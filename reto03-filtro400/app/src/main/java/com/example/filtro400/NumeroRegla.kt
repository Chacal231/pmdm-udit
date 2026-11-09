package com.example.filtro400

// Las dos listas de números concretos. Se guardan en SQLite por su nombre
// ("LISTA_BLANCA"), que es legible y no cambia si se reordenan las opciones.
enum class TipoNumero(val etiqueta: String, val textoVacio: String) {
    BLOQUEADO("Números bloqueados", "Ningún número concreto bloqueado."),
    LISTA_BLANCA("Lista blanca", "Ningún número en la lista blanca.");

    companion object {
        // Ante un valor desconocido se elige la opción que nunca rechaza una
        // llamada: mejor dejarla pasar que bloquearla a ciegas.
        fun desdeNombre(nombre: String?): TipoNumero =
            entries.firstOrNull { it.name == nombre } ?: LISTA_BLANCA
    }
}

// Una fila de la tabla "numeros". Aquí el número va completo porque hace falta
// para comparar: es configuración del usuario, no registro, y nunca va a Logcat.
data class NumeroRegla(
    val id: Long,
    val numero: String,
    val tipo: TipoNumero
)

// El servicio y el probador necesitan las dos listas por separado: al compartir
// esta función, no pueden repartirlas de forma distinta.
fun List<NumeroRegla>.deTipo(tipo: TipoNumero): List<String> =
    filter { it.tipo == tipo }.map { it.numero }
