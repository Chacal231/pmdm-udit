package com.example.filtro400

import android.content.Context
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

    companion object {
        private const val NOMBRE_ARCHIVO = "escudo_prefs"
        private const val CLAVE_TEMA = "modo_tema"
    }
}
