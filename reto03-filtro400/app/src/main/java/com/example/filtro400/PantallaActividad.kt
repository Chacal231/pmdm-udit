package com.example.filtro400

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.text.SimpleDateFormat
import java.time.ZoneId
import java.util.Date
import java.util.Locale

// Actividad: el registro de las llamadas que ha filtrado el servicio.
// "padding" viene del Scaffold de la raíz y evita que el contenido quede
// debajo de las barras.
@Composable
fun PantallaActividad(padding: PaddingValues, db: FiltrosDbHelper, refresco: Int) {
    val entradas = rememberActividad(db)
    // "refresco" cambia al volver a primer plano: si la app se queda abierta de
    // un día para otro, "hoy" tiene que recalcularse aunque no llegue ninguna llamada.
    val resumen = remember(entradas, refresco) {
        EstadisticasActividad.calcular(entradas, System.currentTimeMillis(), ZoneId.systemDefault())
    }
    var confirmandoVaciar by remember { mutableStateOf(false) }
    val formatoFecha = remember { SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault()) }

    LazyColumn(
        modifier = Modifier
            .padding(padding)
            .fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { TarjetaResumen(resumen) }

        if (entradas.isEmpty()) {
            item { TarjetaActividadVacia() }
        } else {
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "Últimas llamadas",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.weight(1f)
                    )
                    TextButton(onClick = { confirmandoVaciar = true }) { Text("Vaciar") }
                }
            }
            items(entradas, key = { it.id }) { entrada ->
                TarjetaEntrada(entrada, formatoFecha.format(Date(entrada.fecha)))
            }
        }
    }

    if (confirmandoVaciar) {
        AlertDialog(
            onDismissRequest = { confirmandoVaciar = false },
            title = { Text("¿Vaciar el registro?") },
            text = { Text("Se borrará el historial de llamadas. El contador de Inicio no cambia.") },
            confirmButton = {
                TextButton(onClick = {
                    // No hace falta recargar: el aviso del registro actualiza la lista.
                    db.vaciarActividad()
                    confirmandoVaciar = false
                }) { Text("Vaciar") }
            },
            dismissButton = {
                TextButton(onClick = { confirmandoVaciar = false }) { Text("Cancelar") }
            }
        )
    }
}

// Devuelve el registro y lo mantiene al día. Lo escribe el servicio, fuera de
// Compose, así que hay que escuchar los cambios para que la lista se actualice
// en directo. Android ejecuta onScreenCall en el hilo principal, de modo que el
// aviso también llega en él y se puede tocar el estado de Compose sin problema.
@Composable
fun rememberActividad(db: FiltrosDbHelper): List<EntradaActividad> {
    var entradas by remember { mutableStateOf(db.obtenerActividad()) }

    // DisposableEffect: empieza a escuchar al entrar y deja de hacerlo al salir,
    // para no dejar un observador activo cuando la pantalla ya no existe.
    DisposableEffect(db) {
        val dejarDeObservar = db.observarActividad { entradas = db.obtenerActividad() }
        onDispose { dejarDeObservar() }
    }
    return entradas
}

// Resumen del registro. Se muestra también vacío, con todo a cero, para que al
// vaciar el registro se vea que las cifras dependen de él.
@Composable
private fun TarjetaResumen(resumen: ResumenActividad) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                "Resumen",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(8.dp))
            FilaResumen("Bloqueadas hoy", resumen.bloqueadasHoy.toString())
            FilaResumen("Bloqueadas en 7 días", resumen.bloqueadasSemana.toString())
            FilaResumen(
                "Bloqueadas en el registro",
                "${resumen.bloqueadasRegistro} de ${resumen.totalRegistro}"
            )
            FilaResumen("Porcentaje bloqueado", "${resumen.porcentajeBloqueado} %")
            FilaResumen("Motivo de bloqueo más frecuente", resumen.motivoMasFrecuente ?: "—")
        }
    }
}

@Composable
private fun FilaResumen(etiqueta: String, valor: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            etiqueta,
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.weight(1f)
        )
        Text(valor, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun TarjetaActividadVacia() {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("📊", style = MaterialTheme.typography.displaySmall)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Todavía no hay actividad", fontWeight = FontWeight.Bold)
            Text(
                "Aquí verás las llamadas que reciba el filtro.",
                style = MaterialTheme.typography.bodySmall
            )
        }
    }
}

// Una tarjeta por llamada. La decisión lleva emoji además de color para que se
// distinga también sin percibir bien los colores.
@Composable
private fun TarjetaEntrada(entrada: EntradaActividad, fecha: String) {
    val bloqueada = entrada.decision == DecisionLlamada.BLOQUEADA
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    entrada.numeroEnmascarado,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    (if (bloqueada) "🚫 " else "✅ ") + entrada.decision.etiqueta,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = if (bloqueada) MaterialTheme.colorScheme.error
                    else MaterialTheme.colorScheme.primary
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(entrada.motivo, style = MaterialTheme.typography.bodyMedium)
            Text(fecha, style = MaterialTheme.typography.bodySmall)
        }
    }
}
