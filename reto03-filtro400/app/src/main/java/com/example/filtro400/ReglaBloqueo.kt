package com.example.filtro400

// "object" = una única instancia, sin necesidad de crearla con ReglaBloqueo().
// Aquí vive la decisión de bloquear o no: sin Android, sin pantalla.
// Los prefijos llegan como parámetro (los lee la base de datos), así que
// esta clase es fácil de probar con tests unitarios.
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

    // Devuelve el prefijo que coincide con el número, o null si ninguno.
    // Número oculto (vacío) -> null: no se bloquea.
    fun prefijoCoincidente(numero: String, prefijos: List<String>): String? {
        val n = normalizar(numero)
        if (n.isEmpty()) return null
        return prefijos.firstOrNull { it.isNotEmpty() && n.startsWith(it) }
    }

    // Misma firma que antes: la usa el servicio de llamadas.
    fun debeBloquearse(numero: String, prefijos: List<String>): Boolean =
        prefijoCoincidente(numero, prefijos) != null
}