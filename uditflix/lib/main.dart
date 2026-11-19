import 'package:flutter/material.dart';

import 'screens/catalogo_screen.dart';
import 'services/almacen_local.dart';
import 'theme/app_theme.dart';

// Punto de entrada de aplicación

Future<void> main() async {
  // Necesario para usar plugins (shared_preferences) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // Cargamos Mi lista, Continuar viendo y los récords guardados.
  await AlmacenLocal.instancia.iniciar();
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

      // Primera pantalla que verá el usuario
      home: const CatalogoScreen(),
    );
  }
}
