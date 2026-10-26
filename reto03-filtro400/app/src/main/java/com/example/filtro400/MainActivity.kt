package com.example.filtro400

import android.app.role.RoleManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    PantallaFiltro()
                }
            }
        }
    }
}

@Composable
fun PantallaFiltro() {
    val context = LocalContext.current

    // RoleManager: el servicio de Android que gestiona "roles" como
    // "app de filtrado de llamadas". Sin el rol, nuestro servicio no se activa.
    val roleManager = remember { context.getSystemService(RoleManager::class.java) }

    // Base de datos y lista de filtros. Se leen de SQLite al abrir la app.
    val db = remember { FiltrosDbHelper(context) }
    val filtros = remember { mutableStateListOf<Filtro>().apply { addAll(db.obtenerTodos()) } }
    fun recargar() {
        filtros.clear()
        filtros.addAll(db.obtenerTodos())
    }

    // Estado que la pantalla "vigila": si el filtro está activo.
    var filtroActivo by remember {
        mutableStateOf(roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
    }
    var numeroPrueba by remember { mutableStateOf("") }
    var resultadoPrueba by remember { mutableStateOf("") }

    // Diálogo de añadir/editar. Si filtroEditando es null, estamos añadiendo.
    var dialogoVisible by remember { mutableStateOf(false) }
    var filtroEditando by remember { mutableStateOf<Filtro?>(null) }

    // Cuando el usuario responde al diálogo del sistema, volvemos aquí
    // y volvemos a comprobar si ahora tenemos el rol.
    val lanzador = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) {
        filtroActivo = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Filtro 400", fontSize = 32.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = if (filtroActivo) "✅ Filtro ACTIVO" else "⚠️ Filtro inactivo",
            fontSize = 18.sp
        )
        Spacer(modifier = Modifier.height(16.dp))

        // Pide al sistema el rol de filtrado. Android muestra su propio
        // diálogo: la app no puede darse el rol a sí misma.
        Button(
            onClick = {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                lanzador.launch(intent)
            },
            enabled = !filtroActivo
        ) {
            Text("Activar filtro de llamadas")
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Probador: comprueba las reglas ACTIVAS sin recibir una llamada.
        Text("Probador de números", fontWeight = FontWeight.Bold)
        OutlinedTextField(
            value = numeroPrueba,
            onValueChange = { numeroPrueba = it },
            label = { Text("Ej. +34 400 123 456") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
            singleLine = true
        )
        Spacer(modifier = Modifier.height(8.dp))

        Button(onClick = {
            val activos = filtros.filter { it.activo }.map { it.prefijo }
            resultadoPrueba = if (ReglaBloqueo.debeBloquearse(numeroPrueba, activos))
                "🚫 Se BLOQUEARÍA" else "✅ Pasaría"
        }) {
            Text("Probar")
        }
        Spacer(modifier = Modifier.height(8.dp))
        Text(resultadoPrueba, fontSize = 20.sp)

        Spacer(modifier = Modifier.height(16.dp))
        HorizontalDivider()
        Spacer(modifier = Modifier.height(8.dp))

        // Cabecera de la lista + botón de añadir.
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                "Prefijos bloqueados",
                fontWeight = FontWeight.Bold,
                modifier = Modifier.weight(1f)
            )
            Button(onClick = { filtroEditando = null; dialogoVisible = true }) {
                Text("+ Añadir")
            }
        }

        if (filtros.isEmpty()) {
            Text("No hay filtros. Pulsa + Añadir.")
        }

        // LazyColumn: lista que solo dibuja las filas visibles.
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(filtros, key = { it.id }) { filtro ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        filtro.prefijo,
                        fontSize = 20.sp,
                        modifier = Modifier.weight(1f)
                    )
                    // Interruptor: activa o desactiva este filtro sin borrarlo.
                    Switch(
                        checked = filtro.activo,
                        onCheckedChange = {
                            db.cambiarActivo(filtro.id, it)
                            recargar()
                        }
                    )
                    TextButton(onClick = { filtroEditando = filtro; dialogoVisible = true }) {
                        Text("Editar")
                    }
                    TextButton(onClick = { db.eliminar(filtro.id); recargar() }) {
                        Text("Borrar")
                    }
                }
                HorizontalDivider()
            }
        }
    }

    if (dialogoVisible) {
        val editando = filtroEditando
        DialogoPrefijo(
            titulo = if (editando == null) "Nuevo prefijo" else "Editar prefijo",
            valorInicial = editando?.prefijo.orEmpty(),
            onCancelar = { dialogoVisible = false },
            // Devuelve true si se guardó bien, false si hay error (vacío o repetido).
            onGuardar = { texto ->
                val prefijo = ReglaBloqueo.limpiarPrefijo(texto)
                val ok = when {
                    prefijo.isEmpty() -> false
                    editando == null -> db.insertar(prefijo)
                    else -> db.actualizarPrefijo(editando.id, prefijo)
                }
                if (ok) {
                    recargar()
                    dialogoVisible = false
                }
                ok
            }
        )
    }
}

@Composable
fun DialogoPrefijo(
    titulo: String,
    valorInicial: String,
    onCancelar: () -> Unit,
    onGuardar: (String) -> Boolean
) {
    var texto by remember { mutableStateOf(valorInicial) }
    var hayError by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onCancelar,
        title = { Text(titulo) },
        text = {
            OutlinedTextField(
                value = texto,
                onValueChange = { texto = it; hayError = false },
                label = { Text("Prefijo (ej. 400)") },
                singleLine = true,
                isError = hayError,
                supportingText = { if (hayError) Text("Está vacío o ya existe") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
            )
        },
        confirmButton = {
            TextButton(onClick = { hayError = !onGuardar(texto) }) { Text("Guardar") }
        },
        dismissButton = {
            TextButton(onClick = onCancelar) { Text("Cancelar") }
        }
    )
}