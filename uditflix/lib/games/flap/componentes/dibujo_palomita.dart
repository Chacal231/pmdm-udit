// DIBUJO DE LA PALOMITA (PERSONAJE DE UDIT FLAP)

// El protagonista es una palomita de maíz con ojos, dibujada solo con
// círculos sobre un Canvas: nada de imágenes ni personajes de otros
// juegos. La misma función se usa en el juego y en la miniatura de la
// tarjeta del Arcade.

import 'dart:ui';

import '../../../theme/app_theme.dart';

abstract final class DibujoPalomita {
  // Pinceles creados una sola vez: crearlos en cada frame gastaría memoria.
  static final Paint _contorno = Paint()..color = PaletaArcade.contorno;
  static final Paint _cuerpo = Paint()..color = PaletaArcade.palomita;
  static final Paint _sombra = Paint()..color = PaletaArcade.palomitaSombra;
  static final Paint _mantequilla = Paint()
    ..color = PaletaArcade.mantequilla.withValues(alpha: 0.85);
  static final Paint _ojo = Paint()..color = PaletaArcade.ojo;
  static final Paint _pupila = Paint()..color = PaletaArcade.pupila;
  static final Paint _mejilla = Paint()
    ..color = PaletaArcade.mejilla.withValues(alpha: 0.7);
  static final Paint _trazo = Paint()
    ..color = PaletaArcade.contorno
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // "Bolitas" que forman la palomita: (x, y, radio) relativos al radio.
  static const List<(double, double, double)> _bolitas = [
    (0.0, 0.12, 0.6),
    (-0.46, -0.12, 0.42),
    (0.44, -0.16, 0.44),
    (-0.08, -0.5, 0.42),
    (0.32, 0.42, 0.36),
    (-0.4, 0.36, 0.36),
  ];

  // Pinta la palomita centrada en [centro] con el tamaño de [radio].
  //   - aleteo: entre -1 y 1, mueve el alita.
  //   - aturdida: ojos en forma de X (después de chocar).
  static void pintar(
    Canvas canvas,
    Offset centro,
    double radio, {
    double aleteo = 0,
    bool aturdida = false,
  }) {
    canvas
      ..save()
      ..translate(centro.dx, centro.dy);

    // Alita: un óvalo detrás del cuerpo que sube y baja.
    canvas
      ..save()
      ..translate(-radio * 0.72, radio * 0.02)
      ..rotate(-0.5 + aleteo * 0.6);
    final ala = Rect.fromCenter(
      center: Offset(-radio * 0.18, 0),
      width: radio * 0.62,
      height: radio * 0.34,
    );
    canvas
      ..drawOval(ala.inflate(radio * 0.07), _contorno)
      ..drawOval(ala, _cuerpo)
      ..restore();

    // Contorno: las mismas bolitas un poco más grandes y oscuras.
    for (final (x, y, r) in _bolitas) {
      canvas.drawCircle(
        Offset(x * radio, y * radio),
        (r + 0.08) * radio,
        _contorno,
      );
    }
    // Cuerpo: primero la sombra (desplazada) y luego el color claro.
    for (final (x, y, r) in _bolitas) {
      canvas.drawCircle(Offset(x * radio, y * radio), r * radio, _sombra);
    }
    for (final (x, y, r) in _bolitas) {
      canvas.drawCircle(
        Offset((x - 0.04) * radio, (y - 0.05) * radio),
        r * radio * 0.86,
        _cuerpo,
      );
    }
    // Gotitas de mantequilla.
    canvas
      ..drawCircle(
        Offset(-radio * 0.5, radio * 0.42),
        radio * 0.12,
        _mantequilla,
      )
      ..drawCircle(
        Offset(radio * 0.1, -radio * 0.62),
        radio * 0.09,
        _mantequilla,
      )
      ..drawCircle(
        Offset(-radio * 0.62, -radio * 0.2),
        radio * 0.08,
        _mantequilla,
      );

    // Ojos (mirando hacia delante, a la derecha).
    final ojos = [
      Offset(radio * 0.14, -radio * 0.12),
      Offset(radio * 0.5, -radio * 0.16),
    ];
    _trazo.strokeWidth = radio * 0.09;
    for (final ojo in ojos) {
      if (aturdida) {
        final d = radio * 0.1;
        canvas
          ..drawLine(ojo.translate(-d, -d), ojo.translate(d, d), _trazo)
          ..drawLine(ojo.translate(-d, d), ojo.translate(d, -d), _trazo);
      } else {
        canvas
          ..drawCircle(ojo, radio * 0.19, _contorno)
          ..drawCircle(ojo, radio * 0.16, _ojo)
          ..drawCircle(
            ojo.translate(radio * 0.05, radio * 0.01),
            radio * 0.085,
            _pupila,
          )
          ..drawCircle(
            ojo.translate(radio * 0.08, -radio * 0.04),
            radio * 0.03,
            _ojo,
          );
      }
    }

    // Mejilla y boca sonriente (o de susto si está aturdida).
    canvas.drawCircle(
      Offset(radio * 0.62, radio * 0.12),
      radio * 0.09,
      _mejilla,
    );
    final boca = Rect.fromCenter(
      center: Offset(radio * 0.36, radio * 0.16),
      width: radio * 0.26,
      height: radio * (aturdida ? 0.26 : 0.18),
    );
    _trazo.strokeWidth = radio * 0.07;
    if (aturdida) {
      canvas.drawOval(boca, _trazo);
    } else {
      canvas.drawArc(boca, 0.2, 2.7, false, _trazo);
    }

    canvas.restore();
  }
}
