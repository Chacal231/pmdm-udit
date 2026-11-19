// ORIENTACIÓN Y BARRAS DEL SISTEMA

// Centraliza cómo se muestra la app en cada momento:
//   - Modo normal: en móviles, solo en vertical (como las apps de
//     streaming); en tablets, libre. Barras del sistema visibles.
//   - Modo reproductor: siempre en horizontal y en modo inmersivo
//     (sin barra de estado ni de navegación).
// Así el reproductor y los juegos entran y salen siempre igual.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract final class SistemaPantalla {
  // Una tablet es un dispositivo cuyo lado más corto mide 600 dp o más.
  static bool get _esTablet {
    final vistas = WidgetsBinding.instance.platformDispatcher.views;
    if (vistas.isEmpty) return false;
    final vista = vistas.first;
    return vista.physicalSize.shortestSide / vista.devicePixelRatio >= 600;
  }

  static Future<void> modoNormal() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(
      _esTablet ? const [] : const [DeviceOrientation.portraitUp],
    );
  }

  static Future<void> modoReproductor() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
