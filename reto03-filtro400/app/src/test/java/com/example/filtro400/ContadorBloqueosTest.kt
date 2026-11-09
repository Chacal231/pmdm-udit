package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Test

// Pruebas unitarias del texto del contador. No necesitan móvil ni emulador.
class ContadorBloqueosTest {

    @Test
    fun ceroMuestraQueNoHayNinguna() {
        assertEquals("Ninguna llamada bloqueada todavía", ContadorBloqueos.textoBloqueadas(0))
    }

    @Test
    fun unaUsaSingular() {
        assertEquals("1 llamada bloqueada", ContadorBloqueos.textoBloqueadas(1))
    }

    @Test
    fun variasUsanPlural() {
        assertEquals("2 llamadas bloqueadas", ContadorBloqueos.textoBloqueadas(2))
        assertEquals("150 llamadas bloqueadas", ContadorBloqueos.textoBloqueadas(150))
    }

    @Test
    fun negativoSeTrataComoCero() {
        assertEquals("Ninguna llamada bloqueada todavía", ContadorBloqueos.textoBloqueadas(-1))
    }
}
