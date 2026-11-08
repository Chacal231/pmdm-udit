package com.example.filtro400.ui.theme

// Las tres opciones del selector de tema. Es lógica pura, sin clases de Android,
// para poder comprobarla con tests unitarios sin móvil ni emulador.
enum class ModoTema(val etiqueta: String) {
    SISTEMA("Sistema"),
    CLARO("Claro"),
    OSCURO("Oscuro");

    // "sistemaOscuro" llega como parámetro porque leerlo depende de Android.
    fun usaOscuro(sistemaOscuro: Boolean): Boolean = when (this) {
        SISTEMA -> sistemaOscuro
        CLARO -> false
        OSCURO -> true
    }

    companion object {
        // Convierte lo guardado en SharedPreferences. Si no hay nada guardado o
        // el valor no se reconoce, seguimos al sistema en vez de fallar al abrir.
        fun desdeNombre(nombre: String?): ModoTema =
            entries.firstOrNull { it.name == nombre } ?: SISTEMA
    }
}
