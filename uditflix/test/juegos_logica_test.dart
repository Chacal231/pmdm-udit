// Tests de la lógica pura del resto del Arcade: geometría de colisiones,
// medallas, Neon Breaker y Galaxy Run.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uditflix/games/breaker/breaker_logica.dart';
import 'package:uditflix/games/comun/geometria.dart';
import 'package:uditflix/games/comun/medalla.dart';
import 'package:uditflix/games/galaxy/galaxy_logica.dart';

void main() {
  group('Geometría', () {
    test('círculo contra rectángulo', () {
      bool choca(double cx, double cy) => circuloChocaRect(
        cx: cx,
        cy: cy,
        radio: 10,
        izquierda: 0,
        arriba: 0,
        derecha: 100,
        abajo: 50,
      );
      expect(choca(50, 25), isTrue, reason: 'dentro');
      expect(choca(105, 25), isTrue, reason: 'roza el lateral');
      expect(choca(120, 25), isFalse, reason: 'lejos');
      expect(choca(108, 58), isFalse, reason: 'cerca de la esquina pero fuera');
    });

    test('círculo contra círculo', () {
      expect(
        circulosChocan(x1: 0, y1: 0, r1: 10, x2: 15, y2: 0, r2: 10),
        isTrue,
      );
      expect(
        circulosChocan(x1: 0, y1: 0, r1: 10, x2: 25, y2: 0, r2: 10),
        isFalse,
      );
    });
  });

  group('Medallas', () {
    test('se asignan por tramos de 10, 20, 30 y 50 puntos', () {
      expect(medallaPara(9), isNull);
      expect(medallaPara(10), Medalla.bronce);
      expect(medallaPara(25), Medalla.plata);
      expect(medallaPara(30), Medalla.oro);
      expect(medallaPara(49), Medalla.oro);
      expect(medallaPara(80), Medalla.platino);
    });
  });

  group('Neon Breaker', () {
    test('rebote en el centro de la pala: sale recta hacia arriba', () {
      final (vx, vy) = LogicaBreaker.reboteEnPala(0, 400);
      expect(vx, closeTo(0, 1e-9));
      expect(vy, closeTo(-400, 1e-9));
    });

    test('rebote en el borde: sale inclinada y mantiene la rapidez', () {
      final (vx, vy) = LogicaBreaker.reboteEnPala(1, 400);
      expect(vx, greaterThan(0));
      expect(vy, lessThan(0));
      expect(math.sqrt(vx * vx + vy * vy), closeTo(400, 1e-6));
    });

    test('el impacto relativo se limita a [-1, 1]', () {
      expect(LogicaBreaker.impactoRelativo(500, 100, 80), 1);
      expect(LogicaBreaker.impactoRelativo(100, 100, 80), 0);
    });

    test('eje de rebote según el lado del golpe', () {
      // Pelota entrando por el lateral izquierdo de un ladrillo ancho.
      expect(
        LogicaBreaker.ejeRebote(
          cx: -6,
          cy: 10,
          radio: 8,
          izquierda: 0,
          arriba: 0,
          derecha: 60,
          abajo: 20,
        ),
        EjeRebote.horizontal,
      );
      // Pelota entrando por debajo.
      expect(
        LogicaBreaker.ejeRebote(
          cx: 30,
          cy: 26,
          radio: 8,
          izquierda: 0,
          arriba: 0,
          derecha: 60,
          abajo: 20,
        ),
        EjeRebote.vertical,
      );
    });

    test(
      'todos los niveles tienen 7 columnas, ladrillos y resistencias válidas',
      () {
        for (var nivel = 1; nivel <= LogicaBreaker.nivelesTotales; nivel++) {
          final diseno = LogicaBreaker.disenoNivel(nivel);
          expect(diseno, isNotEmpty);
          var ladrillos = 0;
          for (final fila in diseno) {
            expect(fila.length, LogicaBreaker.columnas);
            for (final r in fila) {
              expect(r, inInclusiveRange(0, 3));
              if (r > 0) ladrillos++;
            }
          }
          expect(ladrillos, greaterThan(0), reason: 'nivel $nivel');
        }
      },
    );

    test('la pelota va más rápida en niveles superiores', () {
      expect(LogicaBreaker.rapidez(3), greaterThan(LogicaBreaker.rapidez(1)));
    });
  });

  group('Galaxy Run', () {
    test('las oleadas crecen en dificultad', () {
      final primera = LogicaGalaxy.oleada(1);
      final quinta = LogicaGalaxy.oleada(5);
      expect(quinta.enemigos, greaterThan(primera.enemigos));
      expect(quinta.velocidadEnemigo, greaterThan(primera.velocidadEnemigo));
      expect(quinta.intervalo, lessThan(primera.intervalo));
    });

    test('las oleadas tienen límites para seguir siendo jugables', () {
      final muyAlta = LogicaGalaxy.oleada(100);
      expect(muyAlta.enemigos, 26);
      expect(muyAlta.intervalo, 0.35);
      expect(muyAlta.velocidadEnemigo, 230);
      expect(muyAlta.probabilidadMeteorito, 0.45);
    });

    test('la cadencia de disparo mejora pero tiene un mínimo', () {
      expect(
        LogicaGalaxy.cadenciaDisparo(5),
        lessThan(LogicaGalaxy.cadenciaDisparo(1)),
      );
      expect(LogicaGalaxy.cadenciaDisparo(100), 0.13);
    });

    test('disparo doble desde la tercera oleada', () {
      expect(LogicaGalaxy.disparoDoble(2), isFalse);
      expect(LogicaGalaxy.disparoDoble(3), isTrue);
    });

    test('meteoritos grandes aguantan más y dan más puntos', () {
      expect(
        LogicaGalaxy.vidaMeteorito(28),
        greaterThan(LogicaGalaxy.vidaMeteorito(16)),
      );
      expect(
        LogicaGalaxy.puntosMeteorito(28),
        greaterThan(LogicaGalaxy.puntosMeteorito(16)),
      );
    });
  });
}
