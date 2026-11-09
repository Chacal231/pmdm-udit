package com.example.filtro400

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

private const val TOTAL_PASOS = 3

// Introducción que se ve la primera vez que se abre la app. Quien decide cuándo
// se muestra es AppRaiz; esta pantalla solo avisa de que el usuario ha terminado.
@Composable
fun PantallaOnboarding(rol: EstadoRol, onTerminar: () -> Unit) {
    // rememberSaveable: al girar el móvil se sigue en el mismo paso.
    var paso by rememberSaveable { mutableIntStateOf(0) }

    // "Atrás" retrocede un paso. Desde el primero, Android cierra la app y la
    // introducción volverá a salir, porque aún no se ha marcado como vista.
    BackHandler(enabled = paso > 0) { paso-- }

    // Esta pantalla no tiene Scaffold: safeDrawingPadding evita que el contenido
    // quede debajo de las barras del sistema.
    Column(
        modifier = Modifier
            .fillMaxSize()
            .safeDrawingPadding()
            .padding(24.dp)
    ) {
        // weight + scroll: los botones siempre se ven y, si el texto no cabe
        // (móvil en horizontal), lo que se desplaza es solo el contenido.
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "Paso ${paso + 1} de $TOTAL_PASOS",
                style = MaterialTheme.typography.labelLarge
            )
            Spacer(modifier = Modifier.height(32.dp))
            when (paso) {
                0 -> BloquePaso(
                    emoji = "🛡️",
                    titulo = "Bienvenido a Escudo de Llamadas",
                    texto = "Rechaza las llamadas entrantes no deseadas antes de que " +
                            "suenen, sin sustituir tu aplicación de teléfono."
                )
                1 -> BloquePaso(
                    emoji = "📋",
                    titulo = "Tú eliges los prefijos",
                    texto = "El prefijo 400 viene bloqueado de serie y puedes añadir más " +
                            "en Reglas. También se reconocen los formatos +34 y 0034.\n\n" +
                            "No se filtran los contactos de tu agenda ni los números ocultos."
                )
                else -> {
                    BloquePaso(
                        emoji = "✅",
                        titulo = "Activa el filtro",
                        texto = "Android solo deja filtrar llamadas a la app que tú elijas. " +
                                "Puedes hacerlo ahora o más tarde desde Inicio."
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                    // Sin "bloqueadas": aquí el contador todavía no aporta nada.
                    TarjetaEstado(
                        activo = rol.activo,
                        onActivar = rol.solicitar,
                        onAjustes = rol.abrirAjustes
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (paso > 0) {
                TextButton(onClick = { paso-- }) { Text("Atrás") }
            }
            Spacer(modifier = Modifier.weight(1f))
            // El rol es opcional: se puede terminar sin darlo, y la tarjeta
            // roja de Inicio seguirá avisando de que el filtro está inactivo.
            Button(onClick = { if (paso < TOTAL_PASOS - 1) paso++ else onTerminar() }) {
                Text(if (paso < TOTAL_PASOS - 1) "Siguiente" else "Empezar")
            }
        }
    }
}

// La parte común de los tres pasos: icono, título y explicación.
@Composable
private fun BloquePaso(emoji: String, titulo: String, texto: String) {
    Text(emoji, style = MaterialTheme.typography.displayMedium)
    Spacer(modifier = Modifier.height(16.dp))
    Text(
        titulo,
        style = MaterialTheme.typography.headlineSmall,
        fontWeight = FontWeight.Bold,
        textAlign = TextAlign.Center
    )
    Spacer(modifier = Modifier.height(12.dp))
    Text(
        texto,
        style = MaterialTheme.typography.bodyLarge,
        textAlign = TextAlign.Center
    )
}
