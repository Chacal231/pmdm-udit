// ANIMACIÓN DE ONDAS DEL DOBLE TOQUE

// Al tocar dos veces en un lado del vídeo saltamos 10 segundos.
// Para que el usuario lo note, en esa mitad de la pantalla aparece una
// zona iluminada con forma de media luna, unas ondas que se expanden
// desde el dedo y el texto "10 s" (o "20 s", "30 s"… si toca varias veces).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class OndasSalto extends StatelessWidget {
  const OndasSalto({
    super.key,
    required this.animacion,
    required this.derecha,
    required this.segundos,
    required this.origen,
  });

  // Progreso de la animación (0 → 1).
  final Animation<double> animacion;
  // true si el salto es hacia delante (mitad derecha).
  final bool derecha;
  // Segundos acumulados del salto.
  final int segundos;
  // Punto donde se tocó, para que las ondas salgan del dedo.
  final Offset origen;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animacion,
        builder: (context, _) {
          final t = animacion.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();
          // Aparece rápido y se desvanece en la segunda mitad.
          final opacidad = t < 0.5 ? 1.0 : (1 - t) * 2;
          return Opacity(
            opacity: opacidad,
            child: CustomPaint(
              size: Size.infinite,
              painter: _PintorOndas(
                progreso: t,
                derecha: derecha,
                origen: origen,
              ),
              child: Align(
                alignment: derecha
                    ? const Alignment(0.62, 0)
                    : const Alignment(-0.62, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      derecha
                          ? Icons.fast_forward_rounded
                          : Icons.fast_rewind_rounded,
                      size: 36,
                    ),
                    const SizedBox(height: AppEspacios.xs),
                    Text('$segundos s', style: AppTexto.etiqueta),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PintorOndas extends CustomPainter {
  _PintorOndas({
    required this.progreso,
    required this.derecha,
    required this.origen,
  });

  final double progreso;
  final bool derecha;
  final Offset origen;

  @override
  void paint(Canvas canvas, Size size) {
    // Media luna: un círculo enorme que solo asoma por un lateral.
    final radioZona = size.height * 1.1;
    final centroZona = Offset(
      derecha ? size.width + radioZona * 0.45 : -radioZona * 0.45,
      size.height / 2,
    );
    final zona = Path()
      ..addOval(Rect.fromCircle(center: centroZona, radius: radioZona));
    canvas
      ..save()
      ..clipPath(zona)
      ..drawRect(
        Offset.zero & size,
        Paint()..color = AppColores.texto.withValues(alpha: 0.12),
      );

    // Tres ondas que se expanden desde el dedo con un pequeño desfase.
    final radioMaximo = math.max(size.width, size.height) * 0.35;
    for (var i = 0; i < 3; i++) {
      final avance = (progreso - i * 0.15).clamp(0.0, 1.0);
      if (avance == 0) continue;
      canvas.drawCircle(
        origen,
        radioMaximo * Curves.easeOut.transform(avance),
        Paint()
          ..color = AppColores.texto.withValues(alpha: 0.18 * (1 - avance)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorOndas anterior) =>
      anterior.progreso != progreso ||
      anterior.derecha != derecha ||
      anterior.origen != origen;
}
