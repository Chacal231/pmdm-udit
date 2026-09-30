Reto 1 · Tarjeta de Presentación Profesional

Módulo: 0489 · Programación Multimedia y Dispositivos Móviles Autor: Daniel Baeza (Chacal231) Tecnología: Kotlin + Jetpack Compose (Android nativo) RA vinculado: RA1 · Tecnologías de desarrollo para dispositivos móviles

📱 Qué es esta app

Una tarjeta de presentación digital (estilo Linktree) con una foto de perfil, un nombre, un rol profesional y tres botones que enlazan directamente a mis perfiles de GitHub, LinkedIn e Instagram.

La pantalla tiene un fondo animado estilo "Matrix" (letras verdes cayendo sobre fondo oscuro), dibujado íntegramente con código, sin imágenes externas.

Sustituye las capturas de abajo por las tuyas antes de entregar.

<!-- ![Captura de la app](captura.png) -->
🎯 Objetivo del reto

Partir de un proyecto Android base y modificarlo para construir una aplicación funcional propia, aplicando los conceptos vistos en clase: estructura de un proyecto Kotlin, componentes visuales de Jetpack Compose, gestión de recursos (imágenes e icono) y control de versiones con Git.

✨ Personalización añadida por mí
Tres botones de enlace (GitHub, LinkedIn e Instagram), cada uno con su propio color.
Fondo animado estilo hacker/Matrix con Canvas, que se redibuja cada pocos milisegundos.
Textos adaptados al fondo oscuro (nombre en verde terminal, rol en blanco).
Enlaces y datos personales cambiados por los míos (usuario de GitHub: Chacal231).
🛠️ Componentes y conceptos utilizados
Componente / concepto	Para qué se usa en esta app
Box	Apila el fondo animado detrás y el contenido delante
Column	Organiza los elementos en vertical (foto, nombre, rol, botones)
Image + clip(CircleShape)	Muestra la foto de perfil recortada en círculo
Text	Nombre y rol profesional
Spacer	Separación entre elementos
Button + ButtonDefaults.buttonColors	Tres botones con colores propios (containerColor y contentColor)
Intent + Uri	Al pulsar cada botón, abre el navegador (o la app) en el perfil correspondiente
Canvas + drawIntoCanvas	Dibuja el efecto Matrix del fondo
LaunchedEffect + mutableIntStateOf	Un contador que se actualiza cada 90 ms y hace que las letras "caigan"
res/drawable	Carpeta donde vive la imagen de perfil
res/mipmap (Image Asset Studio)	Icono personalizado de la app, sustituyendo al robot de Android por defecto
strings.xml (app_name)	Nombre visible de la app bajo el icono, en el móvil
🚀 Cómo ejecutar el proyecto
Clonar o abrir el proyecto en Android Studio.
Esperar a que sincronice Gradle.
Ejecutar (▶) sobre un emulador o un dispositivo Android real con la depuración USB activada.
🧠 Qué he aprendido
Cómo se estructura un proyecto Android/Kotlin con Jetpack Compose.
Cómo importar y organizar imágenes en res/drawable.
Cómo usar Box, Column, Image, Text, Spacer y Button para maquetar una pantalla.
Cómo personalizar los colores de un botón con ButtonDefaults.buttonColors.
Cómo lanzar una URL externa desde un botón usando Intent + Uri.
Cómo superponer un fondo animado detrás del contenido con Box y Canvas.
Cómo cambiar el icono de la app con Image Asset Studio (capa de fondo y capa de primer plano).
Cómo cambiar el nombre visible de la app en strings.xml, sin tocar el nombre del proyecto.
Cómo subir el proyecto a GitHub y resolver un push rechazado con git pull --rebase.
🐞 Dificultades y cómo las resolví
Error en el color del botón: usé container en vez de containerColor dentro de buttonColors, y me faltaba cerrar un paréntesis. Lo resolví corrigiendo el nombre del parámetro y revisando la estructura del Button.
Imports que faltaban: al pegar código nuevo, Android Studio marcaba en rojo Canvas, Box, etc. Lo resolví con Alt+Enter sobre cada palabra para que el IDE añadiera el import.
git push rechazado (fetch first): GitHub tenía commits que yo no tenía en local. Lo resolví haciendo git add -A, git commit, git pull --rebase y git push.
Cambios sin añadir por estar en una subcarpeta: git add . solo añade lo de la carpeta actual, y los archivos borrados de la carpeta superior se quedaban fuera. Lo resolví usando git add -A.
📂 Estructura del proyecto
app/src/main/java/.../MainActivity.kt   → pantalla principal (Compose): tarjeta + fondo Matrix
app/src/main/res/drawable/              → imagen de perfil
app/src/main/res/mipmap-*/              → icono de la app
app/src/main/res/values/strings.xml     → nombre visible de la app
🔗 Enlaces
GitHub: github.com/Chacal231
LinkedIn: Daniel Baeza Jiménez
Instagram: @dani__baeza
