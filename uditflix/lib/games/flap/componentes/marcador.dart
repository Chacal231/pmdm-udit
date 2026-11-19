// COMPONENTE PUNTUACIÓN

// Número grande en el centro superior. Cada vez que se suma un punto
// hace un "pop": crece rápido y vuelve a su tamaño con un ScaleEffect.

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class MarcadorFlap extends TextComponent with HasVisibility {
  MarcadorFlap() : super(text: '0', anchor: Anchor.center, priority: 30);

  ScaleEffect? _pop;

  void ajustar(double escala, Vector2 posicion) {
    position = posicion;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 64 * escala,
        fontWeight: FontWeight.w900,
        color: AppColores.texto,
        shadows: [
          Shadow(color: AppColores.neonMagenta, blurRadius: 14 * escala),
          Shadow(
            color: AppColores.sombra(0.6),
            offset: Offset(0, 3 * escala),
            blurRadius: 4 * escala,
          ),
        ],
      ),
    );
  }

  void mostrar(int puntos, {bool conPop = true}) {
    text = '$puntos';
    if (!conPop) return;
    // Si había un pop a medias lo quitamos y partimos del tamaño normal.
    _pop?.removeFromParent();
    scale = Vector2.all(1);
    add(
      _pop = ScaleEffect.to(
        Vector2.all(1.35),
        EffectController(
          duration: 0.07,
          reverseDuration: 0.16,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
