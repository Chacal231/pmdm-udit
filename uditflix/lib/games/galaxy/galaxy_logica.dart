// REGLAS DE GALAXY RUN (LÓGICA PURA)

// Cómo se componen las oleadas, a qué ritmo dispara la nave y cuántos
// puntos da cada objetivo. Velocidades en unidades de referencia (pantalla
// de 400 de ancho); el juego las multiplica por su escala.

import 'dart:math' as math;

// Configuración de una oleada de enemigos.
class ConfigOleada {
  const ConfigOleada({
    required this.enemigos,
    required this.intervalo,
    required this.velocidadEnemigo,
    required this.probabilidadMeteorito,
    required this.vidaEnemigo,
  });

  // Número total de objetivos que aparecen en la oleada.
  final int enemigos;
  // Segundos (aproximados) entre la aparición de uno y el siguiente.
  final double intervalo;
  // Velocidad de bajada de las naves enemigas.
  final double velocidadEnemigo;
  // Probabilidad de que un objetivo sea un meteorito en vez de una nave.
  final double probabilidadMeteorito;
  // Disparos que aguanta cada nave enemiga.
  final int vidaEnemigo;
}

abstract final class LogicaGalaxy {
  static const double anchoReferencia = 400;
  static const int vidasIniciales = 3;
  // Segundos de invulnerabilidad (la nave parpadea) tras recibir un golpe.
  static const double invulnerabilidad = 1.6;
  static const int puntosEnemigo = 25;
  static const double velocidadLaser = 620;

  // Cada oleada es un poco más larga, rápida y con más meteoritos,
  // siempre con un tope para que siga siendo jugable.
  static ConfigOleada oleada(int numero) {
    final n = math.max(1, numero);
    return ConfigOleada(
      enemigos: math.min(6 + n * 2, 26),
      intervalo: math.max(0.35, 0.95 - n * 0.07),
      velocidadEnemigo: math.min(90 + n * 14, 230),
      probabilidadMeteorito: math.min(0.15 + n * 0.04, 0.45),
      vidaEnemigo: n >= 4 ? 2 : 1,
    );
  }

  // Segundos entre disparos automáticos (cada vez más rápido).
  static double cadenciaDisparo(int oleada) =>
      math.max(0.13, 0.26 - oleada * 0.015);

  // A partir de la tercera oleada la nave dispara doble.
  static bool disparoDoble(int oleada) => oleada >= 3;

  // Bonificación por superar una oleada.
  static int bonusOleada(int oleada) => oleada * 50;

  // Los meteoritos grandes aguantan más y dan más puntos.
  static int vidaMeteorito(double radioReferencia) =>
      radioReferencia > 24 ? 3 : 2;
  static int puntosMeteorito(double radioReferencia) =>
      (radioReferencia * 1.5).round();
}
