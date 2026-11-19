// SISTEMA DE DISEÑO DE UDITFLIX

// En este archivo centralizamos TODO lo visual de la aplicación:
// colores, tipografía, radios, espaciados y duraciones de animación.
// Las pantallas nunca deben escribir colores "sueltos": siempre los
// toman de aquí. Así, si mañana queremos cambiar el rojo de la marca,
// solo hay que tocar una línea.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Paleta de colores de la aplicación.
// Usamos una clase con constantes estáticas para poder escribir,
// por ejemplo, AppColores.rojo desde cualquier pantalla.
abstract final class AppColores {
  // Fondo general de las pantallas (casi negro, ligeramente azulado).
  static const Color fondo = Color(0xFF0B0B0F);
  // Superficies: tarjetas, barras, hojas inferiores…
  static const Color superficie = Color(0xFF16161D);
  // Superficie un poco más clara para elementos elevados.
  static const Color superficieAlta = Color(0xFF1F1F28);

  // Rojo de marca de UDITflix.
  static const Color rojo = Color(0xFFE50914);
  // Rojo más oscuro para degradados y estados pulsados.
  static const Color rojoOscuro = Color(0xFF8C0610);

  // Textos.
  static const Color texto = Color(0xFFFFFFFF);
  static const Color textoSecundario = Color(0xFFB3B3B3);
  static const Color textoTerciario = Color(0xFF808080);

  // Verde del porcentaje de coincidencia ("97 % para ti").
  static const Color coincidencia = Color(0xFF46D369);

  // Acentos neón de la sección UDIT Arcade.
  static const Color neonCian = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFFF2E88);
  static const Color neonAmarillo = Color(0xFFFFE14D);
  static const Color neonVerde = Color(0xFF39FF88);
  static const Color neonVioleta = Color(0xFF9B5CFF);

  // Medallas del Game Over.
  static const Color bronce = Color(0xFFCD7F32);
  static const Color plata = Color(0xFFC9D1D9);
  static const Color oro = Color(0xFFFFC83D);
  static const Color platino = Color(0xFF9EE7FF);

  // Negro puro (reproductor de vídeo) y transparente.
  static const Color negro = Color(0xFF000000);
  static const Color transparente = Color(0x00000000);

  // Velo oscuro para degradados sobre imágenes.
  static Color velo(double opacidad) => fondo.withValues(alpha: opacidad);
  // Sombra negra pura (controles del reproductor sobre el vídeo).
  static Color sombra(double opacidad) => negro.withValues(alpha: opacidad);
}

// Paleta de los videojuegos del Arcade. Los juegos se dibujan por código,
// así que también sus colores viven aquí y no repartidos por los archivos.
abstract final class PaletaArcade {
  // ---------- UDIT Flap ----------
  static const Color cieloAlto = Color(0xFF1A0B3D);
  static const Color cieloMedio = Color(0xFF4B1A6B);
  static const Color cieloHorizonte = Color(0xFFE0457B);
  static const Color skylineLejano = Color(0xFF2B1650);
  static const Color skylineCercano = Color(0xFF160B2E);
  static const Color ventana = Color(0xFFFFD27A);
  static const Color suelo = Color(0xFF120A22);
  static const Color sueloRaya = Color(0xFF2A1A4A);
  static const Color palomita = Color(0xFFFFF4D6);
  static const Color palomitaSombra = Color(0xFFF2D58A);
  static const Color mantequilla = Color(0xFFFFC93C);
  static const Color contorno = Color(0xFF5A3A12);
  static const Color ojo = Color(0xFFFFFFFF);
  static const Color pupila = Color(0xFF1B1B1B);
  static const Color mejilla = Color(0xFFFF8FA3);
  static const Color pelicula = Color(0xFF15131C);
  static const Color peliculaFotograma = Color(0xFF241F33);
  static const Color peliculaAgujero = Color(0xFF3B3452);

  // ---------- Neon Breaker / Galaxy Run ----------
  static const Color espacio = Color(0xFF05040C);
  static const Color espacioClaro = Color(0xFF120B2B);
  static const Color rejilla = Color(0xFF2A1B5C);
  static const Color estrella = Color(0xFFFFFFFF);
  static const Color naveCuerpo = Color(0xFFE6F7FF);
  static const Color naveSombra = Color(0xFF7FA6C9);
  static const Color propulsor = Color(0xFFFF9F1C);
  static const Color enemigo = Color(0xFFB04BFF);
  static const Color meteorito = Color(0xFF7A6458);
  static const Color meteoritoSombra = Color(0xFF4A3B33);
}

// Espaciados estándar. Siempre múltiplos de 4 para mantener el ritmo visual.
abstract final class AppEspacios {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Margen lateral de las pantallas.
  static const double margenPantalla = 16;
}

// Radios de las esquinas redondeadas.
abstract final class AppRadios {
  static const double s = 4;
  static const double m = 8;
  static const double l = 12;
  static const double xl = 20;
  static const double pastilla = 999;

  static const BorderRadius tarjeta = BorderRadius.all(Radius.circular(m));
  static const BorderRadius boton = BorderRadius.all(Radius.circular(s));
  static const BorderRadius grande = BorderRadius.all(Radius.circular(l));
}

// Duraciones de las animaciones. Usarlas siempre desde aquí hace
// que toda la app tenga el mismo "ritmo".
abstract final class AppDuraciones {
  static const Duration rapida = Duration(milliseconds: 150);
  static const Duration media = Duration(milliseconds: 300);
  static const Duration lenta = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1800);
  static const Duration carrusel = Duration(seconds: 6);
  static const Duration ocultarControles = Duration(seconds: 3);
  static const Duration debounceBusqueda = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1400);
}

// Medidas que se adaptan al ancho de la pantalla (móvil o tablet).
// Así una misma pantalla se ve bien en 360 px y en una tablet de 1280 px.
abstract final class AppMedidas {
  // Ancho a partir del cual consideramos que es una tablet.
  static const double anchoTablet = 600;
  // Ancho máximo del contenido de lectura (ficha) en pantallas grandes.
  static const double anchoMaximoLectura = 840;

  // Ancho de los pósters de las filas horizontales.
  static double anchoPoster(double anchoPantalla) {
    if (anchoPantalla >= 1000) return 156;
    if (anchoPantalla >= anchoTablet) return 136;
    return 108;
  }

  // Número de columnas de las cuadrículas de pósters.
  static int columnasRejilla(double ancho) => (ancho / 124).floor().clamp(3, 8);

  // Altura del destacado: casi toda la pantalla, pero sin exagerar
  // en móviles muy alargados ni en tablets apaisadas.
  static double altoDestacado(Size pantalla) {
    final alto = pantalla.height * 0.7;
    final maximo = pantalla.width * 1.45;
    if (alto > maximo) return maximo;
    return alto < 360 ? 360 : alto;
  }
}

// Tipografía. Usamos la fuente del sistema (sin descargas) con una
// jerarquía fuerte: títulos muy gruesos y compactos, cuerpo ligero.
abstract final class AppTexto {
  static const TextStyle logo = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.2,
    color: AppColores.rojo,
    height: 1,
  );

  static const TextStyle tituloGrande = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    height: 1.05,
    color: AppColores.texto,
  );

  static const TextStyle titulo = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.1,
    color: AppColores.texto,
  );

  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColores.texto,
  );

  static const TextStyle cuerpo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColores.texto,
  );

  static const TextStyle cuerpoSecundario = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColores.textoSecundario,
  );

  static const TextStyle etiqueta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColores.texto,
  );

  static const TextStyle pequeno = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColores.textoTerciario,
  );

  static const TextStyle boton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}

// Construye el ThemeData oscuro que usa MaterialApp.
// Así los widgets de Material (botones, chips, barra de navegación…)
// ya salen con el aspecto de UDITflix sin configurarlos uno a uno.
abstract final class AppTheme {
  static ThemeData get oscuro {
    const esquema = ColorScheme.dark(
      primary: AppColores.rojo,
      onPrimary: AppColores.texto,
      secondary: AppColores.neonCian,
      onSecondary: AppColores.fondo,
      surface: AppColores.superficie,
      onSurface: AppColores.texto,
      surfaceContainerHighest: AppColores.superficieAlta,
      onSurfaceVariant: AppColores.textoSecundario,
      error: AppColores.rojo,
      outline: AppColores.textoTerciario,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColores.fondo,
      canvasColor: AppColores.fondo,
      splashFactory: InkSparkle.splashFactory,

      textTheme: const TextTheme(
        displaySmall: AppTexto.tituloGrande,
        headlineSmall: AppTexto.titulo,
        titleMedium: AppTexto.tituloSeccion,
        bodyMedium: AppTexto.cuerpo,
        bodySmall: AppTexto.cuerpoSecundario,
        labelLarge: AppTexto.boton,
        labelSmall: AppTexto.pequeno,
      ),

      // Barra superior transparente: cada pantalla decide su fondo.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColores.transparente,
        foregroundColor: AppColores.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTexto.tituloSeccion,
      ),

      // Barra de navegación inferior oscura con el indicador en rojo suave.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColores.superficie,
        indicatorColor: AppColores.rojo.withValues(alpha: 0.18),
        surfaceTintColor: AppColores.transparente,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => AppTexto.pequeno.copyWith(
            color: estados.contains(WidgetState.selected)
                ? AppColores.texto
                : AppColores.textoTerciario,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? AppColores.texto
                : AppColores.textoTerciario,
          ),
        ),
      ),

      // Botón principal: blanco con texto negro, como "Reproducir".
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColores.texto,
          foregroundColor: AppColores.fondo,
          textStyle: AppTexto.boton,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
          shape: const RoundedRectangleBorder(borderRadius: AppRadios.boton),
        ),
      ),

      // Botón secundario: gris translúcido.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColores.texto,
          backgroundColor: AppColores.textoTerciario.withValues(alpha: 0.35),
          side: BorderSide.none,
          textStyle: AppTexto.boton,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
          shape: const RoundedRectangleBorder(borderRadius: AppRadios.boton),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColores.texto,
          textStyle: AppTexto.boton,
        ),
      ),

      // Chips de filtro "Series" / "Películas".
      chipTheme: const ChipThemeData(
        backgroundColor: AppColores.transparente,
        selectedColor: AppColores.texto,
        labelStyle: AppTexto.etiqueta,
        side: BorderSide(color: AppColores.textoSecundario),
        shape: StadiumBorder(),
        showCheckmark: false,
      ),

      // Campo de texto del buscador.
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColores.superficieAlta,
        hintStyle: TextStyle(color: AppColores.textoTerciario),
        prefixIconColor: AppColores.textoSecundario,
        suffixIconColor: AppColores.textoSecundario,
        border: OutlineInputBorder(
          borderRadius: AppRadios.boton,
          borderSide: BorderSide.none,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColores.superficieAlta,
        contentTextStyle: AppTexto.etiqueta,
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColores.rojo,
        linearTrackColor: AppColores.superficieAlta,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColores.superficieAlta,
        thickness: 1,
      ),

      iconTheme: const IconThemeData(color: AppColores.texto),
    );
  }
}
