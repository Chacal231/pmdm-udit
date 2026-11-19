// NEON BREAKER: EL JUEGO

// Rompe-ladrillos con estética de neón:
//   - La pala se mueve arrastrando el dedo; un toque lanza la pelota.
//   - La pelota rebota en paredes, techo, pala y ladrillos. En la pala,
//     el ángulo depende de dónde golpea (LogicaBreaker.reboteEnPala).
//   - Los ladrillos aguantan 1, 2 o 3 golpes y sueltan partículas al romperse.
//   - Algunos sueltan un power-up que ensancha la pala durante 10 s.
//   - 3 vidas y 5 niveles; al superar el último, victoria.
//
// La pelota se mueve en pequeños subpasos en cada frame: así, aunque vaya
// muy rápida, nunca "atraviesa" un ladrillo sin tocarlo.

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../comun/geometria.dart';
import '../comun/juego_arcade.dart';
import '../comun/particulas.dart';
import 'breaker_logica.dart';
import 'componentes/elementos_breaker.dart';

class NeonBreakerGame extends JuegoArcade with TapCallbacks, DragCallbacks {
  NeonBreakerGame() : super(idJuego: IdsJuego.breaker);

  @override
  String get titulo => 'Neon Breaker';
  @override
  String get instrucciones =>
      'Arrastra para mover la pala\ny toca para lanzar la pelota.';
  @override
  Color get acento => AppColores.neonCian;
  @override
  bool get usaVidas => true;

  @override
  Color backgroundColor() => PaletaArcade.espacio;

  final math.Random _azar = math.Random();
  final Pala _pala = Pala();
  final Pelota _pelota = Pelota();
  final List<Ladrillo> _ladrillos = [];
  final List<PowerUp> _powerUps = [];

  double escala = 1;
  int _nivel = 1;
  bool _pelotaEnPala = true;
  double _tiempoPalaAncha = 0;

  // Altura del techo (debajo del marcador) y de la pala.
  double get techo => 96 * escala;
  double get _yPala => size.y - 110 * escala;

  void _calcularEscala() {
    escala = math.min(size.x / LogicaBreaker.anchoReferencia, size.y / 720);
  }

  @override
  Future<void> onLoad() async {
    _calcularEscala();
    addAll([FondoNeon(), _pala, _pelota]);
    reiniciarEscena();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    _calcularEscala();
    // Si cambia el tamaño antes de jugar, recolocamos todo. Durante una
    // partida (o en pausa) no tocamos nada para no perder el progreso.
    if (estado.value == EstadoJuego.inicio) reiniciarEscena();
  }

  // ------------------------------------------------------------------
  // PREPARACIÓN
  // ------------------------------------------------------------------

  @override
  void reiniciarEscena() {
    _nivel = 1;
    vidas.value = LogicaBreaker.vidasIniciales;
    _pala.ajustar(escala, Vector2(size.x / 2, _yPala));
    _pelota.ajustar(escala);
    _tiempoPalaAncha = 0;
    _limpiarPowerUps();
    _construirNivel();
    _devolverPelotaAPala();
  }

  void _construirNivel() {
    for (final l in _ladrillos) {
      l.removeFromParent();
    }
    _ladrillos.clear();
    final diseno = LogicaBreaker.disenoNivel(_nivel);
    final margen = 14 * escala;
    final hueco = 6 * escala;
    final anchoLadrillo =
        (size.x - margen * 2 - hueco * (LogicaBreaker.columnas - 1)) /
        LogicaBreaker.columnas;
    final altoLadrillo = 22 * escala;
    for (var f = 0; f < diseno.length; f++) {
      for (var c = 0; c < LogicaBreaker.columnas; c++) {
        final resistencia = diseno[f][c];
        if (resistencia == 0) continue;
        final ladrillo = Ladrillo(
          resistenciaInicial: resistencia,
          posicion: Vector2(
            margen + c * (anchoLadrillo + hueco),
            techo + 36 * escala + f * (altoLadrillo + hueco),
          ),
          tamano: Vector2(anchoLadrillo, altoLadrillo),
          escala: escala,
        );
        _ladrillos.add(ladrillo);
        add(ladrillo);
      }
    }
  }

  void _devolverPelotaAPala() {
    _pelotaEnPala = true;
    _pelota.velocidad.setZero();
    _colocarPelotaSobrePala();
    _pelota.limpiarEstela();
  }

  void _colocarPelotaSobrePala() {
    _pelota.centro.setValues(
      _pala.x,
      _pala.y - _pala.size.y / 2 - _pelota.radio,
    );
  }

  void _limpiarPowerUps() {
    for (final p in _powerUps) {
      p.removeFromParent();
    }
    _powerUps.clear();
    _pala.ancha = false;
  }

  // ------------------------------------------------------------------
  // ENTRADA
  // ------------------------------------------------------------------

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (estado.value == EstadoJuego.inicio) comenzar();
    if (!jugando) return;
    _pala.mover(event.localDelta.x);
  }

  // Un toque (sin arrastrar) empieza la partida y lanza la pelota.
  @override
  void onTapUp(TapUpEvent event) {
    if (estado.value == EstadoJuego.inicio) comenzar();
    if (jugando && _pelotaEnPala) _lanzar();
  }

  @override
  void alComenzar() => mostrarMensaje('Nivel $_nivel');

  void _lanzar() {
    _pelotaEnPala = false;
    // Sale con un pequeño ángulo aleatorio para que no sea siempre igual.
    final (vx, vy) = LogicaBreaker.reboteEnPala(
      (_azar.nextDouble() - 0.5) * 0.6,
      LogicaBreaker.rapidez(_nivel) * escala,
    );
    _pelota.velocidad.setValues(vx, vy);
  }

  // ------------------------------------------------------------------
  // BUCLE DE JUEGO
  // ------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (!jugando) {
      if (_pelotaEnPala) _colocarPelotaSobrePala();
      return;
    }
    _actualizarPowerUps(dt);
    if (_pelotaEnPala) {
      _colocarPelotaSobrePala();
    } else {
      _moverPelota(dt);
    }
  }

  void _moverPelota(double dt) {
    final p = _pelota;
    final r = p.radio;
    // Dividimos el movimiento en pasos de medio radio como máximo.
    final distancia = p.velocidad.length * dt;
    final pasos = math.max(1, (distancia / (r * 0.5)).ceil());
    final dtPaso = dt / pasos;

    for (var i = 0; i < pasos; i++) {
      p.centro.addScaled(p.velocidad, dtPaso);

      // Paredes y techo.
      if (p.centro.x - r < 0) {
        p.centro.x = r;
        p.velocidad.x = p.velocidad.x.abs();
      } else if (p.centro.x + r > size.x) {
        p.centro.x = size.x - r;
        p.velocidad.x = -p.velocidad.x.abs();
      }
      if (p.centro.y - r < techo) {
        p.centro.y = techo + r;
        p.velocidad.y = p.velocidad.y.abs();
      }

      // Pala: solo cuenta si la pelota baja.
      final pala = _pala.rect;
      if (p.velocidad.y > 0 && _toca(pala)) {
        p.centro.y = pala.top - r;
        final impacto = LogicaBreaker.impactoRelativo(
          p.centro.x,
          _pala.x,
          _pala.size.x,
        );
        final (vx, vy) = LogicaBreaker.reboteEnPala(
          impacto,
          LogicaBreaker.rapidez(_nivel) * escala,
        );
        p.velocidad.setValues(vx, vy);
        HapticFeedback.selectionClick();
      }

      // Ladrillos: como mucho uno por subpaso.
      for (final ladrillo in _ladrillos) {
        final caja = ladrillo.rect;
        if (!_toca(caja)) continue;
        final eje = LogicaBreaker.ejeRebote(
          cx: p.centro.x,
          cy: p.centro.y,
          radio: r,
          izquierda: caja.left,
          arriba: caja.top,
          derecha: caja.right,
          abajo: caja.bottom,
        );
        // Rebote y separación para no quedarse "pegada" dentro.
        if (eje == EjeRebote.horizontal) {
          p.velocidad.x = -p.velocidad.x;
          p.centro.x = p.velocidad.x > 0 ? caja.right + r : caja.left - r;
        } else {
          p.velocidad.y = -p.velocidad.y;
          p.centro.y = p.velocidad.y > 0 ? caja.bottom + r : caja.top - r;
        }
        _golpear(ladrillo);
        break;
      }
      if (_ladrillos.isEmpty) {
        _nivelSuperado();
        return;
      }

      // Se ha escapado por abajo.
      if (p.centro.y - r > size.y) {
        _perderVida();
        return;
      }
    }
  }

  bool _toca(Rect caja) => circuloChocaRect(
    cx: _pelota.centro.x,
    cy: _pelota.centro.y,
    radio: _pelota.radio,
    izquierda: caja.left,
    arriba: caja.top,
    derecha: caja.right,
    abajo: caja.bottom,
  );

  void _golpear(Ladrillo ladrillo) {
    if (!ladrillo.golpear()) return;
    // Roto: puntos, partículas y quizá un power-up.
    _ladrillos.remove(ladrillo);
    ladrillo.removeFromParent();
    puntos.value += LogicaBreaker.puntosPorLadrillo(
      ladrillo.resistenciaInicial,
    );
    HapticFeedback.lightImpact();
    final centro = ladrillo.position + ladrillo.size / 2;
    add(
      explosion(
        posicion: centro,
        colores: [
          colorResistencia(ladrillo.resistenciaInicial),
          AppColores.texto,
        ],
        cantidad: 18,
        velocidad: 180 * escala,
        radio: 3 * escala,
        duracion: 0.6,
        gravedad: 260 * escala,
      ),
    );
    if (_azar.nextDouble() < LogicaBreaker.probabilidadPowerUp) {
      final powerUp = PowerUp(inicio: centro, escala: escala);
      _powerUps.add(powerUp);
      add(powerUp);
    }
  }

  void _actualizarPowerUps(double dt) {
    if (_tiempoPalaAncha > 0) {
      _tiempoPalaAncha -= dt;
      if (_tiempoPalaAncha <= 0) _pala.ancha = false;
    }
    final pala = _pala.rect;
    for (final powerUp in List.of(_powerUps)) {
      final caja = powerUp.rect;
      if (caja.overlaps(pala)) {
        _pala.ancha = true;
        _tiempoPalaAncha = LogicaBreaker.duracionPalaAncha;
        mostrarMensaje('¡Pala ancha!', segundos: 1.2);
        HapticFeedback.mediumImpact();
        _quitarPowerUp(powerUp);
      } else if (caja.top > size.y) {
        _quitarPowerUp(powerUp);
      }
    }
  }

  void _quitarPowerUp(PowerUp powerUp) {
    _powerUps.remove(powerUp);
    powerUp.removeFromParent();
  }

  void _perderVida() {
    HapticFeedback.heavyImpact();
    add(
      explosion(
        posicion: Vector2(_pelota.centro.x, size.y - 4 * escala),
        colores: const [AppColores.neonCian, AppColores.neonMagenta],
        cantidad: 26,
        velocidad: 240 * escala,
        radio: 3 * escala,
        duracion: 0.7,
        gravedad: 400 * escala,
        direccion: -math.pi / 2,
        apertura: 2.2,
      ),
    );
    vidas.value--;
    if (vidas.value <= 0) {
      terminar();
      return;
    }
    mostrarMensaje(vidas.value == 1 ? '¡Última vida!' : '¡Cuidado!');
    _devolverPelotaAPala();
  }

  void _nivelSuperado() {
    _limpiarPowerUps();
    if (_nivel >= LogicaBreaker.nivelesTotales) {
      puntos.value += LogicaBreaker.bonusVictoria(vidas.value);
      terminar(victoria: true);
      return;
    }
    _nivel++;
    mostrarMensaje('Nivel $_nivel');
    _construirNivel();
    _devolverPelotaAPala();
  }
}
