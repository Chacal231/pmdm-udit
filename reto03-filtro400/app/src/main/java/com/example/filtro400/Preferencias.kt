package com.example.filtro400

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import com.example.filtro400.ui.theme.ModoTema

// SharedPreferences guarda ajustes sencillos (clave -> valor) en un archivo privado
// de la app. Esta clase esconde las claves para que el resto del código no las
// repita y no pueda equivocarse al escribirlas.
class Preferencias(context: Context) {

    private val prefs =
        context.getSharedPreferences(NOMBRE_ARCHIVO, Context.MODE_PRIVATE)

    // Se guarda el nombre del enum ("OSCURO"), que es legible y no cambia
    // aunque algún día se reordenen las opciones.
    var modoTema: ModoTema
        get() = ModoTema.desdeNombre(prefs.getString(CLAVE_TEMA, null))
        set(valor) = prefs.edit { putString(CLAVE_TEMA, valor.name) }

    // Solo guardamos cuántas llamadas se han bloqueado, nunca qué números eran.
    val bloqueadas: Int
        get() = prefs.getInt(CLAVE_BLOQUEADAS, 0)

    // commit = true escribe en disco antes de seguir. Con apply() la escritura
    // queda para más tarde, y Android puede matar el proceso del servicio nada
    // más responder a la llamada: se perdería la cuenta.
    fun incrementarBloqueadas() {
        prefs.edit(commit = true) { putInt(CLAVE_BLOQUEADAS, bloqueadas + 1) }
    }

    // Avisa cada vez que cambia el contador y devuelve la función para dejar de
    // escuchar. Android guarda el listener con una referencia débil: esa función
    // mantiene viva la referencia mientras quien observa la conserve.
    fun observarBloqueadas(alCambiar: (Int) -> Unit): () -> Unit {
        val listener = SharedPreferences.OnSharedPreferenceChangeListener { _, clave ->
            if (clave == CLAVE_BLOQUEADAS) alCambiar(bloqueadas)
        }
        prefs.registerOnSharedPreferenceChangeListener(listener)
        return { prefs.unregisterOnSharedPreferenceChangeListener(listener) }
    }

    companion object {
        private const val NOMBRE_ARCHIVO = "escudo_prefs"
        private const val CLAVE_TEMA = "modo_tema"
        private const val CLAVE_BLOQUEADAS = "llamadas_bloqueadas"
    }
}
