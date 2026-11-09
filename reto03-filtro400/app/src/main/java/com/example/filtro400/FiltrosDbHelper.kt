package com.example.filtro400

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import java.util.concurrent.CopyOnWriteArraySet

// SQLiteOpenHelper: clase de Android que crea la base de datos la primera vez
// y nos da acceso a ella después. Aquí vive el CRUD de los filtros y el registro.
// El constructor es privado para obligar a pasar por obtener(): ver más abajo.
class FiltrosDbHelper private constructor(context: Context) :
    SQLiteOpenHelper(context, NOMBRE_BD, null, VERSION_BD) {

    // Funciones que quieren enterarse de que el registro ha cambiado.
    // CopyOnWrite: permite recorrerla sin fallar aunque alguien se dé de baja a la vez.
    private val observadoresActividad = CopyOnWriteArraySet<() -> Unit>()

    // Se ejecuta UNA sola vez, cuando la base de datos todavía no existe.
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE $TABLA (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_PREFIJO TEXT NOT NULL UNIQUE,
                $COL_ACTIVO INTEGER NOT NULL DEFAULT 1
            )
            """.trimIndent()
        )
        // Para no perder lo de la Fase 1: el prefijo 400 viene creado de serie.
        db.insert(TABLA, null, ContentValues().apply {
            put(COL_PREFIJO, "400")
            put(COL_ACTIVO, 1)
        })
        crearTablasV2(db)
    }

    // Se ejecuta al abrir una base de datos con una versión anterior a VERSION_BD.
    // Migración: solo AÑADE tablas, así que "filtros" conserva todos sus datos.
    // Android la envuelve en una transacción: si falla, la BD no queda a medias.
    override fun onUpgrade(db: SQLiteDatabase, versionAnterior: Int, versionNueva: Int) {
        if (versionAnterior < 2) crearTablasV2(db)
    }

    // onCreate y onUpgrade comparten este método para que una instalación nueva y
    // una actualizada acaben con exactamente las mismas tablas.
    private fun crearTablasV2(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS $TABLA_ACTIVIDAD (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_FECHA INTEGER NOT NULL,
                $COL_NUMERO_ENMASCARADO TEXT NOT NULL,
                $COL_DECISION TEXT NOT NULL,
                $COL_MOTIVO TEXT NOT NULL
            )
            """.trimIndent()
        )
        // Números concretos: bloqueados y lista blanca, distinguidos por "tipo".
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS $TABLA_NUMEROS (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_NUMERO TEXT NOT NULL UNIQUE,
                $COL_TIPO TEXT NOT NULL
            )
            """.trimIndent()
        )
    }

    // READ: todos los filtros, para mostrarlos en la pantalla.
    fun obtenerTodos(): List<Filtro> {
        val lista = mutableListOf<Filtro>()
        readableDatabase.query(TABLA, null, null, null, null, null, "$COL_ID ASC").use { c ->
            while (c.moveToNext()) {
                lista.add(
                    Filtro(
                        id = c.getLong(c.getColumnIndexOrThrow(COL_ID)),
                        prefijo = c.getString(c.getColumnIndexOrThrow(COL_PREFIJO)),
                        activo = c.getInt(c.getColumnIndexOrThrow(COL_ACTIVO)) == 1
                    )
                )
            }
        }
        return lista
    }

    // Solo los prefijos activos: es lo que consulta el servicio en cada llamada.
    fun prefijosActivos(): List<String> {
        val lista = mutableListOf<String>()
        readableDatabase.query(
            TABLA, arrayOf(COL_PREFIJO), "$COL_ACTIVO = 1", null, null, null, null
        ).use { c ->
            while (c.moveToNext()) lista.add(c.getString(0))
        }
        return lista
    }

    // CREATE: devuelve false si el prefijo ya existe (la columna es UNIQUE).
    fun insertar(prefijo: String): Boolean = insertarConEstado(prefijo, true)

    // CREATE indicando si nace activo o no. Lo usa "Deshacer" al borrar,
    // para devolver el filtro tal y como estaba.
    fun insertarConEstado(prefijo: String, activo: Boolean): Boolean {
        val valores = ContentValues().apply {
            put(COL_PREFIJO, prefijo)
            put(COL_ACTIVO, if (activo) 1 else 0)
        }
        return insertarSinRegistrarDuplicados(TABLA, valores)
    }

    // Privacidad: insert() normal, si choca con un UNIQUE, escribe en Logcat todos
    // los valores de la fila, y un "prefijo" puede ser un número entero. Con
    // CONFLICT_IGNORE el duplicado solo devuelve -1, sin dejar rastro.
    private fun insertarSinRegistrarDuplicados(tabla: String, valores: ContentValues): Boolean =
        writableDatabase.insertWithOnConflict(
            tabla, null, valores, SQLiteDatabase.CONFLICT_IGNORE
        ) != -1L

    // UPDATE del prefijo. Devuelve false si choca con otro ya existente.
    fun actualizarPrefijo(id: Long, prefijo: String): Boolean {
        val valores = ContentValues().apply { put(COL_PREFIJO, prefijo) }
        return try {
            writableDatabase.update(TABLA, valores, "$COL_ID = ?", arrayOf(id.toString())) > 0
        } catch (e: Exception) {
            false
        }
    }

    // UPDATE del interruptor activar/desactivar.
    fun cambiarActivo(id: Long, activo: Boolean) {
        val valores = ContentValues().apply { put(COL_ACTIVO, if (activo) 1 else 0) }
        writableDatabase.update(TABLA, valores, "$COL_ID = ?", arrayOf(id.toString()))
    }

    // DELETE
    fun eliminar(id: Long) {
        writableDatabase.delete(TABLA, "$COL_ID = ?", arrayOf(id.toString()))
    }

    // ---- Números concretos (bloqueados y lista blanca) ----

    // READ: las dos listas juntas. Se reparten con deTipo().
    fun obtenerNumeros(): List<NumeroRegla> {
        val lista = mutableListOf<NumeroRegla>()
        readableDatabase.query(
            TABLA_NUMEROS, null, null, null, null, null, "$COL_ID ASC"
        ).use { c ->
            while (c.moveToNext()) {
                lista.add(
                    NumeroRegla(
                        id = c.getLong(c.getColumnIndexOrThrow(COL_ID)),
                        numero = c.getString(c.getColumnIndexOrThrow(COL_NUMERO)),
                        tipo = TipoNumero.desdeNombre(
                            c.getString(c.getColumnIndexOrThrow(COL_TIPO))
                        )
                    )
                )
            }
        }
        return lista
    }

    // CREATE: devuelve false si el número ya existe. La columna es UNIQUE en toda
    // la tabla, así que un número no puede estar a la vez en las dos listas.
    fun insertarNumero(numero: String, tipo: TipoNumero): Boolean {
        val valores = ContentValues().apply {
            put(COL_NUMERO, numero)
            put(COL_TIPO, tipo.name)
        }
        return insertarSinRegistrarDuplicados(TABLA_NUMEROS, valores)
    }

    // UPDATE: devuelve false si choca con otro número ya guardado.
    fun actualizarNumero(id: Long, numero: String): Boolean {
        val valores = ContentValues().apply { put(COL_NUMERO, numero) }
        return writableDatabase.updateWithOnConflict(
            TABLA_NUMEROS, valores, "$COL_ID = ?", arrayOf(id.toString()),
            SQLiteDatabase.CONFLICT_IGNORE
        ) > 0
    }

    // DELETE
    fun eliminarNumero(id: Long) {
        writableDatabase.delete(TABLA_NUMEROS, "$COL_ID = ?", arrayOf(id.toString()))
    }

    // ---- Registro de actividad ----

    // Recibe el número tal cual, pero la única escritura pasa por
    // RegistroActividad.crear: a esta tabla solo puede llegar enmascarado.
    fun registrar(
        numero: String,
        bloqueada: Boolean,
        motivo: String,
        fecha: Long = System.currentTimeMillis()
    ) {
        val entrada = RegistroActividad.crear(numero, bloqueada, motivo, fecha)
        val valores = ContentValues().apply {
            put(COL_FECHA, entrada.fecha)
            put(COL_NUMERO_ENMASCARADO, entrada.numeroEnmascarado)
            put(COL_DECISION, entrada.decision.name)
            put(COL_MOTIVO, entrada.motivo)
        }
        val db = writableDatabase
        // Transacción: insertar y recortar ocurren juntos o no ocurre ninguno.
        db.beginTransaction()
        try {
            db.insert(TABLA_ACTIVIDAD, null, valores)
            // El id solo crece, así que ordena por antigüedad sin depender del reloj
            // del móvil. Con 500 filas o menos la subconsulta da NULL y no borra nada.
            db.delete(
                TABLA_ACTIVIDAD,
                "$COL_ID <= (SELECT $COL_ID FROM $TABLA_ACTIVIDAD " +
                        "ORDER BY $COL_ID DESC LIMIT 1 OFFSET ${RegistroActividad.MAX_ENTRADAS})",
                null
            )
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        avisarCambioActividad()
    }

    // READ: el registro completo, de la llamada más reciente a la más antigua.
    fun obtenerActividad(): List<EntradaActividad> {
        val lista = mutableListOf<EntradaActividad>()
        readableDatabase.query(
            TABLA_ACTIVIDAD, null, null, null, null, null, "$COL_ID DESC"
        ).use { c ->
            while (c.moveToNext()) {
                lista.add(
                    EntradaActividad(
                        id = c.getLong(c.getColumnIndexOrThrow(COL_ID)),
                        fecha = c.getLong(c.getColumnIndexOrThrow(COL_FECHA)),
                        numeroEnmascarado = c.getString(c.getColumnIndexOrThrow(COL_NUMERO_ENMASCARADO)),
                        decision = DecisionLlamada.desdeNombre(
                            c.getString(c.getColumnIndexOrThrow(COL_DECISION))
                        ),
                        motivo = c.getString(c.getColumnIndexOrThrow(COL_MOTIVO))
                    )
                )
            }
        }
        return lista
    }

    // Borra solo el registro: el contador de Inicio es acumulado y va aparte.
    fun vaciarActividad() {
        writableDatabase.delete(TABLA_ACTIVIDAD, null, null)
        avisarCambioActividad()
    }

    // Avisa cada vez que cambia el registro y devuelve la función para dejar de
    // escuchar, igual que Preferencias.observarBloqueadas. Funciona porque el
    // servicio y la interfaz comparten proceso y, gracias a obtener(), objeto.
    fun observarActividad(alCambiar: () -> Unit): () -> Unit {
        observadoresActividad.add(alCambiar)
        return { observadoresActividad.remove(alCambiar) }
    }

    private fun avisarCambioActividad() {
        observadoresActividad.forEach { it() }
    }

    companion object {
        private const val NOMBRE_BD = "filtro400.db"
        private const val VERSION_BD = 2
        private const val TABLA = "filtros"
        private const val COL_ID = "id"
        private const val COL_PREFIJO = "prefijo"
        private const val COL_ACTIVO = "activo"

        private const val TABLA_ACTIVIDAD = "actividad"
        private const val COL_FECHA = "fecha"
        private const val COL_NUMERO_ENMASCARADO = "numero_enmascarado"
        private const val COL_DECISION = "decision"
        private const val COL_MOTIVO = "motivo"

        private const val TABLA_NUMEROS = "numeros"
        private const val COL_NUMERO = "numero"
        private const val COL_TIPO = "tipo"

        // @Volatile: un cambio hecho desde un hilo lo ven enseguida los demás.
        @Volatile
        private var instancia: FiltrosDbHelper? = null

        // Instancia única para el servicio y la interfaz: dos conexiones que
        // escriben a la vez pueden chocar, y los avisos del registro no llegarían
        // de un objeto a otro. Se usa applicationContext para no retener una Activity.
        fun obtener(context: Context): FiltrosDbHelper =
            instancia ?: synchronized(this) {
                instancia ?: FiltrosDbHelper(context.applicationContext).also { instancia = it }
            }
    }
}