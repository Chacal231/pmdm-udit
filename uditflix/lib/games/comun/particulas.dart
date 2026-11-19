// PARTÍCULAS COMPARTIDAS

// Pequeñas explosiones de puntos de colores que salen disparados en
// todas direcciones y se desvanecen. Las usan los tres juegos: al saltar
// y chocar en UDIT Flap, al romper ladrillos en Neon Breaker y al
// destruir naves en Galaxy Run.

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

final math.Random _azar = math.Random();

// Crea un componente de partículas listo para añadir al juego.
//   - posicion: dónde ocurre la explosión.
//   - colores: se reparten entre las partículas.
//   - velocidad: rapidez máxima con la que salen (píxeles/segundo).
//   - gravedad: aceleración hacia abajo (0 en el espacio).
//   - direccion/apertura: si se indican, las partículas salen en un cono
//     (por ejemplo, hacia atrás al saltar) en lugar de en círculo.
ParticleSystemComponent explosion({
  required Vector2 posicion,
  required List<Color> colores,
  int cantidad = 24,
  double velocidad = 220,
  double radio = 3,
  double duracion = 0.7,
  double gravedad = 0,
  double? direccion,
  double apertura = math.pi * 2,
  int prioridad = 50,
}) {
  return ParticleSystemComponent(
    position: posicion.clone(),
    priority: prioridad,
    particle: Particle.generate(
      count: cantidad,
      lifespan: duracion,
      generator: (i) {
        final angulo = direccion == null
            ? _azar.nextDouble() * math.pi * 2
            : direccion + (_azar.nextDouble() - 0.5) * apertura;
        final rapidez = velocidad * (0.35 + _azar.nextDouble() * 0.65);
        final color = colores[i % colores.length];
        final tamano = radio * (0.6 + _azar.nextDouble() * 0.8);
        final pincel = Paint();
        return AcceleratedParticle(
          speed: Vector2(math.cos(angulo), math.sin(angulo)) * rapidez,
          acceleration: Vector2(0, gravedad),
          // ComputedParticle nos deja dibujar la partícula a mano:
          // se encoge y se vuelve transparente según avanza su vida.
          child: ComputedParticle(
            renderer: (canvas, particula) {
              final t = particula.progress;
              pincel.color = color.withValues(alpha: 1 - t);
              canvas.drawCircle(Offset.zero, tamano * (1 - t * 0.6), pincel);
            },
          ),
        );
      },
    ),
  );
}
