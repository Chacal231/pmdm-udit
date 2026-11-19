// Importamos Flutter para utilizar sus componentes visuales
import 'package:flutter/material.dart';

// Importamos la lista de contenidos simulados y sus consultas
import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../services/almacen_local.dart';
// Importamos los colores centralizados del tema
import '../theme/app_theme.dart';
import '../widgets/banner_arcade.dart';
import '../widgets/carrusel_destacados.dart';
import '../widgets/fila_contenidos.dart';
import '../widgets/logo_uditflix.dart';
import '../widgets/tarjeta_top10.dart';

// PANTALLA DE CATÁLOGO (INICIO)

// Es la portada de UDITflix, organizada como una plataforma de streaming:
//   - Una barra superior transparente que se vuelve opaca al hacer scroll,
//     con el logotipo y los filtros "Series" / "Películas".
//   - Un carrusel de destacados que ocupa casi toda la pantalla.
//   - Varias filas horizontales: Continuar viendo, Top 10, Tendencias…
//
// Es un StatefulWidget porque recuerda el filtro elegido y escucha el
// scroll para cambiar la opacidad de la barra.
class CatalogoScreen extends StatefulWidget {
  // Constructor de la pantalla
  const CatalogoScreen({super.key, this.onAbrirArcade});

  // Acción del banner del Arcade (cambia a esa pestaña). Si es null,
  // el banner no se muestra.
  final VoidCallback? onAbrirArcade;

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ScrollController _scroll = ScrollController();
  // Opacidad de la barra superior (0 = transparente, 1 = opaca).
  // Con un ValueNotifier solo se redibuja la barra, no toda la pantalla.
  final ValueNotifier<double> _opacidadBarra = ValueNotifier(0);
  // Filtro activo: null (todo), 'Serie' o 'Película'.
  String? _filtro;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alHacerScroll);
  }

  void _alHacerScroll() {
    _opacidadBarra.value = (_scroll.offset / 220).clamp(0.0, 1.0);
  }

  void _cambiarFiltro(String? filtro) {
    setState(() => _filtro = filtro);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    // Liberamos el controlador y el notificador al cerrar la pantalla.
    _scroll.dispose();
    _opacidadBarra.dispose();
    super.dispose();
  }

  // Método que construye la interfaz visual
  @override
  Widget build(BuildContext context) {
    final altoDestacado = AppMedidas.altoDestacado(MediaQuery.sizeOf(context));
    final filtro = _filtro;

    // Scaffold proporciona la estructura básica de una pantalla.
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: CarruselDestacados(
                  // Al cambiar el filtro se crea un carrusel nuevo (empieza
                  // en la primera página y con su propio temporizador).
                  key: ValueKey(filtro),
                  contenidos: destacados(filtro),
                  alto: altoDestacado,
                ),
              ),
              SliverToBoxAdapter(child: _ContinuarViendo(filtro: filtro)),
              SliverList.list(children: _filas(filtro)),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppEspacios.xxxl),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _BarraSuperior(
              opacidad: _opacidadBarra,
              filtro: filtro,
              onFiltro: _cambiarFiltro,
            ),
          ),
        ],
      ),
    );
  }

  // Construye las filas del catálogo según el filtro. Las filas con
  // menos de dos títulos se omiten para que no queden "cojas".
  List<Widget> _filas(String? filtro) {
    final filas = <Widget>[];
    void fila(String titulo, String seccion, List<Contenido> lista) {
      if (lista.length < 2) return;
      filas.add(
        FilaContenidos(titulo: titulo, seccion: seccion, contenidos: lista),
      );
    }

    final top = top10(filtro);
    if (top.length >= 2) {
      final tituloTop = switch (filtro) {
        'Serie' => 'Top 10 series en España hoy',
        'Película' => 'Top 10 películas en España hoy',
        _ => 'Top 10 en España hoy',
      };
      filas.add(FilaTop10(titulo: tituloTop, contenidos: top));
    }
    fila('Tendencias', 'tendencias', tendencias(filtro));
    // Acceso destacado al Arcade entre las filas.
    final abrirArcade = widget.onAbrirArcade;
    if (abrirArcade != null) filas.add(BannerArcade(onTap: abrirArcade));
    if (filtro != 'Película') fila('Series', 'series', porCategoria('Serie'));
    if (filtro != 'Serie') {
      fila('Películas', 'peliculas', porCategoria('Película'));
    }
    fila('Ciencia ficción', 'cifi', porGenero('Ciencia ficción', filtro));
    fila('Animación para todos', 'animacion', porGenero('Animación', filtro));
    if (filtro != 'Serie') {
      fila('Cortos de animación libres', 'cortos', cortosLibres());
    }
    return filas;
  }
}

// Fila "Continuar viendo": solo aparece si hay vídeos empezados.
// Escucha al AlmacenLocal para actualizarse al volver del reproductor.
class _ContinuarViendo extends StatelessWidget {
  const _ContinuarViendo({required this.filtro});

  final String? filtro;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AlmacenLocal.instancia,
      builder: (context, _) {
        final progresos = <int, double>{};
        final lista = <Contenido>[];
        for (final progreso in AlmacenLocal.instancia.continuarViendo) {
          final contenido = contenidoPorId(progreso.idContenido);
          if (contenido == null) continue;
          if (filtro != null && contenido.categoria != filtro) continue;
          lista.add(contenido);
          progresos[contenido.id] = progreso.fraccion;
        }
        if (lista.isEmpty) return const SizedBox.shrink();
        return FilaContenidos(
          titulo: 'Continuar viendo',
          seccion: 'continuar',
          contenidos: lista,
          progresos: progresos,
        );
      },
    );
  }
}

// Barra superior: logotipo y chips de filtro. Su fondo pasa de
// transparente a casi opaco según cuánto se haya desplazado la pantalla.
class _BarraSuperior extends StatelessWidget {
  const _BarraSuperior({
    required this.opacidad,
    required this.filtro,
    required this.onFiltro,
  });

  final ValueNotifier<double> opacidad;
  final String? filtro;
  final ValueChanged<String?> onFiltro;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: opacidad,
      builder: (context, valor, hijo) =>
          ColoredBox(color: AppColores.velo(valor), child: hijo),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppEspacios.margenPantalla,
            AppEspacios.s,
            AppEspacios.margenPantalla,
            AppEspacios.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoUditflix(tamano: 26),
              const SizedBox(height: AppEspacios.m),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Con un filtro activo aparece una "x" para quitarlo.
                    AnimatedSize(
                      duration: AppDuraciones.media,
                      child: filtro == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(
                                right: AppEspacios.s,
                              ),
                              child: IconButton.outlined(
                                tooltip: 'Quitar filtro',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => onFiltro(null),
                                icon: const Icon(Icons.close_rounded, size: 18),
                              ),
                            ),
                    ),
                    _ChipFiltro(
                      texto: 'Series',
                      seleccionado: filtro == 'Serie',
                      onTap: () => onFiltro(filtro == 'Serie' ? null : 'Serie'),
                    ),
                    const SizedBox(width: AppEspacios.s),
                    _ChipFiltro(
                      texto: 'Películas',
                      seleccionado: filtro == 'Película',
                      onTap: () =>
                          onFiltro(filtro == 'Película' ? null : 'Película'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(texto),
      selected: seleccionado,
      onSelected: (_) => onTap(),
      labelStyle: AppTexto.etiqueta.copyWith(
        color: seleccionado ? AppColores.fondo : AppColores.texto,
      ),
    );
  }
}
