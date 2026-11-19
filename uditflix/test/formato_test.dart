// Tests de las funciones de formato que usa el reproductor.

import 'package:flutter_test/flutter_test.dart';
import 'package:uditflix/utils/formato.dart';

void main() {
  test('formatea tiempos en mm:ss y h:mm:ss', () {
    expect(formatearTiempo(Duration.zero), '00:00');
    expect(formatearTiempo(const Duration(seconds: 75)), '01:15');
    expect(formatearTiempo(const Duration(seconds: 3725)), '1:02:05');
  });

  test('un tiempo negativo se muestra como cero', () {
    expect(formatearTiempo(const Duration(seconds: -3)), '00:00');
  });

  test('formatea la velocidad con coma decimal', () {
    expect(formatearVelocidad(1), '1×');
    expect(formatearVelocidad(2), '2×');
    expect(formatearVelocidad(0.5), '0,5×');
    expect(formatearVelocidad(1.25), '1,25×');
  });
}
