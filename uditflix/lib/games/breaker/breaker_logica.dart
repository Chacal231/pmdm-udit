// REGLAS DE NEON BREAKER (LÓGICA PURA)

// Reglas del juego que no dependen de cómo se dibuja: hacia dónde rebota
// la pelota, cómo son los niveles, cuántos puntos da cada ladrillo…
// Valores de velocidad y tamaño en unidades de referencia (pantalla de
// 400 de ancho); el juego los multiplica por su escala.

import 'dart:math' as math;

// Eje sobre el que rebota la pelota al chocar con un ladrillo.
enum EjeRebote {
  // Golpe por un lateral: se invierte la velocidad horizontal.
  horizontal,
  // Golpe por arriba o por abajo: se invierte la velocidad vertical.
  vertical,
}

abstract final class LogicaBreaker {
  static const double anchoReferencia = 400;
  static const int columnas = 7;
  static const int nivelesTotales = 5;
  static const int vidasIniciales = 3;
  // Ángulo máximo de salida respecto a la vertical (unos 60 grados).
  static const double anguloMaximo = 1.05;
  // Probabilidad de que un ladrillo roto suelte el power-up.
  static const double probabilidadPowerUp = 0.14;
  // Duración del power-up "pala ancha" en segundos.
  static const double duracionPalaAncha = 10;

  // Punto de impacto relativo en la pala: -1 (borde izquierdo),
  // 0 (centro) o 1 (borde derecho).
  static double impactoRelativo(
    double xPelota,
    double centroPala,
    double anchoPala,
  ) => ((xPelota - centroPala) / (anchoPala / 2)).clamp(-1.0, 1.0);

  // Velocidad de la pelota tras rebotar en la pala: cuanto más al borde
  // golpea, más inclinada sale. Así el jugador puede "apuntar".
  // Devuelve (vx, vy); vy siempre es negativa (hacia arriba).
  static (double, double) reboteEnPala(double impacto, double rapidez) {
    final angulo = impacto.clamp(-1.0, 1.0) * anguloMaximo;
    return (rapidez * math.sin(angulo), -rapidez * math.cos(angulo));
  }

  // Rapidez de la pelota en cada nivel (unidades/s).
  static double rapidez(int nivel) => 360 + (nivel - 1) * 35;

  static int puntosPorLadrillo(int resistencia) => resistencia * 10;

  // Bonificación al ganar: 100 puntos por cada vida que quede.
  static int bonusVictoria(int vidas) => vidas * 100;

  // Decide el eje de rebote según cuánto se "mete" la pelota en el
  // ladrillo por cada lado: el lado con menos penetración es el que tocó.
  static EjeRebote ejeRebote({
    required double cx,
    required double cy,
    required double radio,
    required double izquierda,
    required double arriba,
    required double derecha,
    required double abajo,
  }) {
    final penetracionX = math.min(
      cx + radio - izquierda,
      derecha - (cx - radio),
    );
    final penetracionY = math.min(cy + radio - arriba, abajo - (cy - radio));
    return penetracionX < penetracionY
        ? EjeRebote.horizontal
        : EjeRebote.vertical;
  }

  // Diseño de cada nivel: una matriz de filas × 7 columnas en la que cada
  // número es la resistencia del ladrillo (0 = hueco, 1-3 = golpes).
  static List<List<int>> disenoNivel(int nivel) {
    List<int> fila(int Function(int c) valor) => List.generate(columnas, valor);
    switch (nivel) {
      case 1:
        return [for (var f = 0; f < 4; f++) fila((_) => 1)];
      case 2:
        return [fila((_) => 2), for (var f = 0; f < 4; f++) fila((_) => 1)];
      case 3:
        // Tablero de ajedrez con una fila dura arriba.
        return [
          fila((_) => 3),
          for (var f = 0; f < 4; f++) fila((c) => (c + f).isEven ? 2 : 1),
        ];
      case 4:
        // Pirámide invertida con el centro reforzado.
        return [
          for (var f = 0; f < 5; f++)
            fila((c) {
              final distancia = (c - 3).abs();
              if (distancia > 3 - f ~/ 2) return 0;
              return distancia == 0 ? 3 : (f.isEven ? 2 : 1);
            }),
        ];
      default:
        // Último nivel: franjas alternas con huecos estratégicos.
        return [
          for (var f = 0; f < 6; f++)
            fila((c) {
              if (f == 2 && (c == 0 || c == 6)) return 0;
              return f.isEven ? 3 : 2;
            }),
        ];
    }
  }
}
