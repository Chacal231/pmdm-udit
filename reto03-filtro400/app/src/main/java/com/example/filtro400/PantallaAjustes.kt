package com.example.filtro400

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.filtro400.ui.theme.ModoTema

// Sección de ajustes. Recibe "onAcerca" en lugar de abrir la pantalla por su
// cuenta porque quien decide qué se muestra es AppRaiz, la dueña de la navegación.
@Composable
fun PantallaAjustes(
    padding: PaddingValues,
    modoTema: ModoTema,
    onCambiarTema: (ModoTema) -> Unit,
    onAcerca: () -> Unit
) {
    Column(
        modifier = Modifier
            .padding(padding)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Card(modifier = Modifier.fillMaxWidth()) {
            // selectableGroup + selectable: TalkBack anuncia las filas como un
            // único grupo de opciones, y se puede pulsar en toda la fila.
            Column(
                modifier = Modifier
                    .padding(vertical = 8.dp)
                    .selectableGroup()
            ) {
                Text(
                    "Tema",
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )
                ModoTema.entries.forEach { opcion ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .selectable(
                                selected = opcion == modoTema,
                                onClick = { onCambiarTema(opcion) },
                                role = Role.RadioButton
                            )
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // onClick = null: el clic ya lo gestiona la fila entera.
                        RadioButton(selected = opcion == modoTema, onClick = null)
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(opcion.etiqueta)
                    }
                }
            }
        }

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
