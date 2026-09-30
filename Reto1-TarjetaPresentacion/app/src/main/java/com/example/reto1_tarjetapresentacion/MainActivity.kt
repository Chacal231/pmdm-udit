package com.example.reto1_tarjetapresentacion

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.reto1_tarjetapresentacion.ui.theme.Reto1TarjetaPresentacionTheme
import kotlinx.coroutines.delay
import kotlin.random.Random

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // Aplicamos el tema de colores a todo lo de dentro
            Reto1TarjetaPresentacionTheme {
                // Surface = el "lienzo" de fondo que ocupa toda la pantalla
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    // Aquí llamamos a NUESTRA función, la que dibuja la tarjeta
                    TarjetaPresentacion()
                }
            }
        }
    }
}


// FONDO ESTILO MATRIX 

@Composable
fun FondoMatrix(modifier: Modifier = Modifier) {
    val caracteres = remember { "01アイウエオカキクケコ{}[]<>/;=+*#$".toList() }
    val tamano = 38f   // tamaño de cada letra (súbelo para letras más grandes)
    val cola = 14      // largo de la estela de cada columna
    val offsets = remember { List(100) { Random.nextInt(0, 60) } }

    val paint = remember {
        android.graphics.Paint().apply {
            color = android.graphics.Color.rgb(0, 255, 70)   // verde Matrix
            textSize = tamano
            typeface = android.graphics.Typeface.MONOSPACE
            isAntiAlias = true
        }
    }

    // Contador que sube cada 90 ms y hace que todo "caiga"
    var frame by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) {
        while (true) {
            delay(90)   // menos = más rápido
            frame++
        }
    }

    Canvas(modifier = modifier) {
        val columnas = (size.width / tamano).toInt()
        val filas = (size.height / tamano).toInt()

        drawIntoCanvas { canvas ->
            for (i in 0 until columnas) {
                val cabeza = (frame + offsets[i % offsets.size]) % (filas + cola)
                for (t in 0 until cola) {
                    val fila = cabeza - t
                    if (fila in 0 until filas) {
                        // cuanto más lejos de la cabeza, más transparente
                        // el 0.35f controla lo "suave" que se ve (súbelo para más intensidad)
                        paint.alpha = (255 * (1f - t / cola.toFloat()) * 0.35f).toInt()
                        val letra = caracteres[(i * 31 + fila * 17 + frame / 3) % caracteres.size]
                        canvas.nativeCanvas.drawText(
                            letra.toString(),
                            i * tamano,
                            (fila + 1) * tamano,
                            paint
                        )
                    }
                }
            }
        }
    }
}



// TARJETA DE PRESENTACIÓN

@Composable
fun TarjetaPresentacion() {
    // LocalContext: así un Composable "pide prestado" el contexto de Android
    // Lo necesitamos para poder abrir el navegador desde el botón.
    val context = LocalContext.current

    // BOX: apila cosas una encima de otra (fondo detrás, contenido delante)
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF020B02))   // negro con un toque verde
    ) {
        // Fondo animado estilo hacker
        FondoMatrix(modifier = Modifier.fillMaxSize())

        // 1. COLUMN: apila los elementos de arriba a abajo (como un flexbox vertical)
        Column(
            modifier = Modifier
                .fillMaxSize()          // ocupa toda la pantalla
                .padding(16.dp),        // margen para que nada toque los bordes
            horizontalAlignment = Alignment.CenterHorizontally,    // centra en el eje X
            verticalArrangement = Arrangement.Center               // centra en el eje Y
        ) {
            // 2. IMAGE: la foto de perfil
            // Requiere un archivo 'foto_perfil' dentro de res/drawable
            Image(
                painter = painterResource(id = R.drawable.foto_perfil),
                contentDescription = "Foto de perfil de usuario",  // para accesibilidad
                modifier = Modifier
                    .size(150.dp)       // tamaño fijo: 150x150
                    .clip(CircleShape), // la recorta en forma de círculo
                contentScale = ContentScale.Crop  // rellena el círculo sin deformar la imagen
            )
            // Hueco vacío entre la imagen y el texto
            Spacer(modifier = Modifier.height(24.dp))

            // 3. TEXT: nombre
            Text(
                text = "Daniel Baeza",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF00FF46)   // verde terminal
            )

            // TEXT: rol o profesión
            Text(
                text = "Estudiante de DAM",
                fontSize = 18.sp,
                color = Color.White
            )

            // Hueco más grande antes del botón
            Spacer(modifier = Modifier.height(32.dp))

            // 4. BUTTON: enlace a GitHub
            Button(
                onClick = {
                    // 1. Intent ACTION_VIEW: le decimos a Android "quiero ver este recurso"
                    //    y el sistema decide qué app usar (normalmente, el navegador)
                    // 2. Uri.parse convierte el texto de la URL en el formato que Android entiende
                    // 3. startActivity lanza esa acción
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/Chacal231"))
                    context.startActivity(intent)
                },
                modifier = Modifier.fillMaxWidth(0.8f),   // ocupa el 80% del ancho de pantalla
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFD32F2F),
                    contentColor = Color.White
                )
            ) {
                Text(text = "Mi Perfil de GitHub")
            }

            Spacer(modifier = Modifier.height(16.dp))

            // BUTTON: enlace a LinkedIn
            Button(
                onClick = {
                    val intent = Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("https://www.linkedin.com/in/daniel-baeza-jim%C3%A9nez-30b391438/")
                    )
                    context.startActivity(intent)
                },
                modifier = Modifier.fillMaxWidth(0.8f),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF0A66C2),
                    contentColor = Color.White
                )
            ) {
                Text("Ver mi LinkedIn")
            }

            Spacer(modifier = Modifier.height(16.dp))

            // BUTTON: enlace a Instagram
            Button(
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.instagram.com/dani__baeza/"))
                    context.startActivity(intent)
                },
                modifier = Modifier.fillMaxWidth(0.8f),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF2E7D32),
                    contentColor = Color.White
                )
            ) {
                Text(text = "Mi Perfil de Instagram")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun TarjetaPreview() {
    Reto1TarjetaPresentacionTheme {
        TarjetaPresentacion()
    }
}