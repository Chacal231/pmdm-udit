package com.example.filtro400

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

// CallScreeningService: Android nos avisa de cada llamada entrante
// ANTES de que suene, y nosotros decidimos qué hacer con ella.
// Solo funciona con números que NO están en la agenda del usuario.
class FiltroLlamadasService : CallScreeningService() {

    // "by lazy": se crea la primera vez que se usa. Hace falta porque el
    // contexto del servicio aún no existe cuando se construye la clase.
    private val db by lazy { FiltrosDbHelper(applicationContext) }

    // Android llama a este método automáticamente por cada llamada.
    override fun onScreenCall(callDetails: Call.Details) {

        // Solo filtramos llamadas entrantes (no las que haces tú).
        val esEntrante = callDetails.callDirection == Call.Details.DIRECTION_INCOMING

        // handle = la dirección de la llamada, algo como "tel:+34400123456".
        // schemeSpecificPart nos devuelve solo el número. Si es un número
        // oculto, viene vacío y no lo bloqueamos.
        val numero = callDetails.handle?.schemeSpecificPart.orEmpty()

        // Fase 2: leemos los prefijos activos de SQLite EN CADA LLAMADA.
        // Así, cualquier cambio hecho en la pantalla se aplica al instante,
        // sin reiniciar nada.
        val bloquear = esEntrante &&
                ReglaBloqueo.debeBloquearse(numero, db.prefijosActivos())

        // Solo para depurar: ver la decisión en Logcat (filtra por "Filtro400").
        // Quítalo en una versión final: un número de teléfono es dato personal.
        Log.d("Filtro400", "Llamada de '$numero' -> ${if (bloquear) "BLOQUEADA" else "PERMITIDA"}")

        // Siempre hay que responder, también cuando dejamos pasar la llamada.
        val respuesta = CallResponse.Builder()
            .setDisallowCall(bloquear)      // impide que suene
            .setRejectCall(bloquear)        // la rechaza
            .setSkipNotification(bloquear)  // sin notificación de llamada perdida
            .build()

        respondToCall(callDetails, respuesta)
    }
}