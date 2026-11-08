package com.example.filtro400

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

// Marcador de posición: la sección ya existe en la navegación, pero el registro
// de llamadas llegará en una ronda posterior. "padding" viene del Scaffold de la
// raíz y evita que el contenido quede debajo de las barras.
@Composable
fun PantallaActividad(padding: PaddingValues) {
    Column(
        modifier = Modifier
            .padding(padding)
            .padding(16.dp)
    ) {
        Card(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("📊", style = MaterialTheme.typography.displaySmall)
                Spacer(modifier = Modifier.height(8.dp))
                Text("Próximamente", fontWeight = FontWeight.Bold)
                Text(
                    "Aquí verás el historial de llamadas filtradas.",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}
