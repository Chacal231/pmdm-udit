// GALAXY RUN: EL JUEGO

// Shooter vertical:
//   - La nave se mueve arrastrando el dedo y dispara sola.
//   - Llegan oleadas de naves enemigas (bajan haciendo eses) y meteoritos.
//   - Cada impacto en la nave quita una vida y la deja invulnerable un
//     momento (parpadea). Con 0 vidas, Game Over.
//   - Al acabar cada oleada se suma una bonificación y empieza la
//     siguiente, un poco más difícil (ver LogicaGalaxy.oleada).
//
// Las colisiones son círculo contra círculo (circulosChocan): sencillas,
// rápidas y suficientes para objetos redondeados.

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../comun/geometria.dart';
import '../comun/juego_arcade.dart';
import '../comun/particulas.dart';
import 'componentes/elementos_galaxy.dart';
import 'galaxy_logica.dart';

class GalaxyRunGame extends JuegoArcade with TapCallbacks, DragCallbacks {
  GalaxyRunGame() : super(idJuego: IdsJuego.galaxy);

  @override
  String get titulo => 'Galaxy Run';
  @override
  String get instrucciones =>
      'Arrastra para mover la nave: dispara sola.\n'
      'Esquiva las naves enemigas y los meteoritos.';
  @override
  Color get acento => AppColores.neonVioleta;
  @override
  bool get usaVidas => true;

  @override
  Color backgroundColor() => PaletaArcade.espacio;

  final math.Random _azar = math.Random();
  final Nave _nave = Nave();
  final List<Laser> _lasers = [];
  final List<Objetivo> _objetivos = [];

  double escala = 1;
  int _oleada = 1;
  ConfigOleada _config = LogicaGalaxy.oleada(1);
  int _porAparecer = 0;
  double _temporizadorAparicion = 0;
  double _temporizadorDisparo = 0;
  double _invulnerable = 0;
  TimerComponent? _temporizadorFin;

  void _calcularEscala() {
    escala = math.min(size.x / LogicaGalaxy.anchoReferencia, size.y / 720);
  }

  @override
  Future<void> onLoad() async {
    _calcularEscala();
    addAll([FondoEstrellas(), _nave]);
    reiniciarEscena();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    _calcularEscala();
    if (estado.value == EstadoJuego.inicio) _colocarNave();
  }

  void _colocarNave() {
    _nave
      ..size = Vector2(44, 52) * escala
      ..position = Vector2(size.x / 2, size.y - 150 * escala);
  }

  // ------------------------------------------------------------------
  // PREPARACIÓN
  // ------------------------------------------------------------------

  @override
  void reiniciarEscena() {
    _temporizadorFin?.removeFromParent();
    _temporizadorFin = null;
    for (final c in [..._lasers, ..._objetivos]) {
      c.removeFromParent();
    }
    _lasers.clear();
    _objetivos.clear();
    _oleada = 1;
    _empezarOleada();
    vidas.value = LogicaGalaxy.vidasIniciales;
    _invulnerable = 0;
    _nave
      ..destruida = false
      ..invulnerable = false;
    _colocarNave();
  }

  void _empezarOleada() {
    _config = LogicaGalaxy.oleada(_oleada);
    _porAparecer = _config.enemigos;
    _temporizadorAparicion = 1.4;
  }

  // ------------------------------------------------------------------
  // ENTRADA
  // ------------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    if (estado.value == EstadoJuego.inicio) comenzar();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (estado.value == EstadoJuego.inicio) comenzar();
    if (!jugando || _nave.destruida) return;
    // La nave sigue al dedo sin salirse de la pantalla.
    final mitad = _nave.size / 2;
    _nave.position = (_nave.position + event.localDelta)
      ..clamp(
        Vector2(mitad.x, 110 * escala),
        Vector2(size.x - mitad.x, size.y - mitad.y - 20 * escala),
      );
  }

  @override
  void alComenzar() => mostrarMensaje('Oleada $_oleada');

  // ------------------------------------------------------------------
  // BUCLE DE JUEGO
  // ------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (!jugando) return;
    if (_invulnerable > 0) _invulnerable -= dt;
    _nave.invulnerable = _invulnerable > 0;

    if (!_nave.destruida) _disparar(dt);
    _generarObjetivos(dt);
    _comprobarColisiones();
    _limpiarFueraDePantalla();
    _comprobarFinOleada();
  }

  void _disparar(double dt) {
    _temporizadorDisparo -= dt;
    if (_temporizadorDisparo > 0) return;
    _temporizadorDisparo = LogicaGalaxy.cadenciaDisparo(_oleada);
    final punta = _nave.position + Vector2(0, -24 * escala);
    if (LogicaGalaxy.disparoDoble(_oleada)) {
      _crearLaser(punta + Vector2(-9 * escala, 8 * escala));
      _crearLaser(punta + Vector2(9 * escala, 8 * escala));
    } else {
      _crearLaser(punta);
    }
  }

  void _crearLaser(Vector2 inicio) {
    final laser = Laser(inicio: inicio, escala: escala);
    _lasers.add(laser);
    add(laser);
  }

  void _generarObjetivos(double dt) {
    if (_porAparecer <= 0) return;
    _temporizadorAparicion -= dt;
    if (_temporizadorAparicion > 0) return;
    // Un poco de azar en el ritmo para que no sea monótono.
    _temporizadorAparicion =
        _config.intervalo * (0.7 + _azar.nextDouble() * 0.6);
    _porAparecer--;

    final Objetivo objetivo;
    if (_azar.nextDouble() < _config.probabilidadMeteorito) {
      final radioRef = 14 + _azar.nextDouble() * 16;
      objetivo = Meteorito(
        inicio: Vector2(_xAleatoria(radioRef * escala), -radioRef * escala),
        radioReferencia: radioRef,
        escala: escala,
        velocidad: Vector2(
          (_azar.nextDouble() - 0.5) * 80 * escala,
          (90 + _azar.nextDouble() * 80) * escala,
        ),
        giro: (_azar.nextDouble() - 0.5) * 3,
        azar: _azar,
      );
    } else {
      final amplitud = (20 + _azar.nextDouble() * 40) * escala;
      objetivo = NaveEnemiga(
        inicio: Vector2(_xAleatoria(amplitud + 20 * escala), -20 * escala),
        vida: _config.vidaEnemigo,
        escala: escala,
        velocidad:
            _config.velocidadEnemigo *
            escala *
            (0.85 + _azar.nextDouble() * 0.3),
        amplitud: amplitud,
        frecuencia: 1.5 + _azar.nextDouble() * 1.5,
      );
    }
    _objetivos.add(objetivo);
    add(objetivo);
  }

  double _xAleatoria(double margen) =>
      margen + _azar.nextDouble() * math.max(1, size.x - margen * 2);

  void _comprobarColisiones() {
    // Láseres contra objetivos.
    for (final laser in List.of(_lasers)) {
      for (final objetivo in _objetivos) {
        if (!_chocan(laser.centro, laser.radio, objetivo)) continue;
        _quitarLaser(laser);
        if (objetivo.golpear()) _destruir(objetivo, conPuntos: true);
        break;
      }
    }

    // Objetivos contra la nave (si no está protegida).
    if (_nave.destruida || _invulnerable > 0) return;
    for (final objetivo in List.of(_objetivos)) {
      if (_chocan(_nave.position, _nave.radio, objetivo)) {
        _destruir(objetivo, conPuntos: false);
        _recibirImpacto();
        break;
      }
    }
  }

  bool _chocan(Vector2 centro, double radio, Objetivo objetivo) =>
      circulosChocan(
        x1: centro.x,
        y1: centro.y,
        r1: radio,
        x2: objetivo.centro.x,
        y2: objetivo.centro.y,
        r2: objetivo.radio,
      );

  void _destruir(Objetivo objetivo, {required bool conPuntos}) {
    _objetivos.remove(objetivo);
    objetivo.removeFromParent();
    if (conPuntos) puntos.value += objetivo.puntos;
    add(
      explosion(
        posicion: objetivo.centro,
        colores: objetivo.coloresExplosion,
        cantidad: 22,
        velocidad: 200 * escala,
        radio: 3 * escala,
        duracion: 0.6,
      ),
    );
  }

  void _quitarLaser(Laser laser) {
    _lasers.remove(laser);
    laser.removeFromParent();
  }

  void _recibirImpacto() {
    HapticFeedback.heavyImpact();
    vidas.value--;
    if (vidas.value > 0) {
      _invulnerable = LogicaGalaxy.invulnerabilidad;
      return;
    }
    // Sin vidas: gran explosión y, un momento después, Game Over.
    _nave.destruida = true;
    add(
      explosion(
        posicion: _nave.position,
        colores: const [
          AppColores.neonCian,
          AppColores.neonMagenta,
          PaletaArcade.propulsor,
          AppColores.texto,
        ],
        cantidad: 48,
        velocidad: 280 * escala,
        radio: 4 * escala,
        duracion: 1,
      ),
    );
    add(
      _temporizadorFin = TimerComponent(
        period: 1.1,
        removeOnFinish: true,
        onTick: terminar,
      ),
    );
  }

  void _limpiarFueraDePantalla() {
    for (final laser in List.of(_lasers)) {
      if (laser.centro.y < -20 * escala) _quitarLaser(laser);
    }
    for (final objetivo in List.of(_objetivos)) {
      if (objetivo.centro.y - objetivo.radio > size.y) {
        _objetivos.remove(objetivo);
        objetivo.removeFromParent();
      }
    }
  }

  void _comprobarFinOleada() {
    if (_nave.destruida || _porAparecer > 0 || _objetivos.isNotEmpty) return;
    puntos.value += LogicaGalaxy.bonusOleada(_oleada);
    _oleada++;
    _empezarOleada();
    mostrarMensaje('Oleada $_oleada');
  }
}
