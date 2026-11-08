package com.example.filtro400

// Las secciones de la barra inferior. Un enum basta para navegar sin librerías:
// la sección actual es un simple valor que decide qué pantalla se dibuja.
// El icono es un emoji porque androidx.compose.material.icons no está disponible
// en este proyecto.
enum class Seccion(val etiqueta: String, val emoji: String) {
    INICIO("Inicio", "🏠"),
    REGLAS("Reglas", "📋"),
    ACTIVIDAD("Actividad", "📊"),
    AJUSTES("Ajustes", "⚙️")
}
