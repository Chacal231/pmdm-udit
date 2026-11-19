// LOGOTIPO DE UDITFLIX

// Logotipo propio hecho solo con texto (sin imágenes ni marcas ajenas):
// "UDIT" en rojo de marca y "flix" en blanco, muy grueso y compacto.
// También incluimos la "U" suelta, que hace de icono en la barra superior.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LogoUditflix extends StatelessWidget {
  const LogoUditflix({super.key, this.tamano = 28, this.brillo = 0});

  // Tamaño de la letra.
  final double tamano;
  // Intensidad del resplandor rojo entre 0 y 1 (lo anima el splash).
  final double brillo;

  @override
  Widget build(BuildContext context) {
    final sombras = brillo <= 0
        ? null
        : [
            Shadow(
              color: AppColores.rojo.withValues(alpha: 0.85 * brillo),
              blurRadius: tamano * 0.9 * brillo,
            ),
            Shadow(
              color: AppColores.rojo.withValues(alpha: 0.45 * brillo),
              blurRadius: tamano * 2 * brillo,
            ),
          ];
    final estilo = AppTexto.logo.copyWith(
      fontSize: tamano,
      letterSpacing: -tamano * 0.045,
      shadows: sombras,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'UDIT', style: estilo),
          TextSpan(
            text: 'flix',
            style: estilo.copyWith(color: AppColores.texto),
          ),
        ],
      ),
      semanticsLabel: 'UDITflix',
    );
  }
}

// La "U" de UDITflix, usada como icono compacto.
class IconoU extends StatelessWidget {
  const IconoU({super.key, this.tamano = 34});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Text(
      'U',
      semanticsLabel: 'UDITflix',
      style: AppTexto.logo.copyWith(
        fontSize: tamano,
        shadows: const [
          Shadow(color: AppColores.rojoOscuro, offset: Offset(1.5, 1.5)),
        ],
      ),
    );
  }
}
