// PANELES DEL REPRODUCTOR

// Pantallas que se superponen al vídeo según el momento:
//   - PanelCarga: mientras el vídeo se inicializa.
//   - PanelReanudar: "Reanudar desde mm:ss" o "Desde el principio".
//   - PanelFin: al terminar, "Ver de nuevo" y una sugerencia.
//   - PanelError: si no se puede cargar, con el botón "Reintentar".
//   - AvisoDiscreto: mensaje breve arriba (vídeo de respaldo, episodio
//     de demostración…).
// El reproductor va en horizontal y la altura disponible es pequeña,
// por eso todos los paneles son compactos y pueden desplazarse.

import 'package:flutter/material.dart';

import '../../models/contenido.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../imagen_red.dart';

// Estructura común: fondo del título muy oscurecido, botón de volver
// y el contenido centrado.
class _BasePanel extends StatelessWidget {
  const _BasePanel({
    required this.contenido,
    required this.onVolver,
    required this.child,
    this.opacidadFondo = 0.25,
  });

  final Contenido contenido;
  final VoidCallback onVolver;
  final Widget child;
  final double opacidadFondo;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColores.negro),
        Opacity(
          opacity: opacidadFondo,
          child: ImagenRed(url: contenido.fondoUrl, titulo: contenido.titulo),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppEspacios.l),
              child: child,
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppEspacios.s),
              child: IconButton(
                tooltip: 'Volver',
                onPressed: onVolver,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Indicador de carga: spinner rojo con el título.
class PanelCarga extends StatelessWidget {
  const PanelCarga({
    super.key,
    required this.contenido,
    required this.onVolver,
  });

  final Contenido contenido;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return _BasePanel(
      contenido: contenido,
      onVolver: onVolver,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(strokeWidth: 3.5),
          ),
          const SizedBox(height: AppEspacios.xl),
          Text(
            contenido.titulo,
            textAlign: TextAlign.center,
            style: AppTexto.titulo,
          ),
          const SizedBox(height: AppEspacios.xs),
          const Text('Cargando…', style: AppTexto.cuerpoSecundario),
        ],
      ),
    );
  }
}

// Pregunta si se quiere continuar donde se dejó.
class PanelReanudar extends StatelessWidget {
  const PanelReanudar({
    super.key,
    required this.contenido,
    required this.posicion,
    required this.onReanudar,
    required this.onDesdeInicio,
    required this.onVolver,
  });

  final Contenido contenido;
  final Duration posicion;
  final VoidCallback onReanudar;
  final VoidCallback onDesdeInicio;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return _BasePanel(
      contenido: contenido,
      onVolver: onVolver,
      opacidadFondo: 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            contenido.titulo,
            textAlign: TextAlign.center,
            style: AppTexto.titulo,
          ),
          const SizedBox(height: AppEspacios.xs),
          const Text(
            'Ya habías empezado a verlo',
            style: AppTexto.cuerpoSecundario,
          ),
          const SizedBox(height: AppEspacios.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppEspacios.m,
            runSpacing: AppEspacios.m,
            children: [
              FilledButton.icon(
                autofocus: true,
                onPressed: onReanudar,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Reanudar desde ${formatearTiempo(posicion)}'),
              ),
              OutlinedButton.icon(
                onPressed: onDesdeInicio,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Desde el principio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Pantalla de fin: volver a verlo o pasar a una sugerencia.
class PanelFin extends StatelessWidget {
  const PanelFin({
    super.key,
    required this.contenido,
    required this.sugerencia,
    required this.creditos,
    required this.onVerDeNuevo,
    required this.onSugerencia,
    required this.onVolver,
  });

  final Contenido contenido;
  final Contenido? sugerencia;
  final String creditos;
  final VoidCallback onVerDeNuevo;
  final VoidCallback onSugerencia;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    final otro = sugerencia;
    return _BasePanel(
      contenido: contenido,
      onVolver: onVolver,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppEspacios.xxxl,
        runSpacing: AppEspacios.xl,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contenido.titulo,
                  textAlign: TextAlign.center,
                  style: AppTexto.titulo,
                ),
                const SizedBox(height: AppEspacios.l),
                FilledButton.icon(
                  onPressed: onVerDeNuevo,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Ver de nuevo'),
                ),
                const SizedBox(height: AppEspacios.m),
                Text(
                  creditos,
                  textAlign: TextAlign.center,
                  style: AppTexto.pequeno,
                ),
              ],
            ),
          ),
          if (otro != null)
            SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'A CONTINUACIÓN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColores.rojo,
                    ),
                  ),
                  const SizedBox(height: AppEspacios.s),
                  ClipRRect(
                    borderRadius: AppRadios.tarjeta,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ImagenRed(
                        url: otro.fondoUrl,
                        titulo: otro.titulo,
                        anchoLogico: 260,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppEspacios.s),
                  Text(
                    otro.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTexto.tituloSeccion,
                  ),
                  const SizedBox(height: AppEspacios.s),
                  OutlinedButton.icon(
                    onPressed: onSugerencia,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Reproducir'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Error de carga con "Reintentar".
class PanelError extends StatelessWidget {
  const PanelError({
    super.key,
    required this.contenido,
    required this.onReintentar,
    required this.onVolver,
  });

  final Contenido contenido;
  final VoidCallback onReintentar;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return _BasePanel(
      contenido: contenido,
      onVolver: onVolver,
      opacidadFondo: 0.15,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColores.textoSecundario,
          ),
          const SizedBox(height: AppEspacios.l),
          const Text(
            'No se ha podido cargar el vídeo',
            textAlign: TextAlign.center,
            style: AppTexto.titulo,
          ),
          const SizedBox(height: AppEspacios.xs),
          const Text(
            'Comprueba tu conexión a Internet e inténtalo de nuevo.',
            textAlign: TextAlign.center,
            style: AppTexto.cuerpoSecundario,
          ),
          const SizedBox(height: AppEspacios.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppEspacios.m,
            runSpacing: AppEspacios.m,
            children: [
              FilledButton.icon(
                autofocus: true,
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
              OutlinedButton(onPressed: onVolver, child: const Text('Volver')),
            ],
          ),
        ],
      ),
    );
  }
}

// Aviso discreto en la parte superior que entra deslizándose.
class AvisoDiscreto extends StatelessWidget {
  const AvisoDiscreto({
    super.key,
    required this.visible,
    required this.texto,
    required this.icono,
  });

  final bool visible;
  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, -1.5),
            duration: AppDuraciones.media,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: AppDuraciones.media,
              child: Container(
                margin: const EdgeInsets.only(top: AppEspacios.m),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacios.l,
                  vertical: AppEspacios.s,
                ),
                decoration: BoxDecoration(
                  color: AppColores.superficieAlta.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppRadios.pastilla),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, size: 18, color: AppColores.textoSecundario),
                    const SizedBox(width: AppEspacios.s),
                    Flexible(child: Text(texto, style: AppTexto.etiqueta)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
