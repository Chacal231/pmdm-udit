// Tests del almacenamiento local: Mi lista, Continuar viendo y récords.
// SharedPreferences.setMockInitialValues simula el almacén del móvil en
// memoria, así cada test empieza "limpio".

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uditflix/services/almacen_local.dart';

void main() {
  // Crea un almacén nuevo a partir de unos valores guardados.
  Future<AlmacenLocal> almacenCon(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final almacen = AlmacenLocal();
    await almacen.iniciar();
    return almacen;
  }

  group('Mi lista', () {
    test('añade y quita al alternar', () async {
      final almacen = await almacenCon({});
      expect(await almacen.alternarMiLista(7), isTrue);
      expect(almacen.estaEnMiLista(7), isTrue);
      expect(await almacen.alternarMiLista(7), isFalse);
      expect(almacen.estaEnMiLista(7), isFalse);
    });

    test('el último añadido aparece primero', () async {
      final almacen = await almacenCon({});
      await almacen.alternarMiLista(1);
      await almacen.alternarMiLista(2);
      await almacen.alternarMiLista(3);
      expect(almacen.miLista, [3, 2, 1]);
    });

    test('se conserva al volver a abrir la app', () async {
      final primero = await almacenCon({});
      await primero.alternarMiLista(5);
      // Una instancia nueva lee lo que guardó la anterior.
      final segundo = AlmacenLocal();
      await segundo.iniciar();
      expect(segundo.estaEnMiLista(5), isTrue);
    });

    test('avisa a quien escucha cuando cambia', () async {
      final almacen = await almacenCon({});
      var avisos = 0;
      almacen.addListener(() => avisos++);
      await almacen.alternarMiLista(9);
      expect(avisos, greaterThan(0));
    });
  });

  group('Continuar viendo', () {
    test('guarda la posición y calcula la fracción vista', () async {
      final almacen = await almacenCon({});
      await almacen.guardarProgreso(4, segundos: 150, duracionTotal: 600);
      final progreso = almacen.progresoDe(4)!;
      expect(progreso.segundos, 150);
      expect(progreso.fraccion, closeTo(0.25, 1e-9));
    });

    test('ordena del más reciente al más antiguo y permite borrar', () async {
      final almacen = await almacenCon({});
      await almacen.guardarProgreso(1, segundos: 10, duracionTotal: 100);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await almacen.guardarProgreso(2, segundos: 20, duracionTotal: 100);
      expect(almacen.continuarViendo.map((p) => p.idContenido), [2, 1]);
      await almacen.borrarProgreso(2);
      expect(almacen.progresoDe(2), isNull);
    });

    test('un dato guardado corrupto no rompe la app', () async {
      final almacen = await almacenCon({'continuar_viendo': 'esto no es JSON'});
      expect(almacen.continuarViendo, isEmpty);
    });
  });

  group('Récords', () {
    test('empiezan en 0 y solo suben', () async {
      final almacen = await almacenCon({});
      expect(almacen.recordDe('flap'), 0);
      expect(await almacen.registrarPuntuacion('flap', 12), isTrue);
      expect(await almacen.registrarPuntuacion('flap', 8), isFalse);
      expect(almacen.recordDe('flap'), 12);
    });

    test('cada juego tiene su propio récord', () async {
      final almacen = await almacenCon({});
      await almacen.registrarPuntuacion('flap', 30);
      await almacen.registrarPuntuacion('galaxy', 900);
      expect(almacen.recordDe('flap'), 30);
      expect(almacen.recordDe('galaxy'), 900);
      expect(almacen.recordDe('breaker'), 0);
    });
  });
}
