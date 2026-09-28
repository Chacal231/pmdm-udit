package com.example.reto1_tarjetapresentacion

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.reto1_tarjetapresentacion.ui.theme.Reto1TarjetaPresentacionTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // Aplicamos el tema de colores a todo lo de dentro
            Reto1TarjetaPresentacionTheme {
                // Surface = el "lienzo" de fondeo que ocupa toda la pantalla
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

@Composable
fun TarjetaPresentacion() {
    // LocalContext: así un Composable "pide prestado" el conexto de Android
    // Lo necesitamos para poder abrir el navegador desde el botón.
    val context = LocalContext.current
    // 1. COLUMN: apila los elementos de arriba a abajo (como un flexbox vertical)
    Column(
        modifier = Modifier
            .fillMaxSize()          // ocupa toda la pantalla
            .padding(16.dp),        // margen para que nada toque los bordes
        horizontalAlignment = Alignment.CenterHorizontally,    // centra en el eje X
        verticalArrangement = Arrangement.Center                // centra en el eje Y
    ) {
        // 2. IMAGE: la foto de perfil
        // Requiere un archivo'foto-perfil' dentro del ras/drawable
        Image(
            painter = painterResource(id = R.drawable.foto_perfil),
            contentDescription = "Foto de perfil de usuario",  //para accesibilidad (lectores de
            modifier = Modifier
                .size(150.dp)       //tamaño fijo: 150x150
                .clip(CircleShape), //la recorta en forma de circulo
            contentScale = ContentScale.Crop  // rellena el circulo sin deformar la imagen
        )
        // Hueco vacio entre la imagen y el texto
        Spacer(modifier = Modifier.height(24.dp))

        // 3.TEXT: nombre
        Text(
            text = "Daniel Baeza",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold
        )

        //TEXT: rol o profesión
        Text(
            text = "Estudiante de DAM",  // cada alumno pone el suyo
            fontSize = 18.sp,
            color = MaterialTheme.colorScheme.secondary // color secundario del tema
        )

        //Hueco mas grande antes del boton
        Spacer(modifier = Modifier.height(32.dp))

        //4. BUTTON: enlace a Github
        Button(
            onClick = {
                //1. Intent ACTION_VIEW: le decimos a Android "quiero ver este recurso"
                //      y el sistema decide que app usar (normalmente, el navegador)
                //2. Uri.parse convierte el texto de la URL en el formato que android entiende
                //3. startActivity lanza esa acción
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/Chacal231"))
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth(0.8f)       //ocupa el 80% del ancho de pantalla
        ) {
            Text(text = "Mi Perfil de GitHub")
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