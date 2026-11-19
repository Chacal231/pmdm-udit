// FÍSICA Y REGLAS DE UDIT FLAP (LÓGICA PURA)

// Aquí están los números que hacen que el juego "se sienta bien":
// gravedad, impulso del salto, velocidad máxima de caída, inclinación
// del personaje y cómo sube la dificultad.
//
// Todo se expresa en "unidades de referencia": una pantalla de 720 de
// alto. El juego multiplica por una escala (alto real / 720) para que se
// juegue igual en un móvil pequeño que en uno grande.
//
// No importa Flame ni Flutter, así que se prueba con tests unitarios.

import 'dart:math' as math;

abstract final class FisicaFlap {
  // Alto de la pantalla de referencia.
  static const double altoReferencia = 720;
  // Aceleración hacia abajo (unidades/s²).
  static const double gravedad = 1650;
  // Velocidad vertical justo después de tocar (negativa = hacia arriba).
  static const double impulso = -470;
  // Velocidad máxima de caída: sin ella el personaje caería como una piedra.
  static const double velocidadTerminal = 760;
  // Inclinación al subir (morro hacia arriba) y máxima al caer (en picado).
  static const double anguloSubida = -0.42;
  static const double anguloPicado = 1.45;
  // Velocidad de caída a partir de la cual empieza a inclinarse hacia abajo.
  static const double umbralPicado = 180;

  // Nueva velocidad tras aplicar la gravedad durante dt segundos,
  // sin superar nunca la velocidad terminal.
  static double aplicarGravedad(double velocidad, double dt) =>
      math.min(velocidad + gravedad * dt, velocidadTerminal);

  // Ángulo objetivo según la velocidad: mira hacia arriba al subir y al
  // principio de la caída; luego se va inclinando hasta caer en picado.
  static double rotacion(double velocidad) {
    if (velocidad <= umbralPicado) return anguloSubida;
    final t = ((velocidad - umbralPicado) / (velocidadTerminal - umbralPicado))
        .clamp(0.0, 1.0);
    return anguloSubida + (anguloPicado - anguloSubida) * t;
  }

  // ¿El personaje toca el techo o el suelo?
  static bool fueraDeLimites({
    required double y,
    required double radio,
    required double techo,
    required double suelo,
  }) => y - radio <= techo || y + radio >= suelo;
}

// La dificultad sube poco a poco con la puntuación y tiene un límite,
// para que el juego sea exigente pero nunca imposible.
abstract final class DificultadFlap {
  // Velocidad de las columnas (unidades/s).
  static double velocidad(int puntos) => math.min(165 + puntos * 3.5, 285);

  // Tamaño del hueco entre la columna de arriba y la de abajo.
  static double hueco(int puntos) => math.max(205 - puntos * 2.5, 150);

  // Distancia horizontal entre una pareja de columnas y la siguiente.
  static double separacion(int puntos) => math.max(250 - puntos * 1.5, 215);

  // Cuánto puede cambiar la altura del hueco de una columna a la
  // siguiente: así nunca aparece un salto imposible de alcanzar.
  static const double cambioMaximo = 230;
}

// Elige el centro del hueco dentro de unos márgenes seguros.
//   - azar01: número aleatorio entre 0 y 1.
//   - alto: altura jugable (desde el techo hasta el suelo).
//   - margen: distancia mínima del hueco al techo y al suelo.
//   - anterior: centro del hueco anterior, si lo hay.
double centroHueco({
  required double azar01,
  required double alto,
  required double hueco,
  required double margen,
  double? anterior,
  double cambioMaximo = DificultadFlap.cambioMaximo,
}) {
  var minimo = margen + hueco / 2;
  var maximo = alto - margen - hueco / 2;
  if (anterior != null) {
    minimo = math.max(minimo, anterior - cambioMaximo);
    maximo = math.min(maximo, anterior + cambioMaximo);
  }
  if (maximo <= minimo) return (minimo + maximo) / 2;
  return minimo + (maximo - minimo) * azar01.clamp(0.0, 1.0);
}
