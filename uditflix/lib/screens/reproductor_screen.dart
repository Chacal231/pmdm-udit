// PANTALLA DEL REPRODUCTOR

// Reproductor de vídeo con controles propios, construido sobre el
// paquete video_player. Así funciona, paso a paso:
//
// 1. Al entrar se pone la pantalla en horizontal e inmersiva y se crea
//    un VideoPlayerController con la URL del contenido.
// 2. Mientras se inicializa se ve el spinner rojo. Si en 13 segundos no
//    ha arrancado, o da error, se pasa solo al vídeo de respaldo (muy
//    ligero) y se avisa con un mensaje discreto. Si también falla,
//    aparece el panel de error con el botón "Reintentar".
// 3. Si el usuario ya había empezado este título, se le pregunta si
//    quiere reanudar o empezar desde el principio.
// 4. Durante la reproducción, los controles aparecen al tocar y se
//    ocultan solos a los 3 segundos. Con doble toque en un lado se
//    salta ±10 s.
// 5. Al pausar o salir se guarda la posición (Continuar viendo).
// 6. Al terminar se muestra la pantalla de fin con una sugerencia.
// 7. Al salir se restauran la orientación y las barras del sistema, y
//    se liberan el controlador, los temporizadores y el wakelock.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/contenidos.dart';
import '../data/cortos_demo.dart';
import '../models/contenido.dart';
import '../models/progreso_visionado.dart';
import '../navigation/transiciones.dart';
import '../services/almacen_local.dart';
import '../services/sistema_pantalla.dart';
import '../theme/app_theme.dart';
import '../widgets/reproductor/controles_reproductor.dart';
import '../widgets/reproductor/ondas_salto.dart';
import '../widgets/reproductor/paneles_reproductor.dart';

class ReproductorScreen extends StatefulWidget {
  const ReproductorScreen({super.key, required this.contenido});

  // Título que se va a reproducir.
  final Contenido contenido;

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

// Momentos por los que pasa el reproductor.
enum _Fase { cargando, preguntarReanudar, reproduciendo, terminado, error }

class _ReproductorScreenState extends State<ReproductorScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Tiempo máximo de espera antes de pasar al vídeo de respaldo.
  static const Duration _limiteCarga = Duration(seconds: 13);
  static const Duration _salto = Duration(seconds: 10);

  // Reproductores abiertos. Al pasar de un vídeo a otro (pantalla de fin)
  // el nuevo se abre antes de cerrar el anterior: solo el último que se
  // cierre debe devolver la app a vertical.
  static int _abiertos = 0;

  VideoPlayerController? _controlador;
  // Controladores que aún están inicializándose. Si los descartamos en
  // ese momento, se liberan ellos solos cuando termine la inicialización.
  final Set<VideoPlayerController> _inicializando = {};

  Timer? _temporizadorCarga;
  Timer? _temporizadorControles;
  Timer? _temporizadorAviso;

  _Fase _fase = _Fase.cargando;
  bool _usandoRespaldo = false;
  // Aviso discreto superior (vídeo de respaldo o episodio de demostración).
  bool _avisoVisible = false;
  String _avisoTexto = '';
  IconData _avisoIcono = Icons.info_outline_rounded;
  bool _avisoDemoMostrado = false;
  bool _controlesVisibles = true;
  // Lo que el usuario quiere: que suene o que esté en pausa. No usamos
  // directamente value.isPlaying porque ExoPlayer lo pone a false mientras
  // carga datos (buffering), y eso no es una pausa del usuario.
  bool _quiereReproducir = false;
  bool _wakelockActivo = false;
  bool _salido = false;
  double _velocidad = 1;
  // Posición 0-1 mientras se arrastra la barra de progreso.
  double? _arrastre;
  // Progreso guardado de una sesión anterior (para "Reanudar desde").
  ProgresoVisionado? _progresoPrevio;

  // Animación de ondas del doble toque.
  late final AnimationController _ondas = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  bool _ondaDerecha = true;
  int _saltoAcumulado = 0;
  Offset _origenOnda = Offset.zero;
  Offset _puntoDobleToque = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _abiertos++;
    SistemaPantalla.modoReproductor();
    _progresoPrevio = AlmacenLocal.instancia.progresoDe(widget.contenido.id);
    _cargar(respaldo: false);
  }

  // ------------------------------------------------------------------
  // CARGA DEL VÍDEO
  // ------------------------------------------------------------------

  Future<void> _cargar({required bool respaldo}) async {
    _temporizadorCarga?.cancel();
    final url = respaldo ? videoRespaldoUrl : widget.contenido.videoUrl;
    final controlador = VideoPlayerController.networkUrl(Uri.parse(url));
    final anterior = _controlador;
    _controlador = controlador;
    _descartar(anterior);
    // En la primera carga (desde initState) el estado ya es el correcto y
    // no se puede llamar a setState; solo redibujamos si algo cambia.
    if (_fase != _Fase.cargando || _usandoRespaldo != respaldo) {
      setState(() {
        _fase = _Fase.cargando;
        _usandoRespaldo = respaldo;
      });
    }

    // Si tarda demasiado, lo damos por perdido y pasamos al plan B.
    _temporizadorCarga = Timer(_limiteCarga, () {
      if (identical(controlador, _controlador) &&
          !controlador.value.isInitialized) {
        _alFallar('el vídeo ha tardado más de ${_limiteCarga.inSeconds} s');
      }
    });

    _inicializando.add(controlador);
    Object? error;
    try {
      await controlador.initialize();
    } catch (e) {
      error = e;
    }
    _inicializando.remove(controlador);

    // Si mientras tanto el usuario salió o se empezó otro intento,
    // este controlador ya no sirve: lo liberamos y no hacemos nada más.
    if (!mounted || !identical(controlador, _controlador)) {
      await controlador.dispose();
      return;
    }
    _temporizadorCarga?.cancel();
    if (error != null) {
      _alFallar('$error');
      return;
    }

    controlador.addListener(_alCambiarVideo);
    await controlador.setPlaybackSpeed(_velocidad);
    if (!mounted) return;

    final previo = _progresoPrevio;
    final total = controlador.value.duration;
    final hayQuePreguntar =
        !respaldo &&
        previo != null &&
        previo.segundos >= 5 &&
        Duration(seconds: previo.segundos) < total - const Duration(seconds: 5);
    if (hayQuePreguntar) {
      setState(() => _fase = _Fase.preguntarReanudar);
    } else {
      await _empezar(Duration.zero);
    }
  }

  // Libera un controlador que ya no se va a usar.
  void _descartar(VideoPlayerController? controlador) {
    if (controlador == null) return;
    controlador.removeListener(_alCambiarVideo);
    // Si sigue inicializándose, se liberará al terminar (ver _cargar).
    if (!_inicializando.contains(controlador)) controlador.dispose();
  }

  void _alFallar(String detalle) {
    debugPrint('Error de vídeo en «${widget.contenido.titulo}»: $detalle');
    _temporizadorCarga?.cancel();
    if (!_usandoRespaldo) {
      // Primer fallo: plan B automático con aviso discreto.
      _mostrarAviso(
        'El vídeo no responde: reproduciendo uno de respaldo',
        Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
      );
      unawaited(_cargar(respaldo: true));
    } else {
      // También ha fallado el respaldo: mostramos el error.
      _activarWakelock(false);
      setState(() => _fase = _Fase.error);
    }
  }

  void _mostrarAviso(String texto, IconData icono) {
    _temporizadorAviso?.cancel();
    setState(() {
      _avisoTexto = texto;
      _avisoIcono = icono;
      _avisoVisible = true;
    });
    _temporizadorAviso = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _avisoVisible = false);
    });
  }

  // La primera vez que arranca un título real avisamos de que lo que se
  // ve es un corto libre de demostración (con su atribución CC BY).
  void _avisarEpisodioDemo() {
    if (_avisoDemoMostrado || _usandoRespaldo) return;
    if (widget.contenido.esCortoLibre) return;
    final corto = cortoPorUrl(widget.contenido.videoUrl);
    if (corto == null) return;
    _avisoDemoMostrado = true;
    _mostrarAviso(
      'Episodio de demostración · ${corto.titulo} '
      '(Blender Foundation, CC BY)',
      Icons.movie_filter_outlined,
    );
  }

  Future<void> _empezar(Duration desde) async {
    final controlador = _controlador;
    if (controlador == null || !mounted) return;
    setState(() => _fase = _Fase.reproduciendo);
    if (desde > Duration.zero) await controlador.seekTo(desde);
    _reproducir(true);
    if (mounted) _avisarEpisodioDemo();
  }

  // ------------------------------------------------------------------
  // ESCUCHA DEL VÍDEO
  // ------------------------------------------------------------------

  // Se ejecuta cada vez que cambia algo del vídeo (posición, buffer,
  // play/pausa, errores…).
  void _alCambiarVideo() {
    final controlador = _controlador;
    if (!mounted || controlador == null) return;
    final valor = controlador.value;

    if (valor.hasError) {
      _alFallar(valor.errorDescription ?? 'error de reproducción');
      return;
    }

    final haTerminado =
        valor.duration > Duration.zero &&
        !valor.isPlaying &&
        valor.position >= valor.duration - const Duration(milliseconds: 400);
    if (haTerminado && _fase == _Fase.reproduciendo) {
      _quiereReproducir = false;
      _activarWakelock(false);
      _guardarProgreso();
      _fase = _Fase.terminado;
    }
    // Redibujamos para actualizar la barra de progreso, el buffer, etc.
    setState(() {});
  }

  // Reproduce o pausa por decisión del usuario.
  void _reproducir(bool reproducir) {
    final controlador = _controlador;
    if (controlador == null) return;
    _quiereReproducir = reproducir;
    // La pantalla solo se mantiene encendida mientras se está viendo.
    _activarWakelock(reproducir);
    if (reproducir) {
      controlador.play();
    } else {
      controlador.pause();
      // Al pausar guardamos por dónde va (Continuar viendo).
      _guardarProgreso();
    }
    // Reproduciendo, los controles se ocultan solos; en pausa se quedan.
    _mostrarControles();
  }

  // True mientras el usuario quiere ver el vídeo pero aún llegan datos.
  bool get _cargandoDatos =>
      _quiereReproducir && (_controlador?.value.isBuffering ?? false);

  void _activarWakelock(bool activo) {
    if (activo == _wakelockActivo) return;
    _wakelockActivo = activo;
    unawaited(WakelockPlus.toggle(enable: activo));
  }

  // Guarda la posición para "Continuar viendo". Si casi se ha terminado
  // (95 % o más), se borra para que no aparezca en la fila.
  // Con diferido = true se guarda justo después del frame actual (hace
  // falta en dispose, cuando el árbol de widgets no admite cambios).
  void _guardarProgreso({bool diferido = false}) {
    final controlador = _controlador;
    if (_usandoRespaldo ||
        controlador == null ||
        !controlador.value.isInitialized) {
      return;
    }
    final total = controlador.value.duration;
    final posicion = controlador.value.position;
    if (total <= Duration.zero) return;
    final id = widget.contenido.id;

    void guardar() {
      if (posicion >= total * 0.95) {
        AlmacenLocal.instancia.borrarProgreso(id);
      } else if (posicion.inSeconds >= 5) {
        AlmacenLocal.instancia.guardarProgreso(
          id,
          segundos: posicion.inSeconds,
          duracionTotal: total.inSeconds,
        );
      }
    }

    diferido ? scheduleMicrotask(guardar) : guardar();
  }

  // ------------------------------------------------------------------
  // CONTROLES
  // ------------------------------------------------------------------

  void _mostrarControles() {
    _temporizadorControles?.cancel();
    setState(() => _controlesVisibles = true);
    if (_quiereReproducir && _arrastre == null) {
      _temporizadorControles = Timer(AppDuraciones.ocultarControles, () {
        if (mounted) setState(() => _controlesVisibles = false);
      });
    }
  }

  void _alternarControles() {
    if (_controlesVisibles) {
      _temporizadorControles?.cancel();
      setState(() => _controlesVisibles = false);
    } else {
      _mostrarControles();
    }
  }

  void _playPausa() => _reproducir(!_quiereReproducir);

  Future<void> _saltar(Duration desplazamiento) async {
    final controlador = _controlador;
    if (controlador == null || !controlador.value.isInitialized) return;
    final total = controlador.value.duration;
    var destino = controlador.value.position + desplazamiento;
    if (destino < Duration.zero) destino = Duration.zero;
    if (destino > total) destino = total;
    await controlador.seekTo(destino);
    if (_controlesVisibles) _mostrarControles();
  }

  // Doble toque: la mitad izquierda retrocede y la derecha avanza.
  void _alDobleToque(double ancho) {
    final derecha = _puntoDobleToque.dx > ancho / 2;
    // Si se repite en el mismo lado mientras dura la animación, se acumula.
    _saltoAcumulado = _ondas.isAnimating && _ondaDerecha == derecha
        ? _saltoAcumulado + _salto.inSeconds
        : _salto.inSeconds;
    _ondaDerecha = derecha;
    _origenOnda = _puntoDobleToque;
    _ondas.forward(from: 0);
    _saltar(derecha ? _salto : -_salto);
  }

  Future<void> _cambiarVelocidad(double velocidad) async {
    setState(() => _velocidad = velocidad);
    await _controlador?.setPlaybackSpeed(velocidad);
    _mostrarControles();
  }

  Future<void> _finArrastre(double valor) async {
    final controlador = _controlador;
    if (controlador == null) return;
    await controlador.seekTo(controlador.value.duration * valor);
    if (!mounted) return;
    setState(() => _arrastre = null);
    _mostrarControles();
  }

  // Rebobinamos antes de cambiar de fase: si no, el listener aún vería
  // la posición final y volvería a mostrar la pantalla de fin.
  Future<void> _verDeNuevo() async {
    final controlador = _controlador;
    if (controlador == null) return;
    await controlador.seekTo(Duration.zero);
    await _empezar(Duration.zero);
  }

  // Sugerencia para la pantalla de fin: el título más parecido.
  Contenido? get _sugerencia {
    final parecidos = similares(widget.contenido, maximo: 1);
    return parecidos.isEmpty ? null : parecidos.first;
  }

  void _reproducirSugerencia(Contenido otro) {
    Navigator.of(context)
        .pushReplacement(rutaUdit<void>(ReproductorScreen(contenido: otro)));
  }

  // ------------------------------------------------------------------
  // SALIDA Y CICLO DE VIDA
  // ------------------------------------------------------------------

  // Se llama al salir con la flecha de la app o con el botón "atrás"
  // del sistema (gracias a PopScope). Restauramos la orientación en
  // ese mismo momento para que el catálogo no se vea girado ni un frame.
  void _alSalir() {
    if (_salido) return;
    _salido = true;
    _quiereReproducir = false;
    _controlador?.pause();
    _guardarProgreso();
    _activarWakelock(false);
    if (_abiertos == 1) SistemaPantalla.modoNormal();
  }

  void _volver() => Navigator.of(context).maybePop();

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    switch (estado) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        // La app pasa a segundo plano: pausamos y guardamos.
        if (_fase == _Fase.reproduciendo) _reproducir(false);
      case AppLifecycleState.resumed:
        // Android puede devolver las barras al volver: las ocultamos otra vez.
        if (!_salido) SistemaPantalla.modoReproductor();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _temporizadorCarga?.cancel();
    _temporizadorControles?.cancel();
    _temporizadorAviso?.cancel();
    _ondas.dispose();
    if (!_salido) _guardarProgreso(diferido: true);
    _activarWakelock(false);
    _descartar(_controlador);
    _abiertos--;
    if (_abiertos == 0 && !_salido) SistemaPantalla.modoNormal();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // INTERFAZ
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controlador = _controlador;
    final listo = controlador != null && controlador.value.isInitialized;

    return PopScope(
      onPopInvokedWithResult: (seHaCerrado, _) {
        if (seHaCerrado) _alSalir();
      },
      child: Scaffold(
        backgroundColor: AppColores.negro,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Vídeo centrado con su proporción real.
            if (listo && _fase != _Fase.error)
              Center(
                child: AspectRatio(
                  aspectRatio: controlador.value.aspectRatio,
                  child: VideoPlayer(controlador),
                ),
              ),

            if (listo && _fase == _Fase.reproduciendo) ...[
              // Capa de gestos: toque para mostrar u ocultar los controles
              // y doble toque a los lados para saltar.
              LayoutBuilder(
                builder: (context, restricciones) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _alternarControles,
                  onDoubleTapDown: (d) => _puntoDobleToque = d.localPosition,
                  onDoubleTap: () => _alDobleToque(restricciones.maxWidth),
                ),
              ),
              OndasSalto(
                animacion: _ondas,
                derecha: _ondaDerecha,
                segundos: _saltoAcumulado,
                origen: _origenOnda,
              ),
              // Si los controles están ocultos y el vídeo se queda
              // cargando, mostramos al menos el spinner.
              if (!_controlesVisibles && _cargandoDatos)
                const IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              IgnorePointer(
                ignoring: !_controlesVisibles,
                child: AnimatedOpacity(
                  opacity: _controlesVisibles ? 1 : 0,
                  duration: AppDuraciones.media,
                  child: ControlesReproductor(
                    titulo: widget.contenido.titulo,
                    valor: controlador.value,
                    reproduciendo: _quiereReproducir,
                    cargandoDatos: _cargandoDatos,
                    velocidad: _velocidad,
                    arrastre: _arrastre,
                    usandoRespaldo: _usandoRespaldo,
                    onVolver: _volver,
                    onPlayPausa: _playPausa,
                    onRetroceder: () => _saltar(-_salto),
                    onAvanzar: () => _saltar(_salto),
                    onArrastreInicio: (v) {
                      _temporizadorControles?.cancel();
                      setState(() => _arrastre = v);
                    },
                    onArrastre: (v) => setState(() => _arrastre = v),
                    onArrastreFin: _finArrastre,
                    onVelocidad: _cambiarVelocidad,
                    onMenuAbierto: () => _temporizadorControles?.cancel(),
                    onMenuCerrado: _mostrarControles,
                  ),
                ),
              ),
            ],

            ..._panelSegunFase(),

            AvisoDiscreto(
              visible: _avisoVisible,
              texto: _avisoTexto,
              icono: _avisoIcono,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _panelSegunFase() {
    final contenido = widget.contenido;
    switch (_fase) {
      case _Fase.cargando:
        return [PanelCarga(contenido: contenido, onVolver: _volver)];
      case _Fase.preguntarReanudar:
        final previo = _progresoPrevio!;
        return [
          PanelReanudar(
            contenido: contenido,
            posicion: Duration(seconds: previo.segundos),
            onReanudar: () => _empezar(Duration(seconds: previo.segundos)),
            onDesdeInicio: () => _empezar(Duration.zero),
            onVolver: _volver,
          ),
        ];
      case _Fase.terminado:
        final otro = _sugerencia;
        return [
          PanelFin(
            contenido: contenido,
            sugerencia: otro,
            creditos: _usandoRespaldo
                ? creditosVideoRespaldo
                : contenido.creditosVideo,
            onVerDeNuevo: _verDeNuevo,
            onSugerencia: () {
              if (otro != null) _reproducirSugerencia(otro);
            },
            onVolver: _volver,
          ),
        ];
      case _Fase.error:
        return [
          PanelError(
            contenido: contenido,
            onReintentar: () => _cargar(respaldo: false),
            onVolver: _volver,
          ),
        ];
      case _Fase.reproduciendo:
        return const [];
    }
  }
}
