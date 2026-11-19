// NAVEGACIÓN ENTRE PANTALLAS

// Funciones de ayuda para abrir la ficha y el reproductor desde
// cualquier sitio (tarjetas, carrusel, búsqueda, Mi lista…) siempre
// con la misma transición.

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../screens/ficha_screen.dart';
import '../screens/reproductor_screen.dart';
import '../screens/trailer_screen.dart';
import 'transiciones.dart';

// Abre la ficha de un título. heroTag enlaza la portada de la tarjeta
// pulsada con la de la ficha para animar el "vuelo" de la imagen.
Future<void> abrirFicha(
  BuildContext context,
  Contenido contenido, {
  String? heroTag,
}) {
  return Navigator.of(
    context,
  ).push(rutaUdit<void>(FichaScreen(contenido: contenido, heroTag: heroTag)));
}

// Abre el reproductor de vídeo.
Future<void> reproducir(BuildContext context, Contenido contenido) {
  return Navigator.of(context)
      .push(rutaUdit<void>(ReproductorScreen(contenido: contenido)));
}

// Abre el tráiler oficial de YouTube (solo si el título tiene uno).
Future<void> verTrailer(BuildContext context, Contenido contenido) async {
  final videoId = contenido.trailerYoutubeId;
  if (videoId == null) return;
  await Navigator.of(
    context,
  ).push(rutaUdit<void>(TrailerScreen(contenido: contenido, videoId: videoId)));
}
