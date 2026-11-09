package com.example.filtro400

import android.app.role.RoleManager
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.example.filtro400.ui.theme.EscudoTheme
import com.example.filtro400.ui.theme.ModoTema
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    // Este contador sube cada vez que la app vuelve a primer plano (onResume).
    // La pantalla lo observa y vuelve a comprobar si tenemos el rol de filtrado,
    // por ejemplo después de cambiarlo en los ajustes del sistema.
    private var refresco by mutableIntStateOf(0)

    // "by lazy": el contexto de la Activity aún no existe al construir la clase.
    private val preferencias by lazy { Preferencias(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // El tema se decide aquí, por encima de EscudoTheme, porque al
            // cambiarlo tiene que redibujarse toda la app.
            var modoTema by remember { mutableStateOf(preferencias.modoTema) }
            val oscuro = modoTema.usaOscuro(isSystemInDarkTheme())

            // Las barras del sistema no dependen de Compose: hay que decirle a
            // Android de qué color poner sus iconos para que se vean sobre el
            // tema elegido, que puede no coincidir con el del sistema.
            LaunchedEffect(oscuro) {
                val estilo = if (oscuro) {
                    SystemBarStyle.dark(Color.TRANSPARENT)
                } else {
                    SystemBarStyle.light(Color.TRANSPARENT, Color.TRANSPARENT)
                }
                enableEdgeToEdge(statusBarStyle = estilo, navigationBarStyle = estilo)
            }

            EscudoTheme(oscuro = oscuro) {
                Surface(modifier = Modifier.fillMaxSize()) {
                    AppRaiz(
                        refresco = refresco,
                        modoTema = modoTema,
                        onCambiarTema = { nuevo ->
                            modoTema = nuevo
                            preferencias.modoTema = nuevo
                        }
                    )
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        refresco++
    }
}

// Navegación sencilla sin librerías: un valor del enum Seccion decide qué se ve.
// El estado compartido vive aquí, en la raíz, y no dentro de una pantalla:
// así sobrevive cuando esa pantalla deja de mostrarse (por ejemplo, el
// "Deshacer" de un borrado sigue funcionando aunque cambiemos de sección).
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppRaiz(refresco: Int, modoTema: ModoTema, onCambiarTema: (ModoTema) -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val snackbarState = remember { SnackbarHostState() }
    val rol = rememberEstadoRol(refresco)

    // Base de datos y lista de filtros. Se leen de SQLite al abrir la app.
    val db = remember { FiltrosDbHelper(context) }
    val filtros = remember { mutableStateListOf<Filtro>().apply { addAll(db.obtenerTodos()) } }
    val recargar: () -> Unit = {
        filtros.clear()
        filtros.addAll(db.obtenerTodos())
    }
    val bloqueadas = rememberBloqueadas(refresco)

    // rememberSaveable: la sección actual sobrevive al girar el móvil.
    var seccion by rememberSaveable { mutableStateOf(Seccion.INICIO) }
    var verAcerca by rememberSaveable { mutableStateOf(false) }
    // El botón "+ Añadir" está en la raíz, pero el diálogo lo dibuja Reglas.
    var anadiendo by remember { mutableStateOf(false) }

    if (verAcerca) {
        PantallaAcerca(onVolver = { verAcerca = false })
        return
    }

    // El botón "atrás" lleva a Inicio; desde Inicio, Android cierra la app.
    BackHandler(enabled = seccion != Seccion.INICIO) { seccion = Seccion.INICIO }

    // Un único Scaffold para toda la app. Con uno por pantalla, cada uno sumaría
    // su propio margen para las barras del sistema y el contenido quedaría descolocado.
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (seccion == Seccion.INICIO) stringResource(R.string.app_name)
                        else seccion.etiqueta,
                        fontWeight = FontWeight.Bold
                    )
                }
            )
        },
        bottomBar = {
            NavigationBar {
                Seccion.entries.forEach { opcion ->
                    NavigationBarItem(
                        selected = opcion == seccion,
                        onClick = { seccion = opcion },
                        icon = { Text(opcion.emoji) },
                        label = { Text(opcion.etiqueta) }
                    )
                }
            }
        },
        snackbarHost = { SnackbarHost(snackbarState) },
        floatingActionButton = {
            if (seccion == Seccion.REGLAS) {
                ExtendedFloatingActionButton(onClick = { anadiendo = true }) {
                    Text("+ Añadir")
                }
            }
        }
    ) { padding ->
        when (seccion) {
            Seccion.INICIO -> PantallaInicio(
                padding = padding,
                rol = rol,
                filtros = filtros,
                bloqueadas = bloqueadas
            )
            Seccion.REGLAS -> PantallaReglas(
                padding = padding,
                db = db,
                filtros = filtros,
                recargar = recargar,
                snackbarState = snackbarState,
                scope = scope,
                anadiendo = anadiendo,
                onCerrarAnadir = { anadiendo = false }
            )
            Seccion.ACTIVIDAD -> PantallaActividad(padding = padding)
            Seccion.AJUSTES -> PantallaAjustes(
                padding = padding,
                modoTema = modoTema,
                onCambiarTema = onCambiarTema,
                onAcerca = { verAcerca = true }
            )
        }
    }
}

// Devuelve el contador de llamadas bloqueadas y lo mantiene al día.
// Lo escribe el servicio, fuera de Compose, así que hay que escuchar los cambios
// para que la tarjeta suba en directo, con la app abierta.
@Composable
fun rememberBloqueadas(refresco: Int): Int {
    val context = LocalContext.current
    val preferencias = remember { Preferencias(context.applicationContext) }
    var bloqueadas by remember { mutableIntStateOf(preferencias.bloqueadas) }

    // Al volver a primer plano releemos, por si algo se perdió mientras tanto.
    LaunchedEffect(refresco) { bloqueadas = preferencias.bloqueadas }

    // DisposableEffect: empieza a escuchar al entrar y deja de hacerlo al salir,
    // para no dejar un listener activo cuando la pantalla ya no existe.
    DisposableEffect(preferencias) {
        val dejarDeObservar = preferencias.observarBloqueadas { bloqueadas = it }
        onDispose { dejarDeObservar() }
    }
    return bloqueadas
}

// Agrupa lo que las pantallas necesitan saber y hacer con el rol de filtrado.
class EstadoRol(
    val activo: Boolean,
    val solicitar: () -> Unit,
    val abrirAjustes: () -> Unit
)

// Función "remember...": concentra la lógica del rol en un solo sitio para que
// cualquier pantalla pueda reutilizarla sin repetir el código de RoleManager.
@Composable
fun rememberEstadoRol(refresco: Int): EstadoRol {
    val context = LocalContext.current

    // RoleManager: el servicio de Android que gestiona "roles" como
    // "app de filtrado de llamadas". Sin el rol, nuestro servicio no se activa.
    val roleManager = remember { context.getSystemService(RoleManager::class.java) }

    // remember(refresco): cada vez que la app vuelve a primer plano se recalcula.
    var activo by remember(refresco) {
        mutableStateOf(roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
    }

    // Cuando el usuario responde al diálogo del sistema, volvemos aquí
    // y volvemos a comprobar si ahora tenemos el rol.
    val lanzador = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) {
        activo = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
    }

    return EstadoRol(
        activo = activo,
        solicitar = {
            // Android muestra su propio diálogo: la app no puede darse el rol sola.
            lanzador.launch(roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING))
        },
        abrirAjustes = {
            // Por si el usuario rechazó el diálogo y ya no vuelve a salir.
            runCatching {
                context.startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
            }
        }
    )
}

// Inicio: el estado del filtro y el probador de números.
// Toda la pantalla es una lista: así hace scroll en móviles pequeños
// y cuando el teclado está abierto.
@Composable
fun PantallaInicio(
    padding: PaddingValues,
    rol: EstadoRol,
    filtros: List<Filtro>,
    bloqueadas: Int
) {
    LazyColumn(
        modifier = Modifier
            .padding(padding)
            .fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            TarjetaEstado(
                activo = rol.activo,
                onActivar = rol.solicitar,
                onAjustes = rol.abrirAjustes,
                bloqueadas = bloqueadas
            )
        }

        item {
            // La lista viene de la raíz: lo que cambies en Reglas se aplica aquí.
            TarjetaProbador(
                prefijosActivos = filtros.filter { it.activo }.map { it.prefijo }
            )
        }
    }
}

// Reglas: la lista de prefijos y sus diálogos de añadir, editar y borrar.
@Composable
fun PantallaReglas(
    padding: PaddingValues,
    db: FiltrosDbHelper,
    filtros: List<Filtro>,
    recargar: () -> Unit,
    snackbarState: SnackbarHostState,
    scope: CoroutineScope,
    anadiendo: Boolean,
    onCerrarAnadir: () -> Unit
) {
    // Filtro que se está editando (null si no se edita ninguno).
    var filtroEditando by remember { mutableStateOf<Filtro?>(null) }
    // Filtro pendiente de confirmar su borrado.
    var filtroABorrar by remember { mutableStateOf<Filtro?>(null) }

    LazyColumn(
        modifier = Modifier
            .padding(padding)
            .fillMaxSize(),
        // Margen inferior amplio para que el botón "+ Añadir" no tape la última tarjeta.
        contentPadding = PaddingValues(16.dp, 16.dp, 16.dp, 96.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text(
                "Prefijos bloqueados",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }

        if (filtros.isEmpty()) {
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("📵", style = MaterialTheme.typography.displaySmall)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Todavía no bloqueas ningún prefijo", fontWeight = FontWeight.Bold)
                        Text(
                            "Pulsa + Añadir para bloquear las llamadas que empiecen por un prefijo.",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }
            }
        }

        items(filtros, key = { it.id }) { filtro ->
            TarjetaFiltro(
                filtro = filtro,
                onCambiarActivo = {
                    db.cambiarActivo(filtro.id, it)
                    recargar()
                },
                onEditar = { filtroEditando = filtro },
                onBorrar = { filtroABorrar = filtro }
            )
        }
    }

    // ---- Diálogo de confirmación de borrado ----
    filtroABorrar?.let { filtro ->
        AlertDialog(
            onDismissRequest = { filtroABorrar = null },
            title = { Text("¿Eliminar el prefijo ${filtro.prefijo}?") },
            text = { Text("Dejarán de bloquearse las llamadas que empiecen por ese prefijo.") },
            confirmButton = {
                TextButton(onClick = {
                    db.eliminar(filtro.id)
                    recargar()
                    filtroABorrar = null
                    scope.launch {
                        snackbarState.currentSnackbarData?.dismiss()
                        val resultado = snackbarState.showSnackbar(
                            message = "Prefijo ${filtro.prefijo} eliminado",
                            actionLabel = "Deshacer",
                            duration = SnackbarDuration.Short
                        )
                        if (resultado == SnackbarResult.ActionPerformed) {
                            // Lo devolvemos con el mismo prefijo y el mismo estado
                            // (activo/desactivado). Vuelve al final de la lista.
                            db.insertarConEstado(filtro.prefijo, filtro.activo)
                            recargar()
                        }
                    }
                }) { Text("Eliminar") }
            },
            dismissButton = {
                TextButton(onClick = { filtroABorrar = null }) { Text("Cancelar") }
            }
        )
    }

    // ---- Diálogo de añadir / editar ----
    val editando = filtroEditando
    if (anadiendo || editando != null) {
        val cerrar: () -> Unit = {
            filtroEditando = null
            onCerrarAnadir()
        }
        DialogoPrefijo(
            titulo = if (editando == null) "Nuevo prefijo" else "Editar prefijo",
            valorInicial = editando?.prefijo.orEmpty(),
            onCancelar = cerrar,
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
                    cerrar()
                }
                ok
            }
        )
    }
}

// Tarjeta de arriba: verde-turquesa si el filtro está activo, roja si no.
// "bloqueadas" es opcional: si es null, la tarjeta no muestra el contador.
@Composable
fun TarjetaEstado(
    activo: Boolean,
    onActivar: () -> Unit,
    onAjustes: () -> Unit,
    bloqueadas: Int? = null
) {
    val colores = if (activo) {
        CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer,
            contentColor = MaterialTheme.colorScheme.onPrimaryContainer
        )
    } else {
        CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer,
            contentColor = MaterialTheme.colorScheme.onErrorContainer
        )
    }
    Card(modifier = Modifier.fillMaxWidth(), colors = colores) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                if (activo) "✅ Filtro ACTIVO" else "⚠️ Filtro inactivo",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                if (activo) "Las llamadas con un prefijo activo se rechazan antes de sonar."
                else "Android necesita que esta app sea tu filtro de llamadas para poder bloquear.",
                style = MaterialTheme.typography.bodyMedium
            )
            if (bloqueadas != null) {
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    "🛡️ ${ContadorBloqueos.textoBloqueadas(bloqueadas)}",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }
            if (!activo) {
                Spacer(modifier = Modifier.height(12.dp))
                Button(onClick = onActivar) { Text("Activar filtro de llamadas") }
                TextButton(onClick = onAjustes) { Text("Abrir ajustes de apps predeterminadas") }
            }
        }
    }
}

// Probador: comprueba las reglas ACTIVAS sin recibir una llamada.
@Composable
fun TarjetaProbador(prefijosActivos: List<String>) {
    var numero by remember { mutableStateOf("") }
    var resultado by remember { mutableStateOf("") }

    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                "Probador de números",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                "Mira qué pasaría con un número sin necesidad de recibir una llamada.",
                style = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = numero,
                onValueChange = { numero = it },
                label = { Text("Ej. +34 400 123 456") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))
            Button(onClick = {
                val coincidencia = ReglaBloqueo.prefijoCoincidente(numero, prefijosActivos)
                val normalizado = ReglaBloqueo.normalizar(numero).ifEmpty { "(vacío)" }
                val veredicto = if (coincidencia != null)
                    "🚫 Se BLOQUEARÍA por el prefijo $coincidencia"
                else
                    "✅ Pasaría"
                resultado = "$veredicto\nNúmero normalizado: $normalizado"
            }) { Text("Probar") }
            if (resultado.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(resultado, style = MaterialTheme.typography.bodyLarge)
            }
        }
    }
}

// Una tarjeta por filtro. Si está desactivado, el prefijo se ve atenuado.
@Composable
fun TarjetaFiltro(
    filtro: Filtro,
    onCambiarActivo: (Boolean) -> Unit,
    onEditar: () -> Unit,
    onBorrar: () -> Unit
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    filtro.prefijo,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .weight(1f)
                        .alpha(if (filtro.activo) 1f else 0.4f)
                )
                Text(
                    if (filtro.activo) "Activo" else "Desactivado",
                    style = MaterialTheme.typography.bodySmall
                )
                Spacer(modifier = Modifier.width(8.dp))
                Switch(checked = filtro.activo, onCheckedChange = onCambiarActivo)
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                TextButton(onClick = onEditar) { Text("Editar") }
                TextButton(onClick = onBorrar) { Text("Borrar") }
            }
        }
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

// Pantalla "Acerca de": la marca personal del trabajo.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PantallaAcerca(onVolver: () -> Unit) {
    // El botón "atrás" del móvil vuelve a la pantalla principal.
    BackHandler(onBack = onVolver)

    val context = LocalContext.current
    val version = remember {
        runCatching {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName
        }.getOrNull() ?: "1.0"
    }
    val urlRepo = "https://github.com/Chacal231/pmdm-udit"

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Acerca de") },
                navigationIcon = { TextButton(onClick = onVolver) { Text("‹ Volver") } }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        stringResource(R.string.app_name),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Text("Versión $version", style = MaterialTheme.typography.bodySmall)
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        "Bloquea llamadas entrantes según prefijos que tú configuras, " +
                                "sin sustituir tu aplicación de teléfono. Los filtros se " +
                                "guardan solo en tu móvil, en una base de datos SQLite."
                    )
                }
            }

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Autor", fontWeight = FontWeight.Bold)
                    Text("Daniel")
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("Curso", fontWeight = FontWeight.Bold)
                    Text("2º DAM · PMDM · UDIT")
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("GitHub", fontWeight = FontWeight.Bold)
                    Text("Chacal231")
                }
            }

            Button(
                onClick = {
                    runCatching {
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(urlRepo)))
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) { Text("Ver el proyecto en GitHub") }
        }
    }
}