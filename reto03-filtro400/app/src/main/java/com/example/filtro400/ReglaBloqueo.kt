package com.example.filtro400

// "object" = una única instancia, sin necesidad de crearla con ReglaBloqueo().
// Aquí vive la decisión de bloquear o no: sin Android, sin pantalla.
// Fase 2: los prefijos ya no están escritos en el código, llegan como parámetro
// (los lee la base de datos). Así esta clase sigue siendo fácil de probar.
object ReglaBloqueo {

    // Un mismo número puede llegar de varias formas:
    // "400123456", "+34400123456", "0034 400 123 456", "+34 400 123 456"...
    // Lo dejamos siempre en el mismo formato antes de comparar.
    fun normalizar(numero: String): String {
        // Nos quedamos solo con dígitos y el signo "+" (fuera espacios y guiones).
        val limpio = numero.filter { it.isDigit() || it == '+' }
        return when {
            limpio.startsWith("+34") -> limpio.removePrefix("+34")
            limpio.startsWith("0034") -> limpio.removePrefix("0034")
            else -> limpio
        }
    }

    // Limpia el prefijo que escribe el usuario: solo dígitos (admite "+34 400").
    fun limpiarPrefijo(texto: String): String =
        normalizar(texto).filter { it.isDigit() }

    // La regla de la Fase 2: bloquear si el número empieza por ALGUNO de los
    // prefijos activos. Número oculto (vacío) -> no se bloquea.
    fun debeBloquearse(numero: String, prefijos: List<String>): Boolean {
        val n = normalizar(numero)
        return n.isNotEmpty() && prefijos.any { it.isNotEmpty() && n.startsWith(it) }
    }
}