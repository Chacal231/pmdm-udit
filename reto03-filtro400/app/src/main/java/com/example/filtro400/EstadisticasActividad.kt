package com.example.filtro400

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import kotlin.math.roundToInt

// Las cifras de la tarjeta Resumen. Salen solo del registro, así que se reinician
// al vaciarlo y cubren como mucho sus últimas entradas.
data class ResumenActividad(
    val bloqueadasHoy: Int,
    val bloqueadasSemana: Int,
    val bloqueadasRegistro: Int,
    val totalRegistro: Int,
    val porcentajeBloqueado: Int,
    val motivoMasFrecuente: String?
)

// Lógica pura: "ahora" y la zona horaria llegan como parámetros, y no se leen
// del sistema, para que los tests puedan fijar el momento exacto que comprueban.
object EstadisticasActividad {

    // La semana son 7 días de calendario: hoy y los 6 anteriores.
    private const val DIAS_ANTERIORES_EN_SEMANA = 6L

    fun calcular(entradas: List<EntradaActividad>, ahora: Long, zona: ZoneId): ResumenActividad {
        val bloqueadas = entradas.filter { it.decision == DecisionLlamada.BLOQUEADA }

        // Se compara por fecha de calendario, no restando milisegundos: un día no
        // siempre dura 24 horas (cambio de hora) y "hoy" empieza a medianoche.
        val hoy = diaDe(ahora, zona)
        val inicioSemana = hoy.minusDays(DIAS_ANTERIORES_EN_SEMANA)
        val diasBloqueadas = bloqueadas.map { diaDe(it.fecha, zona) }

        return ResumenActividad(
            bloqueadasHoy = diasBloqueadas.count { it == hoy },
            bloqueadasSemana = diasBloqueadas.count { it in inicioSemana..hoy },
            bloqueadasRegistro = bloqueadas.size,
            totalRegistro = entradas.size,
            porcentajeBloqueado = porcentaje(bloqueadas.size, entradas.size),
            motivoMasFrecuente = motivoMasFrecuente(bloqueadas)
        )
    }

    private fun diaDe(fecha: Long, zona: ZoneId): LocalDate =
        Instant.ofEpochMilli(fecha).atZone(zona).toLocalDate()

    // Con el registro vacío no se puede dividir: el porcentaje es 0.
    private fun porcentaje(parte: Int, total: Int): Int =
        if (total == 0) 0 else (parte * 100.0 / total).roundToInt()

    // Solo cuentan las bloqueadas: si entraran las permitidas, casi siempre
    // ganaría "Sin coincidencia", que no dice nada útil. En un empate gana el primero
    // por orden alfabético, para que el resultado no dependa del orden de la lista.
    private fun motivoMasFrecuente(bloqueadas: List<EntradaActividad>): String? =
        bloqueadas.groupingBy { it.motivo }.eachCount().entries
            .minWithOrNull(compareBy({ -it.value }, { it.key }))
            ?.key
}
