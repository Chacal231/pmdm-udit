// MEDALLAS (LÓGICA PURA)

// Al terminar una partida de UDIT Flap se gana una medalla según los
// puntos conseguidos: bronce (10), plata (20), oro (30) y platino (50).

enum Medalla {
  bronce('Bronce', 10),
  plata('Plata', 20),
  oro('Oro', 30),
  platino('Platino', 50);

  const Medalla(this.nombre, this.puntosNecesarios);

  final String nombre;
  final int puntosNecesarios;
}

// Devuelve la mejor medalla alcanzada, o null si no llega a bronce.
Medalla? medallaPara(int puntos) {
  Medalla? mejor;
  for (final medalla in Medalla.values) {
    if (puntos >= medalla.puntosNecesarios) mejor = medalla;
  }
  return mejor;
}
