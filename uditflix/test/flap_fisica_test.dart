// Tests de la lógica pura de UDIT Flap: física, dificultad y huecos.
// No arrancan Flame: solo comprueban los cálculos.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uditflix/games/flap/flap_fisica.dart';

void main() {
  group('Gravedad', () {
    test('acelera hacia abajo con el paso del tiempo', () {
      final v = FisicaFlap.aplicarGravedad(0, 0.1);
      expect(v, closeTo(FisicaFlap.gravedad * 0.1, 1e-9));
    });

    test('nunca supera la velocidad terminal', () {
      var v = 0.0;
      for (var i = 0; i < 600; i++) {
        v = FisicaFlap.aplicarGravedad(v, 1 / 60);
      }
      expect(v, FisicaFlap.velocidadTerminal);
    });

    test('tras un salto el personaje sube y luego vuelve a caer', () {
      var v = FisicaFlap.impulso;
      var y = 0.0;
      var alturaMinima = 0.0;
      for (var i = 0; i < 90; i++) {
        v = FisicaFlap.aplicarGravedad(v, 1 / 60);
        y += v / 60;
        alturaMinima = math.min(alturaMinima, y);
      }
      expect(alturaMinima, lessThan(0), reason: 'primero sube');
      expect(v, greaterThan(0), reason: 'al final está cayendo');
    });
  });

  group('Rotación', () {
    test('mira hacia arriba al subir', () {
      expect(FisicaFlap.rotacion(FisicaFlap.impulso), FisicaFlap.anguloSubida);
    });

    test('cae en picado a velocidad terminal', () {
      expect(
        FisicaFlap.rotacion(FisicaFlap.velocidadTerminal),
        closeTo(FisicaFlap.anguloPicado, 1e-9),
      );
    });

    test('se inclina más cuanto más rápido cae', () {
      expect(FisicaFlap.rotacion(400), greaterThan(FisicaFlap.rotacion(250)));
    });
  });

  group('Límites', () {
    test('detecta el choque con el techo y con el suelo', () {
      expect(
        FisicaFlap.fueraDeLimites(y: 5, radio: 10, techo: 0, suelo: 600),
        isTrue,
      );
      expect(
        FisicaFlap.fueraDeLimites(y: 595, radio: 10, techo: 0, suelo: 600),
        isTrue,
      );
      expect(
        FisicaFlap.fueraDeLimites(y: 300, radio: 10, techo: 0, suelo: 600),
        isFalse,
      );
    });
  });

  group('Dificultad', () {
    test('la velocidad sube con los puntos pero tiene tope', () {
      expect(
        DificultadFlap.velocidad(10),
        greaterThan(DificultadFlap.velocidad(0)),
      );
      expect(DificultadFlap.velocidad(1000), DificultadFlap.velocidad(500));
    });

    test('el hueco se estrecha pero nunca baja del mínimo', () {
      expect(DificultadFlap.hueco(10), lessThan(DificultadFlap.hueco(0)));
      expect(DificultadFlap.hueco(1000), 150);
    });
  });

  group('Centro del hueco', () {
    test('siempre deja el hueco completo dentro de los márgenes', () {
      final azar = math.Random(1);
      for (var i = 0; i < 500; i++) {
        final centro = centroHueco(
          azar01: azar.nextDouble(),
          alto: 600,
          hueco: 180,
          margen: 60,
        );
        expect(centro - 90, greaterThanOrEqualTo(60));
        expect(centro + 90, lessThanOrEqualTo(540));
      }
    });

    test('no cambia más de lo permitido respecto al anterior', () {
      final centro = centroHueco(
        azar01: 1,
        alto: 2000,
        hueco: 180,
        margen: 60,
        anterior: 300,
        cambioMaximo: 100,
      );
      expect(centro, lessThanOrEqualTo(400));
    });
  });
}
