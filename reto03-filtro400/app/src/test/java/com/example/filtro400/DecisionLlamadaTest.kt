package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

// Pruebas del motor de decisión: lista blanca -> número concreto -> prefijo -> permitir.
class DecisionLlamadaTest {

    private fun decidir(
        numero: String,
        listaBlanca: List<String> = emptyList(),
        bloqueados: List<String> = emptyList(),
        prefijos: List<String> = emptyList()
    ) = ReglaBloqueo.decidir(numero, listaBlanca, bloqueados, prefijos)

    private val permitidaSinCoincidencia = ResultadoDecision(false, "Sin coincidencia")
    private val permitidaListaBlanca = ResultadoDecision(false, "Lista blanca")
    private val bloqueadaNumeroConcreto = ResultadoDecision(true, "Número concreto")

    // ---- Cada nivel del orden ----

    @Test
    fun listaBlancaPermite() {
        assertEquals(permitidaListaBlanca, decidir("400111222", listaBlanca = listOf("400111222")))
    }

    @Test
    fun numeroConcretoBloqueaSinPrefijoActivo() {
        assertEquals(bloqueadaNumeroConcreto, decidir("600123456", bloqueados = listOf("600123456")))
    }

    @Test
    fun prefijoBloqueaConSuMotivo() {
        assertEquals(
            ResultadoDecision(true, "Prefijo 400"),
            decidir("400123456", prefijos = listOf("400"))
        )
    }

    @Test
    fun sinCoincidenciaSePermite() {
        assertEquals(
            permitidaSinCoincidencia,
            decidir("600123456", listOf("700111222"), listOf("800111222"), listOf("400"))
        )
    }

    // ---- Prioridades ----

    @Test
    fun listaBlancaGanaAlNumeroConcreto() {
        assertEquals(
            permitidaListaBlanca,
            decidir("600123456", listaBlanca = listOf("600123456"), bloqueados = listOf("600123456"))
        )
    }

    @Test
    fun listaBlancaGanaAlPrefijo() {
        assertEquals(
            permitidaListaBlanca,
            decidir("400111222", listaBlanca = listOf("400111222"), prefijos = listOf("400"))
        )
    }

    @Test
    fun numeroConcretoGanaAlPrefijo() {
        assertEquals(
            bloqueadaNumeroConcreto,
            decidir("400111222", bloqueados = listOf("400111222"), prefijos = listOf("400"))
        )
    }

    // ---- Coincidencia exacta y formatos ----

    @Test
    fun listaBlancaNoSalvaAOtrosNumerosDelPrefijo() {
        assertTrue(
            decidir("400111223", listaBlanca = listOf("400111222"), prefijos = listOf("400")).bloquear
        )
    }

    @Test
    fun numeroConcretoNoAlcanzaAUnNumeroParecido() {
        assertFalse(decidir("600123457", bloqueados = listOf("600123456")).bloquear)
    }

    @Test
    fun formatosEspanolesCoincidenConElGuardado() {
        listOf("600123456", "+34600123456", "0034600123456", "+34 600 123 456").forEach {
            assertEquals(bloqueadaNumeroConcreto, decidir(it, bloqueados = listOf("600123456")))
            assertEquals(permitidaListaBlanca, decidir(it, listaBlanca = listOf("600123456")))
        }
    }

    @Test
    fun numeroGuardadoConPrefijoInternacionalTambienCoincide() {
        assertEquals(bloqueadaNumeroConcreto, decidir("600123456", bloqueados = listOf("+34600123456")))
    }

    @Test
    fun numeroExtranjeroGuardadoCoincide() {
        val guardado = ReglaBloqueo.limpiarNumero("+44 123 456 789")
        assertEquals(bloqueadaNumeroConcreto, decidir("+44123456789", bloqueados = listOf(guardado)))
    }

    // ---- Número oculto ----

    @Test
    fun numeroOcultoNuncaSeBloquea() {
        assertEquals(
            permitidaSinCoincidencia,
            decidir("", listOf("400111222"), listOf("600123456"), listOf("400"))
        )
    }

    @Test
    fun numeroOcultoNoCoincideConEntradasVacias() {
        assertEquals(permitidaSinCoincidencia, decidir("", bloqueados = listOf("")))
    }

    // ---- Privacidad y validación ----

    @Test
    fun ningunMotivoRevelaUnPrefijoLargo() {
        assertEquals(
            ResultadoDecision(true, "Prefijo 600***456"),
            decidir("600123456", prefijos = listOf("600123456"))
        )
    }

    @Test
    fun limpiarNumeroQuitaFormatoEspanolYSeparadores() {
        assertEquals("600123456", ReglaBloqueo.limpiarNumero("+34 600-123-456"))
        assertEquals("600123456", ReglaBloqueo.limpiarNumero("0034 600 123 456"))
    }

    @Test
    fun limpiarNumeroConservaElMasDeLosExtranjeros() {
        assertEquals("+44123456789", ReglaBloqueo.limpiarNumero("+44 123 456 789"))
    }

    @Test
    fun entradasSinCifrasSuficientesNoSonValidas() {
        listOf("", "+", "+34", "0034", "12", "abc", "+34 12").forEach {
            assertFalse("\"$it\" no debería ser válido", ReglaBloqueo.esNumeroValido(it))
        }
    }

    @Test
    fun entradasConTresCifrasOMasSonValidas() {
        listOf("123", "+34 600", "600123456", "+44123456789").forEach {
            assertTrue("\"$it\" debería ser válido", ReglaBloqueo.esNumeroValido(it))
        }
    }

    @Test
    fun tipoNumeroDesconocidoNuncaBloquea() {
        assertEquals(TipoNumero.BLOQUEADO, TipoNumero.desdeNombre("BLOQUEADO"))
        assertEquals(TipoNumero.LISTA_BLANCA, TipoNumero.desdeNombre("otra cosa"))
        assertEquals(TipoNumero.LISTA_BLANCA, TipoNumero.desdeNombre(null))
    }
}
