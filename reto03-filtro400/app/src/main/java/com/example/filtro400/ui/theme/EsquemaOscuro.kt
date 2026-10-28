package com.example.filtro400.ui.theme
 
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
 
// Paleta propia de la app: azul marino + turquesa.
// No usamos el color dinámico de Android para que SIEMPRE se vea igual.
private val EsquemaOscuro = darkColorScheme(
    primary = Color(0xFF00BFA6),
    onPrimary = Color(0xFF04122A),
    primaryContainer = Color(0xFF0F4A44),
    onPrimaryContainer = Color(0xFFB2F5EA),
    secondary = Color(0xFF7FB2FF),
    background = Color(0xFF0B1F3A),
    onBackground = Color(0xFFE6EEF8),
    surface = Color(0xFF10294B),
    onSurface = Color(0xFFE6EEF8),
    surfaceVariant = Color(0xFF173660),
    onSurfaceVariant = Color(0xFFB8C7DB),
    error = Color(0xFFFF6B6B),
    errorContainer = Color(0xFF5C1F28),
    onErrorContainer = Color(0xFFFFDAD6)
)
 
private val EsquemaClaro = lightColorScheme(
    primary = Color(0xFF0B1F3A),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFBFF5EC),
    onPrimaryContainer = Color(0xFF00332D),
    secondary = Color(0xFF00897B),
    background = Color(0xFFF4F8FC),
    onBackground = Color(0xFF0B1F3A),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF0B1F3A),
    surfaceVariant = Color(0xFFE3ECF6),
    onSurfaceVariant = Color(0xFF3A4D66),
    error = Color(0xFFB3261E),
    errorContainer = Color(0xFFFCE4E1),
    onErrorContainer = Color(0xFF5C0F0A)
)
 
// Sigue el modo claro/oscuro del sistema.
@Composable
fun EscudoTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) EsquemaOscuro else EsquemaClaro,
        content = content
    )
}