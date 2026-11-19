// SKELETON CON EFECTO SHIMMER

// Mientras una imagen se descarga mostramos un rectángulo gris con un
// brillo que lo recorre de izquierda a derecha. Indica "esto está
// cargando" sin dejar huecos vacíos. Está hecho a mano, sin paquetes:
// un degradado lineal que se desplaza con un AnimationController.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({super.key, this.borderRadius = BorderRadius.zero});

  final BorderRadius borderRadius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: AppDuraciones.shimmer,
  )..repeat();

  @override
  void dispose() {
    // Liberamos el controlador para no dejar la animación viva.
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            colors: const [
              AppColores.superficie,
              AppColores.superficieAlta,
              AppColores.superficie,
            ],
            stops: const [0.35, 0.5, 0.65],
            transform: _DesplazarGradiente(_controlador.value),
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// Mueve el degradado horizontalmente: con progreso 0 el brillo está fuera
// por la izquierda y con progreso 1 ha salido por la derecha.
class _DesplazarGradiente extends GradientTransform {
  const _DesplazarGradiente(this.progreso);

  final double progreso;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progreso * 2 - 1), 0, 0);
}
