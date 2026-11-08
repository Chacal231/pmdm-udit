package com.example.filtro400

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

// Sección de ajustes. Recibe "onAcerca" en lugar de abrir la pantalla por su
// cuenta porque quien decide qué se muestra es AppRaiz, la dueña de la navegación.
@Composable
fun PantallaAjustes(padding: PaddingValues, onAcerca: () -> Unit) {
    Column(
        modifier = Modifier
            .padding(padding)
            .padding(16.dp)
    ) {
        Card(onClick = onAcerca, modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Acerca de", fontWeight = FontWeight.Bold)
                Text(
                    "Versión, autor y repositorio del proyecto",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}
