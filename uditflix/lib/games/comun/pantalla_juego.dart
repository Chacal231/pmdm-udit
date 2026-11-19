// PANTALLA QUE ALOJA UN JUEGO

// Es la "carcasa" Flutter de cualquier juego del Arcade:
//   - Pone la pantalla en vertical e inmersiva al entrar y la restaura
//     al salir.
//   - Muestra el juego con GameWidget y registra sus capas de Flutter
//     (HUD, inicio, pausa y Game Over) en overlayBuilderMap.
//   - Si la app pasa a segundo plano, pausa el juego automáticamente.
//   - Al salir, GameWidget libera el juego (Flame llama a onDispose).

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../services/sistema_pantalla.dart';
import '../../theme/app_theme.dart';
import 'juego_arcade.dart';
import 'overlay_fin_partida.dart';
import 'overlays_juego.dart';

class PantallaJuego extends StatefulWidget {
  const PantallaJuego({super.key, required this.crearJuego});

  // Función que crea el juego. Se llama una sola vez, al abrir la pantalla.
  final JuegoArcade Function() crearJuego;

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego>
    with WidgetsBindingObserver {
  late final JuegoArcade _juego = widget.crearJuego();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SistemaPantalla.modoJuego();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // "inactive" llega antes que "paused": pausamos lo antes posible
    // (por ejemplo, al bajar la cortina de notificaciones).
    if (estado != AppLifecycleState.resumed) _juego.pausar();
  }

  void _alSalir() {
    _juego.pauseEngine();
    SistemaPantalla.modoNormal();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (seHaCerrado, _) {
        if (seHaCerrado) _alSalir();
      },
      child: Scaffold(
        backgroundColor: PaletaArcade.espacio,
        body: GameWidget<JuegoArcade>(
          game: _juego,
          loadingBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          overlayBuilderMap: {
            OverlaysJuego.hud: (context, juego) => HudJuego(juego: juego),
            OverlaysJuego.inicio: (context, juego) =>
                OverlayInicio(juego: juego),
            OverlaysJuego.pausa: (context, juego) => OverlayPausa(juego: juego),
            OverlaysJuego.fin: (context, juego) =>
                OverlayFinPartida(juego: juego),
          },
          initialActiveOverlays: const [
            OverlaysJuego.hud,
            OverlaysJuego.inicio,
          ],
        ),
      ),
    );
  }
}
