// TARJETA DE PÓSTER

// La pieza básica del catálogo: un póster vertical 2:3 con las esquinas
// redondeadas. Al pulsarlo se hunde un poco y abre la ficha, y la imagen
// "vuela" hasta la ficha gracias al widget Hero.
// Si recibe un progreso, se dibuja como tarjeta de "Continuar viendo":
// con un botón de play encima y la barra roja de lo que ya se ha visto.

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../navigation/navegacion.dart';
import '../theme/app_theme.dart';
import 'imagen_red.dart';
import 'pulsable.dart';

class TarjetaPoster extends StatelessWidget {
  const TarjetaPoster({
    super.key,
    required this.contenido,
    required this.heroTag,
    this.ancho,
    this.progreso,
  });

  final Contenido contenido;
  // Etiqueta única del Hero. Un mismo título puede aparecer en varias
  // filas, por eso incluye el nombre de la sección: "top10-7", "series-7"…
  final String heroTag;
  // Ancho fijo (en filas horizontales). En cuadrículas se deja a null.
  final double? ancho;
  // Fracción vista (0-1) para la fila "Continuar viendo".
  final double? progreso;

  @override
  Widget build(BuildContext context) {
    final esContinuar = progreso != null;
    return Pulsable(
      etiqueta: contenido.titulo,
      onTap: () => esContinuar
          ? reproducir(context, contenido)
          : abrirFicha(context, contenido, heroTag: heroTag),
      child: SizedBox(
        width: ancho,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: AppRadios.tarjeta,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImagenRed(
                    url: contenido.imagenUrl,
                    titulo: contenido.titulo,
                    anchoLogico: ancho ?? 160,
                  ),
                  if (esContinuar) _CapaContinuar(progreso: progreso!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Capa superpuesta de "Continuar viendo": oscurece la parte inferior,
// pinta un botón de play y la barra de progreso roja.
class _CapaContinuar extends StatelessWidget {
  const _CapaContinuar({required this.progreso});

  final double progreso;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColores.transparente, AppColores.velo(0.85)],
          stops: const [0.45, 1],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppEspacios.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColores.velo(0.5),
              border: Border.all(color: AppColores.texto, width: 1.5),
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 28),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progreso,
            minHeight: 3,
            color: AppColores.rojo,
            backgroundColor: AppColores.textoTerciario.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
