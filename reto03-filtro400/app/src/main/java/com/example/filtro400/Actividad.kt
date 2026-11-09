package com.example.filtro400

// Lógica pura del registro de actividad: sin clases de Android, para poder
// comprobar con tests unitarios lo más delicado, que es la privacidad.

// La decisión se guarda en SQLite por su nombre ("BLOQUEADA"), que es legible y
// no cambia aunque algún día se reordenen las opciones.
enum class DecisionLlamada(val etiqueta: String) {
    BLOQUEADA("Bloqueada"),
    PERMITIDA("Permitida");

    companion object {
        // Si el valor guardado no se reconoce, mostramos "Permitida" en vez de
        // hacer fallar la pantalla entera por una sola fila.
        fun desdeNombre(nombre: String?): DecisionLlamada =
            entries.firstOrNull { it.name == nombre } ?: PERMITIDA
    }
}

// Una fila del registro. Solo existe el número enmascarado: el completo nunca
// llega a este modelo.
data class EntradaActividad(
    val id: Long = 0,
    val fecha: Long,
    val numeroEnmascarado: String,
    val decision: DecisionLlamada,
    val motivo: String
)

object RegistroActividad {

    // El registro no puede crecer sin límite: la base de datos solo conserva
    // este número de entradas, las más recientes.
    const val MAX_ENTRADAS = 500

    const val MOTIVO_SIN_COINCIDENCIA = "Sin coincidencia"
    const val MOTIVO_LISTA_BLANCA = "Lista blanca"
    const val MOTIVO_NUMERO_CONCRETO = "Número concreto"

    private const val MAX_CIFRAS_PREFIJO_VISIBLE = 3

    // El número enmascarado ya enseña sus 3 primeras cifras y las 3 últimas. Si el
    // motivo mostrara más cifras del prefijo, rellenaría justo el hueco oculto:
    // "600***456" junto a "Prefijo 600123" revelaría el número entero.
    fun motivoPrefijo(prefijo: String): String {
        val visible = if (prefijo.length > MAX_CIFRAS_PREFIJO_VISIBLE) {
            prefijo.take(MAX_CIFRAS_PREFIJO_VISIBLE) + "***"
        } else {
            prefijo
        }
        return "Prefijo $visible"
    }

    // Único punto donde nace una entrada a partir de un número real. Enmascarar
    // aquí, y no en quien la llama, impide que nadie se olvide de hacerlo.
    fun crear(numero: String, bloqueada: Boolean, motivo: String, fecha: Long): EntradaActividad {
        val enmascarado = ReglaBloqueo.enmascarar(numero)
        val normalizado = ReglaBloqueo.normalizar(numero)

        // Caso límite: si el número es idéntico a un prefijo corto (llamada del
        // "400" con el prefijo 400), el motivo lo revelaría entero. La comprobación
        // de vacío es necesaria: replace("", ...) insertaría texto entre cada letra.
        val motivoSeguro = if (normalizado.isNotEmpty()) {
            motivo.replace(normalizado, enmascarado)
        } else {
            motivo
        }

        return EntradaActividad(
            fecha = fecha,
            numeroEnmascarado = enmascarado,
            decision = if (bloqueada) DecisionLlamada.BLOQUEADA else DecisionLlamada.PERMITIDA,
            motivo = motivoSeguro
        )
    }
}
