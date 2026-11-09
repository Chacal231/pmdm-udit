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
    private val db by lazy { FiltrosDbHelper.obtener(applicationContext) }
    private val preferencias by lazy { Preferencias(applicationContext) }

    // Android llama a este método automáticamente por cada llamada.
    override fun onScreenCall(callDetails: Call.Details) {

        // Solo filtramos llamadas entrantes (no las que haces tú).
        val esEntrante = callDetails.callDirection == Call.Details.DIRECTION_INCOMING

        // handle = la dirección de la llamada, algo como "tel:+34400123456".
        // schemeSpecificPart nos devuelve solo el número. Si es un número
        // oculto, viene vacío y no lo bloqueamos.
        val numero = callDetails.handle?.schemeSpecificPart.orEmpty()

        // Leemos las reglas de SQLite EN CADA LLAMADA.
        // Así, cualquier cambio hecho en la pantalla se aplica al instante,
        // sin reiniciar nada.
        // runCatching: abrir la BD puede lanzar una migración, y una excepción aquí
        // dejaría la llamada sin respuesta. Si la BD falla se PERMITE la llamada:
        // perder un bloqueo es mejor que rechazar a ciegas una llamada legítima.
        val resultado = if (esEntrante) {
            runCatching {
                val numeros = db.obtenerNumeros()
                ReglaBloqueo.decidir(
                    numero = numero,
                    listaBlanca = numeros.deTipo(TipoNumero.LISTA_BLANCA),
                    numerosBloqueados = numeros.deTipo(TipoNumero.BLOQUEADO),
                    prefijos = db.prefijosActivos()
                )
            }
                .onFailure { Log.e("Filtro400", "No se pudieron leer las reglas", it) }
                .getOrNull()
        } else {
            null
        }
        val bloquear = resultado?.bloquear == true

        // Para depurar: la decisión queda en Logcat (filtra por "Filtro400").
        // Privacidad: el número se registra ENMASCARADO, nunca completo.
        Log.d(
            "Filtro400",
            "Llamada de ${ReglaBloqueo.enmascarar(numero)} -> " +
                    if (bloquear) "BLOQUEADA" else "PERMITIDA"
        )

        // runCatching: si falla el contador, la llamada debe seguir bloqueándose.
        // Contar es secundario; responder a Android, no.
        if (bloquear) runCatching { preferencias.incrementarBloqueadas() }

        // Va por separado del contador para que un fallo en uno no afecte al otro.
        // Se escribe antes de responder porque después Android puede matar el proceso.
        if (esEntrante) {
            val motivo = resultado?.motivo ?: RegistroActividad.MOTIVO_SIN_COINCIDENCIA
            runCatching { db.registrar(numero, bloquear, motivo) }
                .onFailure { Log.e("Filtro400", "No se pudo guardar el registro", it) }
        }

        // Siempre hay que responder, también cuando dejamos pasar la llamada.
        val respuesta = CallResponse.Builder()
            .setDisallowCall(bloquear)      // impide que suene
            .setRejectCall(bloquear)        // la rechaza
            .setSkipNotification(bloquear)  // sin notificación de llamada perdida
            .build()

        respondToCall(callDetails, respuesta)
    }
}