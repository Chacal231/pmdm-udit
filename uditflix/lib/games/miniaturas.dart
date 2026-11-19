// MINIATURAS ANIMADAS DE LOS JUEGOS

// Pequeñas escenas dibujadas con CustomPainter para las tarjetas del
// Arcade. No son capturas: se pintan en tiempo real a partir de una
// animación que va de 0 a 1 y se repite. Reutilizan los dibujos de los
// propios juegos (la palomita y la nave), así la tarjeta muestra lo que
// el usuario va a jugar.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'flap/componentes/dibujo_palomita.dart';
import 'galaxy/componentes/elementos_galaxy.dart';

// UDIT Flap: cielo al atardecer, columnas que avanzan y la palomita.
class MiniaturaFlap extends CustomPainter {
  MiniaturaFlap(this.animacion) : super(repaint: animacion);

  final Animation<double> animacion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animacion.value;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaArcade.cieloAlto,
            PaletaArcade.cieloMedio,
            PaletaArcade.cieloHorizonte,
          ],
        ).createShader(rect),
    );
    final suelo = size.height * 0.86;
    canvas.drawCircle(
      Offset(size.width * 0.72, suelo - size.height * 0.2),
      size.height * 0.2,
      Paint()..color = AppColores.neonAmarillo.withValues(alpha: 0.75),
    );

    // Columnas que se desplazan y vuelven a entrar por la derecha.
    final ancho = size.width * 0.1;
    final separacion = size.width * 0.42;
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 3; i++) {
      final x =
          (i * separacion - t * separacion * 3) % (separacion * 3) - ancho;
      final centro = size.height * (0.38 + 0.12 * math.sin(i * 2.1));
      final hueco = size.height * 0.36;
      borde.color = i.isEven ? AppColores.neonCian : AppColores.neonMagenta;
      for (final r in [
        Rect.fromLTRB(x, 0, x + ancho, centro - hueco / 2),
        Rect.fromLTRB(x, centro + hueco / 2, x + ancho, suelo),
      ]) {
        canvas
          ..drawRect(r, Paint()..color = PaletaArcade.pelicula)
          ..drawRect(r, borde);
      }
    }
    canvas.drawRect(
      Rect.fromLTRB(0, suelo, size.width, size.height),
      Paint()..color = PaletaArcade.suelo,
    );

    // Palomita que sube y baja.
    final y =
        size.height * 0.45 + math.sin(t * math.pi * 6) * size.height * 0.08;
    DibujoPalomita.pintar(
      canvas,
      Offset(size.width * 0.3, y),
      size.height * 0.11,
      aleteo: math.sin(t * math.pi * 24),
    );
  }

  @override
  bool shouldRepaint(MiniaturaFlap anterior) => false;
}

// Neon Breaker: ladrillos de colores, pala y pelota rebotando.
class MiniaturaBreaker extends CustomPainter {
  MiniaturaBreaker(this.animacion) : super(repaint: animacion);

  final Animation<double> animacion;

  // Onda triangular entre 0 y 1: perfecta para rebotes.
  static double _triangular(double v) => 1 - (v % 2 - 1).abs();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animacion.value;
    canvas.drawRect(Offset.zero & size, Paint()..color = PaletaArcade.espacio);
    final rejilla = Paint()..color = PaletaArcade.rejilla;
    for (var i = 1; i < 6; i++) {
      final y = size.height * (0.55 + i * 0.09);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rejilla);
    }

    const colores = [
      AppColores.neonAmarillo,
      AppColores.neonMagenta,
      AppColores.neonCian,
    ];
    final anchoLadrillo = size.width / 7;
    final altoLadrillo = size.height * 0.08;
    for (var f = 0; f < 3; f++) {
      for (var c = 0; c < 7; c++) {
        // Un ladrillo "parpadea" como si estuviera a punto de romperse.
        final roto = f == 2 && c == (t * 7).floor() % 7;
        final color = colores[f];
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            c * anchoLadrillo + 3,
            size.height * 0.12 + f * (altoLadrillo + 4),
            anchoLadrillo - 6,
            altoLadrillo,
          ),
          const Radius.circular(3),
        );
        canvas
          ..drawRRect(
            r,
            Paint()..color = color.withValues(alpha: roto ? 0.6 : 0.25),
          )
          ..drawRRect(
            r,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
      }
    }

    final xPelota = size.width * (0.1 + 0.8 * _triangular(t * 6));
    final yPelota = size.height * (0.42 + 0.38 * _triangular(t * 8));
    final xPala = (xPelota + size.width * 0.5) / 2;
    final pala = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(xPala, size.height * 0.86),
        width: size.width * 0.24,
        height: 8,
      ),
      const Radius.circular(4),
    );
    canvas
      ..drawRRect(
        pala,
        Paint()
          ..shader = const LinearGradient(
            colors: [AppColores.neonCian, AppColores.neonMagenta],
          ).createShader(pala.outerRect),
      )
      ..drawCircle(
        Offset(xPelota, yPelota),
        9,
        Paint()..color = AppColores.neonCian.withValues(alpha: 0.4),
      )
      ..drawCircle(
        Offset(xPelota, yPelota),
        5,
        Paint()..color = AppColores.texto,
      );
  }

  @override
  bool shouldRepaint(MiniaturaBreaker anterior) => false;
}

// Galaxy Run: estrellas en movimiento, la nave disparando y un enemigo.
class MiniaturaGalaxy extends CustomPainter {
  MiniaturaGalaxy(this.animacion) : super(repaint: animacion);

  final Animation<double> animacion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animacion.value;
    canvas.drawRect(Offset.zero & size, Paint()..color = PaletaArcade.espacio);
    // Estrellas pseudoaleatorias (semilla fija) que bajan.
    final azar = math.Random(9);
    final estrella = Paint()..color = PaletaArcade.estrella;
    for (var i = 0; i < 40; i++) {
      final velocidad = 1 + azar.nextInt(3);
      final x = azar.nextDouble() * size.width;
      final y = (azar.nextDouble() + t * velocidad) % 1 * size.height;
      canvas.drawCircle(Offset(x, y), velocidad * 0.6, estrella);
    }

    final xNave = size.width * (0.5 + 0.3 * math.sin(t * math.pi * 4));
    final yNave = size.height * 0.78;
    // Disparos que suben desde la nave.
    final laser = Paint()..color = AppColores.neonCian;
    for (var i = 0; i < 4; i++) {
      final avance = (t * 8 + i / 4) % 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(xNave, yNave - 20 - avance * size.height * 0.7),
            width: 3,
            height: 10,
          ),
          const Radius.circular(2),
        ),
        laser,
      );
    }
    // Platillo enemigo balanceándose arriba.
    final enemigo = Offset(
      size.width * (0.5 + 0.25 * math.cos(t * math.pi * 2)),
      size.height * 0.2,
    );
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: enemigo.translate(0, -5),
          width: 16,
          height: 13,
        ),
        Paint()..color = AppColores.neonCian.withValues(alpha: 0.85),
      )
      ..drawOval(
        Rect.fromCenter(center: enemigo, width: 36, height: 13),
        Paint()..color = PaletaArcade.enemigo,
      );
    DibujoNave.pintar(canvas, Offset(xNave, yNave), 0.9, t * 20);
  }

  @override
  bool shouldRepaint(MiniaturaGalaxy anterior) => false;
}
