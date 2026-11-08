package com.example.filtro400

import com.example.filtro400.ui.theme.ModoTema
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

// Pruebas unitarias de ModoTema. No necesitan móvil ni emulador:
// el enum no usa nada de Android.
class ModoTemaTest {

    @Test
    fun sistemaSigueAlSistema() {
        assertTrue(ModoTema.SISTEMA.usaOscuro(sistemaOscuro = true))
        assertFalse(ModoTema.SISTEMA.usaOscuro(sistemaOscuro = false))
    }

    @Test
    fun claroIgnoraAlSistema() {
        assertFalse(ModoTema.CLARO.usaOscuro(sistemaOscuro = true))
        assertFalse(ModoTema.CLARO.usaOscuro(sistemaOscuro = false))
    }

    @Test
    fun oscuroIgnoraAlSistema() {
        assertTrue(ModoTema.OSCURO.usaOscuro(sistemaOscuro = true))
        assertTrue(ModoTema.OSCURO.usaOscuro(sistemaOscuro = false))
    }

    // Lo que se guarda (name) tiene que poder leerse de vuelta en todos los modos.
    @Test
    fun desdeNombreRecuperaCadaModoGuardado() {
        ModoTema.entries.forEach { modo ->
            assertEquals(modo, ModoTema.desdeNombre(modo.name))
        }
    }

    @Test
    fun sinValorGuardadoSigueAlSistema() {
        assertEquals(ModoTema.SISTEMA, ModoTema.desdeNombre(null))
    }

    @Test
    fun valorDesconocidoSigueAlSistema() {
        assertEquals(ModoTema.SISTEMA, ModoTema.desdeNombre("AZUL"))
    }
}
