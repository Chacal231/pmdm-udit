// FUNCIONES DE FORMATO

// Pequeñas funciones puras (sin Flutter) para mostrar datos al usuario.
// Al no depender de nada, se pueden probar fácilmente con tests unitarios.

// Convierte una duración en texto "mm:ss" o "h:mm:ss" si pasa de una hora.
// Ejemplos: 75 s → "01:15"; 3725 s → "1:02:05".
String formatearTiempo(Duration duracion) {
  final total = duracion.isNegative ? Duration.zero : duracion;
  String dosCifras(int n) => n.toString().padLeft(2, '0');
  final horas = total.inHours;
  final minutos = dosCifras(total.inMinutes.remainder(60));
  final segundos = dosCifras(total.inSeconds.remainder(60));
  return horas > 0 ? '$horas:$minutos:$segundos' : '$minutos:$segundos';
}

// Velocidad de reproducción en formato español: 1 → "1×", 1.25 → "1,25×".
String formatearVelocidad(double velocidad) {
  final texto = velocidad == velocidad.roundToDouble()
      ? velocidad.toInt().toString()
      : velocidad.toString().replaceAll('.', ',');
  return '$texto×';
}
