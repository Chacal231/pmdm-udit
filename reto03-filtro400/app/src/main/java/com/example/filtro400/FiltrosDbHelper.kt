package com.example.filtro400

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

// SQLiteOpenHelper: clase de Android que crea la base de datos la primera vez
// y nos da acceso a ella después. Aquí vive el CRUD de los filtros.
class FiltrosDbHelper(context: Context) :
    SQLiteOpenHelper(context, NOMBRE_BD, null, VERSION_BD) {

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
    }

    // Se ejecutaría al subir VERSION_BD (en la Fase 3: listas blancas, registro...).
    override fun onUpgrade(db: SQLiteDatabase, versionAnterior: Int, versionNueva: Int) {}

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
    fun insertar(prefijo: String): Boolean {
        val valores = ContentValues().apply {
            put(COL_PREFIJO, prefijo)
            put(COL_ACTIVO, 1)
        }
        return writableDatabase.insert(TABLA, null, valores) != -1L
    }

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

    companion object {
        private const val NOMBRE_BD = "filtro400.db"
        private const val VERSION_BD = 1
        private const val TABLA = "filtros"
        private const val COL_ID = "id"
        private const val COL_PREFIJO = "prefijo"
        private const val COL_ACTIVO = "activo"
    }
}