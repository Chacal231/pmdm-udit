package com.example.filtro400

// Lo que devuelve el motor: qué hacer con la llamada y por qué.
data class ResultadoDecision(val bloquear: Boolean, val motivo: String)

// "object" = una única instancia, sin necesidad de crearla con ReglaBloqueo().
// Aquí vive la decisión de bloquear o no: sin Android, sin pantalla.
// Los prefijos llegan como parámetro (los lee la base de datos), así que
// esta clase es fácil de probar con tests unitarios.
object ReglaBloqueo {

    private const val MIN_CIFRAS_NUMERO = 3

    // Un mismo número puede llegar de varias formas:
    // "400123456", "+34400123456", "0034 400 123 456", "+34 400 123 456"...
    // Lo dejamos siempre en el mismo formato antes de comparar.
    fun normalizar(numero: String): String {
        // Nos quedamos solo con dígitos y el signo "+" (fuera espacios y guiones).
        val limpio = numero.filter { it.isDigit() || it == '+' }
        return when {
            limpio.startsWith("+34") -> limpio.removePrefix("+34")
            limpio.startsWith("0034") -> limpio.removePrefix("0034")
            else -> limpio
        }
    }

    // Limpia el prefijo que escribe el usuario: solo dígitos (admite "+34 400").
    fun limpiarPrefijo(texto: String): String =
        normalizar(texto).filter { it.isDigit() }

    // Devuelve el prefijo que coincide con el número, o null si ninguno.
    // Número oculto (vacío) -> null: no se bloquea.
    fun prefijoCoincidente(numero: String, prefijos: List<String>): String? {
        val n = normalizar(numero)
        if (n.isEmpty()) return null
        return prefijos.firstOrNull { it.isNotEmpty() && n.startsWith(it) }
    }

    // Misma firma que antes: la usa el servicio de llamadas.
    fun debeBloquearse(numero: String, prefijos: List<String>): Boolean =
        prefijoCoincidente(numero, prefijos) != null

    // Limpia un número escrito por el usuario. A diferencia del prefijo, conserva
    // el "+" inicial de los números extranjeros, porque normalizar() también lo
    // conserva en las llamadas: sin él, "+44..." nunca coincidiría.
    fun limpiarNumero(texto: String): String {
        val n = normalizar(texto)
        val cifras = n.filter { it.isDigit() }
        return if (n.startsWith("+")) "+$cifras" else cifras
    }

    // Se cuentan cifras, no caracteres: "+" o "+34" no son números válidos.
    fun esNumeroValido(texto: String): Boolean =
        limpiarNumero(texto).count { it.isDigit() } >= MIN_CIFRAS_NUMERO

    // El motor completo. El servicio y el probador usan esta misma función, así
    // que no pueden contradecirse. El orden importa: la lista blanca va primero
    // para que una excepción puntual gane siempre a cualquier regla de bloqueo.
    fun decidir(
        numero: String,
        listaBlanca: List<String>,
        numerosBloqueados: List<String>,
        prefijos: List<String>
    ): ResultadoDecision {
        val n = normalizar(numero)
        // Número oculto: no hay nada con lo que comparar, así que no se bloquea.
        if (n.isEmpty()) {
            return ResultadoDecision(false, RegistroActividad.MOTIVO_SIN_COINCIDENCIA)
        }

        // Se normalizan los dos lados para que "+34600..." y "600..." coincidan.
        fun estaEn(lista: List<String>) = lista.any { normalizar(it) == n }

        val prefijo = prefijoCoincidente(numero, prefijos)
        return when {
            estaEn(listaBlanca) ->
                ResultadoDecision(false, RegistroActividad.MOTIVO_LISTA_BLANCA)
            estaEn(numerosBloqueados) ->
                ResultadoDecision(true, RegistroActividad.MOTIVO_NUMERO_CONCRETO)
            prefijo != null ->
                ResultadoDecision(true, RegistroActividad.motivoPrefijo(prefijo))
            else ->
                ResultadoDecision(false, RegistroActividad.MOTIVO_SIN_COINCIDENCIA)
        }
    }

    // Privacidad: un número de teléfono es un dato personal. Cuando hay que
    // dejar constancia (Logcat, registros) usamos una versión enmascarada:
    // "+34 400 123 456" -> "400***456". Números muy cortos -> "***".
    fun enmascarar(numero: String): String {
        val n = normalizar(numero)
        return if (n.length <= 6) "***" else n.take(3) + "***" + n.takeLast(3)
    }
}