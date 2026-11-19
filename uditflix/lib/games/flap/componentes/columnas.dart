// COMPONENTES OBSTÁCULO: COLUMNAS DE PELÍCULA

// Cada obstáculo es una pareja de columnas (arriba y abajo) con un hueco
// entre ellas. Tienen aspecto de tira de película: fondo oscuro, agujeros
// de arrastre en los bordes, fotogramas y un remate de neón junto al hueco.
//
// Las parejas no se crean y destruyen todo el rato: el juego tiene un
// "pool" fijo de parejas y, cuando una sale por la izquierda, la recoloca
// a la derecha con un hueco nuevo (ver UditFlapGame). Así no se reserva
// memoria durante la partida y el juego va más fluido.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../theme/app_theme.dart';

class ParColumnas extends PositionComponent {
  ParColumnas() : super(priority: 0) {
    addAll([arriba, abajo]);
  }

  final Columna arriba = Columna(superior: true);
  final Columna abajo = Columna(superior: false);

  // Centro vertical del hueco (en píxeles) y si ya dio su punto.
  double centro = 0;
  bool puntuado = false;

  // Coloca la pareja en x con el hueco centrado en [centro].
  void colocar({
    required double x,
    required double centro,
    required double hueco,
    required double ancho,
    required double altoJugable,
    required double escala,
    required Color colorNeon,
  }) {
    this.centro = centro;
    puntuado = false;
    position.setValues(x, 0);
    size.setValues(ancho, altoJugable);
    final finArriba = math.max(0.0, centro - hueco / 2);
    final inicioAbajo = math.min(altoJugable, centro + hueco / 2);
    arriba.configurar(
      posicion: Vector2.zero(),
      tamano: Vector2(ancho, finArriba),
      escala: escala,
      color: colorNeon,
    );
    abajo.configurar(
      posicion: Vector2(0, inicioAbajo),
      tamano: Vector2(ancho, altoJugable - inicioAbajo),
      escala: escala,
      color: colorNeon,
    );
  }
}

class Columna extends PositionComponent {
  Columna({required this.superior});

  // La de arriba tiene el remate abajo; la de abajo, arriba.
  final bool superior;

  double _escala = 1;
  // Hitbox pasiva (no comprueba choques entre columnas, solo con el jugador)
  // y un poco más estrecha que el dibujo.
  final RectangleHitbox _hitbox = RectangleHitbox(
    position: Vector2.zero(),
    size: Vector2.zero(),
    collisionType: CollisionType.passive,
  );

  static final Paint _cuerpo = Paint()..color = PaletaArcade.pelicula;
  static final Paint _fotograma = Paint()
    ..color = PaletaArcade.peliculaFotograma;
  static final Paint _agujero = Paint()..color = PaletaArcade.peliculaAgujero;
  final Paint _neon = Paint()..style = PaintingStyle.stroke;
  final Paint _brillo = Paint()..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    add(_hitbox);
  }

  void configurar({
    required Vector2 posicion,
    required Vector2 tamano,
    required double escala,
    required Color color,
  }) {
    position = posicion;
    size = tamano;
    if (_escala != escala || _neon.color != color) {
      _escala = escala;
      _neon
        ..color = color
        ..strokeWidth = 2.5 * escala;
      _brillo
        ..color = color.withValues(alpha: 0.55)
        ..strokeWidth = 6 * escala
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * escala);
    }
    final margen = tamano.x * 0.08;
    _hitbox
      ..position = Vector2(margen, 0)
      ..size = Vector2(tamano.x - margen * 2, tamano.y);
  }

  @override
  void render(Canvas canvas) {
    if (size.y <= 0) return;
    final ancho = size.x;
    final alto = size.y;
    final e = _escala;
    canvas.drawRect(Rect.fromLTWH(0, 0, ancho, alto), _cuerpo);

    // Fotogramas y agujeros: se dibujan desde el hueco hacia fuera para
    // que siempre queden alineados con el remate.
    final paso = 26 * e;
    final ladoAgujero = 5 * e;
    for (var d = 8 * e; d < alto; d += paso) {
      final y = superior ? alto - d - paso * 0.75 : d;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ancho * 0.24, y, ancho * 0.52, paso * 0.75),
          Radius.circular(3 * e),
        ),
        _fotograma,
      );
      final yAgujero = y + paso * 0.3;
      for (final xAgujero in [ancho * 0.07, ancho * 0.93 - ladoAgujero]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(xAgujero, yAgujero, ladoAgujero, ladoAgujero * 1.3),
            Radius.circular(1.5 * e),
          ),
          _agujero,
        );
      }
    }

    // Bordes de neón con resplandor.
    final borde = Rect.fromLTWH(0, 0, ancho, alto);
    canvas
      ..drawRect(borde, _brillo)
      ..drawRect(borde, _neon);

    // Remate junto al hueco: una pieza algo más ancha, como un carrete.
    final altoRemate = 16 * e;
    final saliente = 5 * e;
    final remate = Rect.fromLTWH(
      -saliente,
      superior ? alto - altoRemate : 0,
      ancho + saliente * 2,
      altoRemate,
    );
    final remateRedondo = RRect.fromRectAndRadius(
      remate,
      Radius.circular(4 * e),
    );
    canvas
      ..drawRRect(remateRedondo, _cuerpo)
      ..drawRRect(remateRedondo, _brillo)
      ..drawRRect(remateRedondo, _neon);
  }
}
