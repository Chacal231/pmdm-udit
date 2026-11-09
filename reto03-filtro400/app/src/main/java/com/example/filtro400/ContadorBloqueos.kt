package com.example.filtro400

// Lógica pura, sin Android: así el texto se puede comprobar con tests unitarios.
object ContadorBloqueos {

    // El singular y el plural se tratan aparte para no mostrar "1 llamadas".
    // Un valor negativo no debería darse; si ocurriera, se trata como cero.
    fun textoBloqueadas(n: Int): String = when {
        n <= 0 -> "Ninguna llamada bloqueada todavía"
        n == 1 -> "1 llamada bloqueada"
        else -> "$n llamadas bloqueadas"
    }
}
