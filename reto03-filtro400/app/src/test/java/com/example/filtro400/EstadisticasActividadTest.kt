package com.example.filtro400

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime

// Pruebas de la tarjeta Resumen. El momento y la zona se fijan a mano para que el
// resultado no dependa del día ni del móvil en que se ejecuten.
class EstadisticasActividadTest {

    private val madrid = ZoneId.of("Europe/Madrid")

    private fun momento(
        mes: Int,
        dia: Int,
        hora: Int = 12,
        minuto: Int = 0,
        segundo: Int = 0,
        nanos: Int = 0
    ): Long = ZonedDateTime.of(2026, mes, dia, hora, minuto, segundo, nanos, madrid)
        .toInstant().toEpochMilli()

    private val ahora = momento(11, 9)

    private fun bloqueada(fecha: Long = ahora, motivo: String = "Prefijo 400") =
        EntradaActividad(
            fecha = fecha,
            numeroEnmascarado = "400***456",
            decision = DecisionLlamada.BLOQUEADA,
            motivo = motivo
        )

    private fun permitida(fecha: Long = ahora, motivo: String = "Sin coincidencia") =
        EntradaActividad(
            fecha = fecha,
            numeroEnmascarado = "600***456",
            decision = DecisionLlamada.PERMITIDA,
            motivo = motivo
        )

    private fun calcular(vararg entradas: EntradaActividad, instante: Long = ahora) =
        EstadisticasActividad.calcular(entradas.toList(), instante, madrid)

    @Test
    fun registroVacioDaCeroSinDividirPorCero() {
        assertEquals(ResumenActividad(0, 0, 0, 0, 0, null), calcular())
    }

    @Test
    fun dosBloqueadasYUnaPermitida() {
        assertEquals(
            ResumenActividad(2, 2, 2, 3, 67, "Prefijo 400"),
            calcular(bloqueada(), bloqueada(), permitida())
        )
    }

    @Test
    fun lasPermitidasNoCuentanComoBloqueadas() {
        val resumen = calcular(permitida(), permitida())
        assertEquals(0, resumen.bloqueadasHoy)
        assertEquals(0, resumen.bloqueadasSemana)
        assertEquals(0, resumen.bloqueadasRegistro)
        assertEquals(2, resumen.totalRegistro)
        assertEquals(0, resumen.porcentajeBloqueado)
    }

    @Test
    fun porcentajeSeRedondea() {
        assertEquals(33, calcular(bloqueada(), permitida(), permitida()).porcentajeBloqueado)
        assertEquals(100, calcular(bloqueada()).porcentajeBloqueado)
    }

    // ---- Límite de medianoche ----

    @Test
    fun laMedianocheDeHoyCuentaComoHoy() {
        assertEquals(1, calcular(bloqueada(momento(11, 9, hora = 0))).bloqueadasHoy)
    }

    @Test
    fun elUltimoInstanteDeAyerNoEsHoyPeroSiEsSemana() {
        val resumen = calcular(bloqueada(momento(11, 8, 23, 59, 59, 999_000_000)))
        assertEquals(0, resumen.bloqueadasHoy)
        assertEquals(1, resumen.bloqueadasSemana)
    }

    @Test
    fun elDiaDependeDeLaZonaHoraria() {
        // 00:30 del día 9 en Madrid son las 23:30 del día 8 en UTC.
        val entradas = listOf(bloqueada(momento(11, 9, 0, 30)))
        assertEquals(1, EstadisticasActividad.calcular(entradas, ahora, madrid).bloqueadasHoy)
        assertEquals(0, EstadisticasActividad.calcular(entradas, ahora, ZoneOffset.UTC).bloqueadasHoy)
    }

    // ---- Ventana de 7 días ----

    @Test
    fun laVentanaIncluyeElSextoDiaAnterior() {
        assertEquals(1, calcular(bloqueada(momento(11, 3, hora = 0))).bloqueadasSemana)
    }

    @Test
    fun laVentanaExcluyeElSeptimoDiaAnteriorPeroSigueEnElRegistro() {
        val resumen = calcular(bloqueada(momento(11, 2, 23, 59, 59)))
        assertEquals(0, resumen.bloqueadasSemana)
        assertEquals(1, resumen.bloqueadasRegistro)
    }

    @Test
    fun laVentanaRespetaElCambioDeHora() {
        // El 29 de marzo de 2026 dura 23 horas en Madrid.
        val resumen = calcular(bloqueada(momento(3, 24, hora = 0)), instante = momento(3, 30))
        assertEquals(1, resumen.bloqueadasSemana)
    }

    @Test
    fun unaFechaFuturaNoCuentaNiHoyNiEnLaSemana() {
        // Puede ocurrir si se cambia a mano el reloj del móvil.
        val resumen = calcular(bloqueada(momento(11, 10)))
        assertEquals(0, resumen.bloqueadasHoy)
        assertEquals(0, resumen.bloqueadasSemana)
        assertEquals(1, resumen.bloqueadasRegistro)
    }

    // ---- Motivo más frecuente ----

    @Test
    fun ganaElMotivoQueMasSeRepite() {
        val resumen = calcular(
            bloqueada(motivo = "Número concreto"),
            bloqueada(motivo = "Prefijo 400"),
            bloqueada(motivo = "Prefijo 400")
        )
        assertEquals("Prefijo 400", resumen.motivoMasFrecuente)
    }

    @Test
    fun elMotivoIgnoraLasPermitidas() {
        val resumen = calcular(bloqueada(), permitida(), permitida(), permitida())
        assertEquals("Prefijo 400", resumen.motivoMasFrecuente)
    }

    @Test
    fun enUnEmpateElResultadoNoDependeDelOrden() {
        val a = bloqueada(motivo = "Número concreto")
        val b = bloqueada(motivo = "Prefijo 400")
        assertEquals("Número concreto", calcular(a, b).motivoMasFrecuente)
        assertEquals("Número concreto", calcular(b, a).motivoMasFrecuente)
    }

    @Test
    fun sinBloqueadasNoHayMotivo() {
        assertNull(calcular(permitida()).motivoMasFrecuente)
    }
}
