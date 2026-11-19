// MODELO PROGRESO DE VISIONADO

// Guarda por dónde se quedó el usuario viendo un contenido.
// Lo usa la fila "Continuar viendo" (barra roja de progreso) y el
// reproductor para ofrecer "Reanudar desde mm:ss".

class ProgresoVisionado {
  // Identificador del Contenido al que pertenece este progreso.
  final int idContenido;
  // Segundo exacto en el que se pausó o se salió del vídeo.
  final int segundos;
  // Duración total del vídeo en segundos.
  final int duracionTotal;
  // Momento de la última actualización (para ordenar la fila).
  final DateTime actualizado;

  const ProgresoVisionado({
    required this.idContenido,
    required this.segundos,
    required this.duracionTotal,
    required this.actualizado,
  });

  // Porcentaje visto entre 0.0 y 1.0, listo para una barra de progreso.
  double get fraccion =>
      duracionTotal <= 0 ? 0 : (segundos / duracionTotal).clamp(0.0, 1.0);

  // Conversión a mapa para guardarlo como JSON en shared_preferences.
  Map<String, Object> toJson() => {
    'id': idContenido,
    's': segundos,
    'd': duracionTotal,
    't': actualizado.millisecondsSinceEpoch,
  };

  // Reconstruye el objeto a partir del JSON guardado.
  factory ProgresoVisionado.fromJson(Map<String, dynamic> json) {
    return ProgresoVisionado(
      idContenido: json['id'] as int,
      segundos: json['s'] as int,
      duracionTotal: json['d'] as int,
      actualizado: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
    );
  }
}
