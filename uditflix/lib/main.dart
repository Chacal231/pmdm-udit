import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/almacen_local.dart';
import 'services/sistema_pantalla.dart';
import 'theme/app_theme.dart';

// Punto de entrada de aplicación

Future<void> main() async {
  // Necesario para usar plugins (shared_preferences) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // Cargamos Mi lista, Continuar viendo y los récords guardados.
  await AlmacenLocal.instancia.iniciar();
  // En móviles la app va en vertical; el reproductor y los juegos
  // cambian la orientación al entrar y la restauran al salir.
  await SistemaPantalla.modoNormal();
  runApp(const MyApp());
}

// Widget principal de UDITflix

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Nombre de nuestra aplicación
      title: 'UDITflix',
      // Ocultamos la etiqueta DEBUG
      debugShowCheckedModeBanner: false,
      // Configuración visual general: el tema oscuro de lib/theme/app_theme.dart
      theme: AppTheme.oscuro,
      darkTheme: AppTheme.oscuro,
      themeMode: ThemeMode.dark,

      // Primera pantalla que verá el usuario: el splash animado,
      // que después da paso a la navegación principal (HomeShell).
      home: const SplashScreen(),
    );
  }
}
