package com.example.filtro400

// Un filtro = una fila de la tabla "filtros" de la base de datos.
data class Filtro(
    val id: Long = 0,
    val prefijo: String,
    val activo: Boolean = true
)