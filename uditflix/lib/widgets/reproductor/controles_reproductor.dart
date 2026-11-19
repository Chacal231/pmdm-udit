// CONTROLES DEL REPRODUCTOR

// Capa que se dibuja encima del vídeo con todos los botones.
// No contiene lógica: recibe el estado del vídeo (VideoPlayerValue) y
// avisa de cada acción mediante callbacks. La pantalla del reproductor
// decide qué hacer. Separar "cómo se ve" de "qué hace" facilita
// entender y mantener el código.
//
//   Arriba:  ← Atrás · Título
//   Centro:  ⟲10   ▶/❚❚   10⟳
//   Abajo:   barra de progreso (con buffer) · 01:23 / 09:56 · 1× · salir

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';
import '../../utils/formato.dart';

// Velocidades que ofrece el selector.
const List<double> velocidadesDisponibles = [0.5, 0.75, 1, 1.25, 1.5, 2];

class ControlesReproductor extends StatelessWidget {
  const ControlesReproductor({
    super.key,
    required this.titulo,
    required this.valor,
    required this.reproduciendo,
    required this.cargandoDatos,
    required this.velocidad,
    required this.arrastre,
    required this.usandoRespaldo,
    required this.onVolver,
    required this.onPlayPausa,
    required this.onRetroceder,
    required this.onAvanzar,
    required this.onArrastreInicio,
    required this.onArrastre,
    required this.onArrastreFin,
    required this.onVelocidad,
    required this.onMenuAbierto,
    required this.onMenuCerrado,
  });

  final String titulo;
  // Estado actual del vídeo: posición, duración y buffer.
  final VideoPlayerValue valor;
  // Si el usuario quiere que suene (icono de pausa) o no (icono de play).
  final bool reproduciendo;
  // Si el vídeo está esperando datos (se muestra un spinner).
  final bool cargandoDatos;
  final double velocidad;
  // Posición (0-1) mientras el usuario arrastra la barra; null si no arrastra.
  final double? arrastre;
  final bool usandoRespaldo;

  final VoidCallback onVolver;
  final VoidCallback onPlayPausa;
  final VoidCallback onRetroceder;
  final VoidCallback onAvanzar;
  final ValueChanged<double> onArrastreInicio;
  final ValueChanged<double> onArrastre;
  final ValueChanged<double> onArrastreFin;
  final ValueChanged<double> onVelocidad;
  final VoidCallback onMenuAbierto;
  final VoidCallback onMenuCerrado;

  @override
  Widget build(BuildContext context) {
    final total = valor.duration;
    final milisTotal = total.inMilliseconds;
    // Fracción reproducida y fracción descargada (buffer), entre 0 y 1.
    final progreso = milisTotal == 0
        ? 0.0
        : (valor.position.inMilliseconds / milisTotal).clamp(0.0, 1.0);
    var finBuffer = 0;
    for (final rango in valor.buffered) {
      if (rango.end.inMilliseconds > finBuffer) {
        finBuffer = rango.end.inMilliseconds;
      }
    }
    final buffer = milisTotal == 0
        ? 0.0
        : (finBuffer / milisTotal).clamp(0.0, 1.0);
    final posicionMostrada = arrastre == null
        ? valor.position
        : total * arrastre!;

    return DecoratedBox(
      // Degradados arriba y abajo para que los controles se lean bien
      // sobre cualquier imagen del vídeo.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColores.sombra(0.75),
            AppColores.sombra(0.15),
            AppColores.sombra(0.15),
            AppColores.sombra(0.8),
          ],
          stops: const [0, 0.3, 0.65, 1],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspacios.l),
          child: Column(
            children: [
              // ---------- Parte superior ----------
              Row(
                children: [
                  IconButton(
                    tooltip: 'Volver',
                    onPressed: onVolver,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppEspacios.s),
                  Expanded(
                    child: Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTexto.tituloSeccion,
                    ),
                  ),
                  if (usandoRespaldo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppEspacios.s,
                        vertical: AppEspacios.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.sombra(0.5),
                        borderRadius: BorderRadius.circular(AppRadios.pastilla),
                        border: Border.all(color: AppColores.textoTerciario),
                      ),
                      child: const Text(
                        'Vídeo de respaldo',
                        style: AppTexto.pequeno,
                      ),
                    ),
                ],
              ),

              // ---------- Centro ----------
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BotonSalto(
                      icono: Icons.replay_10_rounded,
                      tooltip: 'Retroceder 10 segundos',
                      onPressed: onRetroceder,
                    ),
                    const SizedBox(width: AppEspacios.xxxl),
                    _BotonPlay(
                      reproduciendo: reproduciendo,
                      cargandoDatos: cargandoDatos,
                      onPressed: onPlayPausa,
                    ),
                    const SizedBox(width: AppEspacios.xxxl),
                    _BotonSalto(
                      icono: Icons.forward_10_rounded,
                      tooltip: 'Avanzar 10 segundos',
                      onPressed: onAvanzar,
                    ),
                  ],
                ),
              ),

              // ---------- Parte inferior ----------
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: AppColores.rojo,
                  secondaryActiveTrackColor: AppColores.texto.withValues(
                    alpha: 0.45,
                  ),
                  inactiveTrackColor: AppColores.texto.withValues(alpha: 0.2),
                  thumbColor: AppColores.rojo,
                  overlayColor: AppColores.rojo.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                ),
                child: Slider(
                  value: arrastre ?? progreso,
                  secondaryTrackValue: buffer,
                  onChangeStart: onArrastreInicio,
                  onChanged: onArrastre,
                  onChangeEnd: onArrastreFin,
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: AppEspacios.s),
                  Text(
                    '${formatearTiempo(posicionMostrada)} / '
                    '${formatearTiempo(total)}',
                    style: AppTexto.etiqueta.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<double>(
                    tooltip: 'Velocidad de reproducción',
                    initialValue: velocidad,
                    color: AppColores.superficieAlta,
                    onOpened: onMenuAbierto,
                    onCanceled: onMenuCerrado,
                    onSelected: onVelocidad,
                    itemBuilder: (context) => [
                      for (final v in velocidadesDisponibles)
                        CheckedPopupMenuItem<double>(
                          value: v,
                          checked: v == velocidad,
                          child: Text(
                            v == 1 ? '1× (normal)' : formatearVelocidad(v),
                          ),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(AppEspacios.s),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speed_rounded, size: 22),
                          const SizedBox(width: AppEspacios.xs),
                          Text(
                            formatearVelocidad(velocidad),
                            style: AppTexto.etiqueta,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Salir de pantalla completa',
                    onPressed: onVolver,
                    icon: const Icon(Icons.fullscreen_exit_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonSalto extends StatelessWidget {
  const _BotonSalto({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: 40,
      onPressed: onPressed,
      icon: Icon(icono),
    );
  }
}

// Botón central grande. Mientras el vídeo carga datos (buffering)
// se convierte en un indicador de carga rojo.
class _BotonPlay extends StatelessWidget {
  const _BotonPlay({
    required this.reproduciendo,
    required this.cargandoDatos,
    required this.onPressed,
  });

  final bool reproduciendo;
  final bool cargandoDatos;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (cargandoDatos) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: Padding(
          padding: EdgeInsets.all(AppEspacios.m),
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }
    return IconButton(
      tooltip: reproduciendo ? 'Pausar' : 'Reproducir',
      iconSize: 64,
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: AppDuraciones.rapida,
        transitionBuilder: (hijo, animacion) =>
            ScaleTransition(scale: animacion, child: hijo),
        child: Icon(
          reproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded,
          key: ValueKey(reproduciendo),
        ),
      ),
    );
  }
}
