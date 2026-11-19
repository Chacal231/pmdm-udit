// CAPAS DE FLUTTER ENCIMA DE LOS JUEGOS

// Flame dibuja el juego; Flutter dibuja encima los menús con widgets
// normales (botones, textos, animaciones). Así aprovechamos lo mejor de
// cada uno. Estas capas son comunes a los tres juegos:
//   - HudJuego: botón de pausa, vidas, puntos y mensajes temporales.
//   - OverlayInicio: título e instrucciones antes de empezar.
//   - OverlayPausa: continuar, reiniciar o salir.
// La pantalla de Game Over está en overlay_fin_partida.dart.

import 'package:flutter/material.dart';

import '../../services/almacen_local.dart';
import '../../theme/app_theme.dart';
import 'juego_arcade.dart';

// ---------------------------------------------------------------------
// HUD
// ---------------------------------------------------------------------

class HudJuego extends StatelessWidget {
  const HudJuego({super.key, required this.juego});

  final JuegoArcade juego;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppEspacios.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // El botón de pausa solo aparece mientras se juega.
                ValueListenableBuilder<EstadoJuego>(
                  valueListenable: juego.estado,
                  builder: (context, estado, _) => AnimatedOpacity(
                    opacity: estado == EstadoJuego.jugando ? 1 : 0,
                    duration: AppDuraciones.rapida,
                    child: IgnorePointer(
                      ignoring: estado != EstadoJuego.jugando,
                      child: BotonNeon(
                        icono: Icons.pause_rounded,
                        color: juego.acento,
                        tooltip: 'Pausa',
                        onTap: juego.pausar,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Vidas y puntos: IgnorePointer para que los toques
                // lleguen al juego aunque caigan encima del texto.
                IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (juego.puntosEnHud)
                        ValueListenableBuilder<int>(
                          valueListenable: juego.puntos,
                          builder: (context, valor, _) => Text(
                            '$valor',
                            style: estiloNeon(juego.acento, 30),
                          ),
                        ),
                      if (juego.usaVidas)
                        ValueListenableBuilder<int>(
                          valueListenable: juego.vidas,
                          builder: (context, valor, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < 3; i++)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppEspacios.xxs,
                                  ),
                                  child: Icon(
                                    i < valor
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: AppColores.neonMagenta,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Mensaje temporal centrado ("Nivel 2", "Oleada 3"…).
          IgnorePointer(
            child: Center(
              child: ValueListenableBuilder<String?>(
                valueListenable: juego.mensaje,
                builder: (context, texto, _) => AnimatedSwitcher(
                  duration: AppDuraciones.media,
                  transitionBuilder: (hijo, animacion) => ScaleTransition(
                    scale: Tween(begin: 0.6, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animacion,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: FadeTransition(opacity: animacion, child: hijo),
                  ),
                  child: texto == null
                      ? const SizedBox.shrink()
                      : Text(
                          texto,
                          key: ValueKey(texto),
                          textAlign: TextAlign.center,
                          style: estiloNeon(juego.acento, 40),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PANTALLA DE INICIO
// ---------------------------------------------------------------------

// No captura toques (IgnorePointer): el toque que la "cierra" llega al
// juego y es el que empieza la partida.
class OverlayInicio extends StatefulWidget {
  const OverlayInicio({super.key, required this.juego});

  final JuegoArcade juego;

  @override
  State<OverlayInicio> createState() => _OverlayInicioState();
}

class _OverlayInicioState extends State<OverlayInicio>
    with SingleTickerProviderStateMixin {
  // Late el texto "Toca para empezar" para llamar la atención.
  late final AnimationController _latido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final juego = widget.juego;
    final record = AlmacenLocal.instancia.recordDe(juego.idJuego);
    return IgnorePointer(
      child: SafeArea(
        // Algo por debajo del centro para no tapar al personaje.
        child: Align(
          alignment: const Alignment(0, 0.25),
          child: Padding(
            padding: const EdgeInsets.all(AppEspacios.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  juego.titulo,
                  textAlign: TextAlign.center,
                  style: estiloNeon(juego.acento, 42),
                ),
                const SizedBox(height: AppEspacios.s),
                Text(
                  juego.instrucciones,
                  textAlign: TextAlign.center,
                  style: AppTexto.cuerpo.copyWith(
                    shadows: [
                      Shadow(color: AppColores.sombra(0.8), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: AppEspacios.xxl),
                FadeTransition(
                  opacity: Tween(begin: 0.35, end: 1.0).animate(_latido),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: juego.acento),
                      const SizedBox(width: AppEspacios.s),
                      Text(
                        'Toca para empezar',
                        style: AppTexto.tituloSeccion.copyWith(
                          color: AppColores.texto,
                        ),
                      ),
                    ],
                  ),
                ),
                if (record > 0) ...[
                  const SizedBox(height: AppEspacios.l),
                  Text(
                    'Récord: $record',
                    style: AppTexto.etiqueta.copyWith(
                      color: AppColores.neonAmarillo,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PAUSA
// ---------------------------------------------------------------------

class OverlayPausa extends StatelessWidget {
  const OverlayPausa({super.key, required this.juego});

  final JuegoArcade juego;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColores.sombra(0.65),
      child: Center(
        child: TarjetaNeon(
          color: juego.acento,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pausa',
                textAlign: TextAlign.center,
                style: estiloNeon(juego.acento, 36),
              ),
              const SizedBox(height: AppEspacios.xl),
              BotonMenuJuego.principal(
                texto: 'Continuar',
                icono: Icons.play_arrow_rounded,
                color: juego.acento,
                onPressed: juego.reanudar,
              ),
              const SizedBox(height: AppEspacios.s),
              BotonMenuJuego.secundario(
                texto: 'Reiniciar',
                icono: Icons.replay_rounded,
                onPressed: juego.reiniciar,
              ),
              const SizedBox(height: AppEspacios.s),
              BotonMenuJuego.secundario(
                texto: 'Salir al Arcade',
                icono: Icons.logout_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PIEZAS VISUALES REUTILIZABLES
// ---------------------------------------------------------------------

// Texto con resplandor de neón.
TextStyle estiloNeon(Color color, double tamano) => TextStyle(
  fontSize: tamano,
  fontWeight: FontWeight.w900,
  letterSpacing: -tamano * 0.03,
  color: AppColores.texto,
  shadows: [
    Shadow(color: color, blurRadius: tamano * 0.35),
    Shadow(color: color.withValues(alpha: 0.6), blurRadius: tamano * 0.8),
  ],
);

// Botón redondo translúcido con borde de neón (pausa).
class BotonNeon extends StatelessWidget {
  const BotonNeon({
    super.key,
    required this.icono,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icono;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColores.sombra(0.35),
        shape: CircleBorder(side: BorderSide(color: color, width: 1.5)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppEspacios.s),
            child: Icon(icono, color: AppColores.texto),
          ),
        ),
      ),
    );
  }
}

// Tarjeta oscura con borde y brillo de neón (pausa y Game Over).
class TarjetaNeon extends StatelessWidget {
  const TarjetaNeon({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      margin: const EdgeInsets.all(AppEspacios.xl),
      padding: const EdgeInsets.all(AppEspacios.xl),
      decoration: BoxDecoration(
        color: AppColores.superficie.withValues(alpha: 0.96),
        borderRadius: AppRadios.grande,
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 28),
        ],
      ),
      child: child,
    );
  }
}

// Botones de los menús del juego.
class BotonMenuJuego extends StatelessWidget {
  const BotonMenuJuego.principal({
    super.key,
    required this.texto,
    required this.icono,
    required Color this.color,
    required this.onPressed,
  });

  const BotonMenuJuego.secundario({
    super.key,
    required this.texto,
    required this.icono,
    required this.onPressed,
  }) : color = null;

  final String texto;
  final IconData icono;
  // Con color es el botón principal (relleno); sin él, secundario.
  final Color? color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorPrincipal = color;
    if (colorPrincipal != null) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: colorPrincipal,
          foregroundColor: AppColores.fondo,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: onPressed,
        icon: Icon(icono),
        label: Text(texto),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: onPressed,
      icon: Icon(icono),
      label: Text(texto),
    );
  }
}
