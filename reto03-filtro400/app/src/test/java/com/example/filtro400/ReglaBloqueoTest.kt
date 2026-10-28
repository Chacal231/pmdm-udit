package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

// Pruebas unitarias de ReglaBloqueo. No necesitan móvil ni emulador:
// ReglaBloqueo no usa nada de Android.
class ReglaBloqueoTest {

    private val prefijos = listOf("400")

    @Test
    fun bloqueaNumeroSinPrefijoDePais() {
        assertTrue(ReglaBloqueo.debeBloquearse("400123456", prefijos))
    }

    @Test
    fun bloqueaNumeroConMasTreintaYCuatro() {
        assertTrue(ReglaBloqueo.debeBloquearse("+34400123456", prefijos))
    }

    @Test
    fun bloqueaNumeroConCerosCeroTreintaYCuatro() {
        assertTrue(ReglaBloqueo.debeBloquearse("0034400123456", prefijos))
    }

    @Test
    fun bloqueaNumeroConEspaciosYGuiones() {
        assertTrue(ReglaBloqueo.debeBloquearse("+34 400-123 456", prefijos))
        assertTrue(ReglaBloqueo.debeBloquearse("0034 400 123 456", prefijos))
    }

    @Test
    fun noBloqueaNumeroConOtroPrefijo() {
        assertFalse(ReglaBloqueo.debeBloquearse("600123456", prefijos))
    }

    @Test
    fun noBloqueaNumeroDeOtroPais() {
        // "+44" no se quita, así que no empieza por 400.
        assertFalse(ReglaBloqueo.debeBloquearse("+44400123456", prefijos))
    }

    @Test
    fun noBloqueaNumeroVacioOOculto() {
        assertFalse(ReglaBloqueo.debeBloquearse("", prefijos))
    }

    @Test
    fun noBloqueaSiNoHayPrefijosActivos() {
        assertFalse(ReglaBloqueo.debeBloquearse("400123456", emptyList()))
    }

    @Test
    fun ignoraPrefijosVacios() {
        assertFalse(ReglaBloqueo.debeBloquearse("123456789", listOf("")))
    }

    @Test
    fun funcionaConVariosPrefijosActivos() {
        val varios = listOf("400", "800", "902")
        assertTrue(ReglaBloqueo.debeBloquearse("+34 800 111 222", varios))
        assertTrue(ReglaBloqueo.debeBloquearse("902123456", varios))
        assertFalse(ReglaBloqueo.debeBloquearse("700123456", varios))
    }

    @Test
    fun limpiarPrefijoQuitaPrefijoDePaisYSimbolos() {
        assertEquals("400", ReglaBloqueo.limpiarPrefijo("+34 400"))
        assertEquals("800", ReglaBloqueo.limpiarPrefijo(" 8-0 0 "))
        assertEquals("", ReglaBloqueo.limpiarPrefijo("abc"))
    }

    @Test
    fun prefijoCoincidenteDevuelveElPrefijoCorrecto() {
        val varios = listOf("400", "800")
        assertEquals("800", ReglaBloqueo.prefijoCoincidente("+34800123456", varios))
        assertEquals("400", ReglaBloqueo.prefijoCoincidente("400999999", varios))
    }

    @Test
    fun prefijoCoincidenteDevuelveNullSiNoHayCoincidencia() {
        assertNull(ReglaBloqueo.prefijoCoincidente("600123456", listOf("400", "800")))
        assertNull(ReglaBloqueo.prefijoCoincidente("", listOf("400")))
    }

    @Test
    fun normalizarDejaElNumeroEnUnSoloFormato() {
        assertEquals("400123456", ReglaBloqueo.normalizar("+34 400 123 456"))
        assertEquals("400123456", ReglaBloqueo.normalizar("0034-400-123-456"))
        assertEquals("400123456", ReglaBloqueo.normalizar("400123456"))
    }
}