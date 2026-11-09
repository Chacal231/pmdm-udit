package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

// Pruebas unitarias del registro. Lo más importante que vigilan es la privacidad:
// ninguna entrada puede contener un número de teléfono completo.
class ActividadTest {

    private val fecha = 1_700_000_000_000L

    private fun crear(
        numero: String,
        bloqueada: Boolean = true,
        motivo: String = "Prefijo 400"
    ) = RegistroActividad.crear(numero, bloqueada, motivo, fecha)

    @Test
    fun enmascaraElNumeroEnTodosLosFormatos() {
        listOf("400123456", "+34400123456", "0034400123456", "+34 400 123 456").forEach {
            assertEquals("400***456", crear(it).numeroEnmascarado)
        }
    }

    // toString() de un data class incluye todos los campos: si el número estuviera
    // en cualquiera de ellos, aparecería aquí.
    @Test
    fun ningunaEntradaContieneElNumeroCompleto() {
        listOf("400123456", "+34400123456", "0034400123456").forEach { numero ->
            val texto = crear(numero).toString()
            assertFalse(texto, texto.contains("400123456"))
        }
    }

    @Test
    fun unNumeroIgualAlPrefijoLargoNoSeFiltraPorElMotivo() {
        val texto = crear("+34600123456", motivo = RegistroActividad.motivoPrefijo("600123456"))
            .toString()
        assertFalse(texto, texto.contains("600123456"))
    }

    @Test
    fun unNumeroIgualAlPrefijoCortoNoSeFiltraPorElMotivo() {
        val entrada = crear("400", motivo = RegistroActividad.motivoPrefijo("400"))
        assertEquals("***", entrada.numeroEnmascarado)
        assertEquals("Prefijo ***", entrada.motivo)
    }

    @Test
    fun numeroOcultoQuedaEnmascaradoYNoAlteraElMotivo() {
        val entrada = crear("", bloqueada = false, motivo = RegistroActividad.MOTIVO_SIN_COINCIDENCIA)
        assertEquals("***", entrada.numeroEnmascarado)
        assertEquals(DecisionLlamada.PERMITIDA, entrada.decision)
        assertEquals("Sin coincidencia", entrada.motivo)
    }

    @Test
    fun motivoConPrefijoCortoSeMuestraEntero() {
        assertEquals("Prefijo 400", RegistroActividad.motivoPrefijo("400"))
        assertEquals("Prefijo 91", RegistroActividad.motivoPrefijo("91"))
    }

    @Test
    fun motivoConPrefijoLargoSeEnmascara() {
        assertEquals("Prefijo 600***", RegistroActividad.motivoPrefijo("6001"))
        assertEquals("Prefijo 123***", RegistroActividad.motivoPrefijo("123456"))
        assertEquals("Prefijo 600***", RegistroActividad.motivoPrefijo("600123456"))
    }

    // Las cifras centrales (123) son justo las que oculta la máscara: no pueden
    // aparecer en ningún campo, o la fila permitiría reconstruir el número.
    @Test
    fun prefijoDeSeisCifrasYMascaraJuntosNoRevelanElNumero() {
        val entrada = crear("600123456", motivo = RegistroActividad.motivoPrefijo("600123"))
        assertEquals("600***456", entrada.numeroEnmascarado)
        assertEquals("Prefijo 600***", entrada.motivo)
        val juntos = "${entrada.numeroEnmascarado} ${entrada.motivo}"
        assertFalse(juntos, juntos.contains("123"))
    }

    @Test
    fun conservaLaDecisionLaFechaYElMotivo() {
        val entrada = crear("400123456", bloqueada = true, motivo = "Prefijo 400")
        assertEquals(DecisionLlamada.BLOQUEADA, entrada.decision)
        assertEquals(fecha, entrada.fecha)
        assertEquals("Prefijo 400", entrada.motivo)
    }

    @Test
    fun decisionDesdeNombreReconoceLoGuardado() {
        assertEquals(DecisionLlamada.BLOQUEADA, DecisionLlamada.desdeNombre("BLOQUEADA"))
        assertEquals(DecisionLlamada.PERMITIDA, DecisionLlamada.desdeNombre("PERMITIDA"))
    }

    @Test
    fun decisionDesconocidaNoHaceFallar() {
        assertEquals(DecisionLlamada.PERMITIDA, DecisionLlamada.desdeNombre("otra cosa"))
        assertEquals(DecisionLlamada.PERMITIDA, DecisionLlamada.desdeNombre(null))
    }
}
