// UDIT FLAP: EL JUEGO

// Juego estilo "flappy" hecho con Flame. Esta clase es el director de
// orquesta: crea los componentes, lleva el bucle de juego y aplica las
// reglas. Las piezas están separadas en componentes:
//   - Palomita (jugador): física e inclinación.
//   - ParColumnas (obstáculos): se reciclan con un pool de 4 parejas.
//   - FondoFlap y SueloFlap: parallax de varias capas.
//   - MarcadorFlap: puntuación con efecto pop.
//
// Bucle de juego (update, unas 60 veces por segundo):
//   1. Las columnas avanzan hacia la izquierda según la dificultad.
//   2. La que sale por la izquierda se recoloca a la derecha.
//   3. Al pasar una columna se suma un punto.
//   4. Si el personaje toca el techo o el suelo, choca. El choque con
//      las columnas lo detecta HasCollisionDetection (ver Palomita).

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../comun/juego_arcade.dart';
import '../comun/particulas.dart';
import 'componentes/columnas.dart';
import 'componentes/fondo.dart';
import 'componentes/jugador.dart';
import 'componentes/marcador.dart';
import 'flap_fisica.dart';

class UditFlapGame extends JuegoArcade
    with HasCollisionDetection, TapCallbacks {
  UditFlapGame() : super(idJuego: IdsJuego.flap);

  @override
  String get titulo => 'UDIT Flap';
  @override
  String get instrucciones =>
      'Toca la pantalla para volar\ny esquiva las columnas de película.';
  @override
  Color get acento => AppColores.neonMagenta;
  @override
  bool get puntosEnHud => false;
  @override
  bool get usaMedallas => true;

  @override
  Color backgroundColor() => PaletaArcade.cieloAlto;

  final math.Random _azar = math.Random();
  // Contenedor de todo lo que "tiembla" al chocar. Mover este único
  // componente es más sencillo que mover la cámara.
  final PositionComponent _escena = PositionComponent();
  final Palomita _jugador = Palomita();
  final MarcadorFlap _marcador = MarcadorFlap();
  final List<ParColumnas> _columnas = List.generate(4, (_) => ParColumnas());

  // Escala: alto real de la pantalla / alto de referencia (720).
  double escala = 1;
  bool muriendo = false;
  double _velocidad = DificultadFlap.velocidad(0);
  double _temblor = 0;
  int _contadorColor = 0;
  TimerComponent? _temporizadorFin;

  static const double _duracionTemblor = 0.4;

  // Altura a la que empieza el suelo.
  double get sueloY => size.y - 96 * escala;
  double get _anchoColumna => 64 * escala;

  // Velocidad (píxeles/s) a la que se desplaza el decorado. En la pantalla
  // de inicio se mueve despacio y al morir se detiene.
  double get velocidadFondo {
    if (muriendo || estado.value == EstadoJuego.fin) return 0;
    final base = _velocidad * escala;
    return jugando ? base : base * 0.35;
  }

  @override
  Future<void> onLoad() async {
    escala = size.y / FisicaFlap.altoReferencia;
    add(_escena);
    _escena.addAll([FondoFlap(), ..._columnas, SueloFlap(), _jugador]);
    add(_marcador..isVisible = false);
    _ajustarEscena();
    _prepararColumnas();
  }

  @override
  void onGameResize(Vector2 size) {
    // La escala se recalcula antes de avisar a los componentes.
    escala = size.y / FisicaFlap.altoReferencia;
    super.onGameResize(size);
    if (!isLoaded) return;
    _ajustarEscena();
    // Solo recolocamos si no hay partida en marcha (ni en pausa).
    if (estado.value == EstadoJuego.inicio) _prepararColumnas();
  }

  void _ajustarEscena() {
    _jugador.ajustar(
      escala,
      Vector2(size.x * 0.3, sueloY * 0.45),
      colocar: estado.value == EstadoJuego.inicio,
    );
    _marcador.ajustar(escala, Vector2(size.x / 2, 110 * escala));
  }

  // Coloca las 4 parejas fuera de la pantalla, a la derecha.
  void _prepararColumnas() {
    var x = size.x + 80 * escala;
    double? anterior;
    for (final par in _columnas) {
      anterior = _colocarPar(par, x, anterior);
      x += DificultadFlap.separacion(0) * escala;
    }
  }

  double _colocarPar(ParColumnas par, double x, double? anterior) {
    final hueco = DificultadFlap.hueco(puntos.value) * escala;
    final centro = centroHueco(
      azar01: _azar.nextDouble(),
      alto: sueloY,
      hueco: hueco,
      margen: 60 * escala,
      anterior: anterior,
      cambioMaximo: DificultadFlap.cambioMaximo * escala,
    );
    // Alternamos cian y magenta para dar ritmo visual.
    final colorNeon = _contadorColor.isEven
        ? AppColores.neonCian
        : AppColores.neonMagenta;
    _contadorColor++;
    par.colocar(
      x: x,
      centro: centro,
      hueco: hueco,
      ancho: _anchoColumna,
      altoJugable: sueloY,
      escala: escala,
      colorNeon: colorNeon,
    );
    return centro;
  }

  // ------------------------------------------------------------------
  // ENTRADA
  // ------------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    switch (estado.value) {
      case EstadoJuego.inicio:
        comenzar();
      case EstadoJuego.jugando:
        if (!muriendo) _saltar();
      case EstadoJuego.pausa || EstadoJuego.fin:
        break;
    }
  }

  @override
  void alComenzar() {
    _marcador
      ..isVisible = true
      ..mostrar(0, conPop: false);
    _saltar();
  }

  void _saltar() {
    _jugador.saltar();
    HapticFeedback.selectionClick();
    // Migas de palomita que salen hacia atrás y hacia abajo.
    _escena.add(
      explosion(
        posicion:
            _jugador.position +
            Vector2(-_jugador.radio * 0.8, _jugador.radio * 0.4),
        colores: const [PaletaArcade.palomita, PaletaArcade.mantequilla],
        cantidad: 7,
        velocidad: 120 * escala,
        radio: 3 * escala,
        duracion: 0.45,
        gravedad: 320 * escala,
        direccion: math.pi * 0.8,
        apertura: 1.1,
      ),
    );
  }

  // ------------------------------------------------------------------
  // BUCLE DE JUEGO
  // ------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    _actualizarTemblor(dt);
    if (!jugando || muriendo) return;

    // La dificultad (velocidad) depende de los puntos.
    _velocidad = DificultadFlap.velocidad(puntos.value);
    final avance = _velocidad * escala * dt;

    ParColumnas? masDerecha;
    for (final par in _columnas) {
      par.x -= avance;
      if (masDerecha == null || par.x > masDerecha.x) masDerecha = par;
    }
    for (final par in _columnas) {
      // Pool: la pareja que sale por la izquierda vuelve por la derecha.
      if (par.x + _anchoColumna < 0) {
        final referencia = masDerecha!;
        _colocarPar(
          par,
          referencia.x + DificultadFlap.separacion(puntos.value) * escala,
          referencia.centro,
        );
        masDerecha = par;
      }
      // Punto: la pareja ha quedado atrás del personaje.
      if (!par.puntuado && par.x + _anchoColumna / 2 < _jugador.x) {
        par.puntuado = true;
        _sumarPunto();
      }
    }

    if (FisicaFlap.fueraDeLimites(
      y: _jugador.y,
      radio: _jugador.radioColision,
      techo: 0,
      suelo: sueloY,
    )) {
      chocar();
    }
  }

  void _sumarPunto() {
    puntos.value++;
    _marcador.mostrar(puntos.value);
  }

  // El personaje ha chocado: partículas, destello, sacudida y vibración.
  // Un momento después aparece la pantalla de Game Over.
  void chocar() {
    if (muriendo || !jugando) return;
    muriendo = true;
    _jugador.aturdida = true;
    if (_jugador.velocidad < 0) _jugador.velocidad = 0;
    HapticFeedback.heavyImpact();
    _temblor = _duracionTemblor;
    _escena.add(
      explosion(
        posicion: _jugador.position,
        colores: const [
          PaletaArcade.palomita,
          PaletaArcade.mantequilla,
          AppColores.neonMagenta,
          AppColores.texto,
        ],
        cantidad: 30,
        velocidad: 260 * escala,
        radio: 4 * escala,
        duracion: 0.8,
        gravedad: 500 * escala,
      ),
    );
    final destello = RectangleComponent(
      size: size.clone(),
      priority: 40,
      paint: Paint()..color = AppColores.texto.withValues(alpha: 0.55),
    );
    destello.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
        onComplete: destello.removeFromParent,
      ),
    );
    add(destello);
    add(
      _temporizadorFin = TimerComponent(
        period: 0.9,
        removeOnFinish: true,
        onTick: terminar,
      ),
    );
  }

  // Sacudida de "cámara": movemos la escena unos píxeles al azar y la
  // intensidad va bajando hasta cero.
  void _actualizarTemblor(double dt) {
    if (_temblor <= 0) return;
    _temblor = math.max(0, _temblor - dt);
    final fuerza = (_temblor / _duracionTemblor) * 8 * escala;
    _escena.position.setValues(
      (_azar.nextDouble() * 2 - 1) * fuerza,
      (_azar.nextDouble() * 2 - 1) * fuerza,
    );
  }

  @override
  void reiniciarEscena() {
    _temporizadorFin?.removeFromParent();
    _temporizadorFin = null;
    muriendo = false;
    _temblor = 0;
    _escena.position.setZero();
    _velocidad = DificultadFlap.velocidad(0);
    _jugador.reiniciar();
    _marcador
      ..isVisible = false
      ..mostrar(0, conPop: false);
    _prepararColumnas();
  }
}
