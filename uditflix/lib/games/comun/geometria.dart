// GEOMETRÍA DE COLISIONES (LÓGICA PURA)

// Funciones matemáticas que comparten los tres juegos para saber si dos
// figuras se tocan. No dependen de Flame ni de Flutter: solo reciben
// números y devuelven true o false. Por eso se pueden probar con tests
// unitarios normales, sin arrancar ningún juego.

// ¿Un círculo (centro cx, cy y radio) toca un rectángulo?
// Truco: buscamos el punto del rectángulo más cercano al centro del
// círculo; si está a menos distancia que el radio, se tocan.
bool circuloChocaRect({
  required double cx,
  required double cy,
  required double radio,
  required double izquierda,
  required double arriba,
  required double derecha,
  required double abajo,
}) {
  final masCercanoX = cx.clamp(izquierda, derecha);
  final masCercanoY = cy.clamp(arriba, abajo);
  final dx = cx - masCercanoX;
  final dy = cy - masCercanoY;
  return dx * dx + dy * dy < radio * radio;
}

// ¿Dos círculos se tocan? Comparamos distancias al cuadrado para no
// tener que calcular raíces cuadradas (es más rápido).
bool circulosChocan({
  required double x1,
  required double y1,
  required double r1,
  required double x2,
  required double y2,
  required double r2,
}) {
  final dx = x1 - x2;
  final dy = y1 - y2;
  final suma = r1 + r2;
  return dx * dx + dy * dy < suma * suma;
}
