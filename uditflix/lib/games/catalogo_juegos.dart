// CATÁLOGO DE JUEGOS DEL ARCADE

// Igual que data/contenidos.dart describe las películas y series, este
// archivo describe los juegos: nombre, descripción, dificultad, color,
// cómo se dibuja su miniatura y cómo se crea el juego. La pantalla del
// Arcade solo recorre esta lista; añadir un juego nuevo es añadir un
// elemento aquí.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'breaker/breaker_game.dart';
import 'comun/juego_arcade.dart';
import 'flap/flap_game.dart';
import 'galaxy/galaxy_game.dart';
import 'miniaturas.dart';

class JuegoInfo {
  const JuegoInfo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.dificultad,
    required this.color,
    required this.pintor,
    required this.crearJuego,
  });

  final String id;
  final String titulo;
  final String descripcion;
  // De 1 (fácil) a 3 (difícil).
  final int dificultad;
  final Color color;
  final CustomPainter Function(Animation<double> animacion) pintor;
  final JuegoArcade Function() crearJuego;

  String get textoDificultad => switch (dificultad) {
    1 => 'Fácil',
    2 => 'Media',
    _ => 'Difícil',
  };
}

const List<JuegoInfo> juegosArcade = [
  JuegoInfo(
    id: IdsJuego.flap,
    titulo: 'UDIT Flap',
    descripcion:
        'Guía a una palomita voladora entre columnas de película. '
        'Un toque, un aleteo… ¿llegarás a la medalla de platino?',
    dificultad: 3,
    color: AppColores.neonMagenta,
    pintor: MiniaturaFlap.new,
    crearJuego: UditFlapGame.new,
  ),
  JuegoInfo(
    id: IdsJuego.breaker,
    titulo: 'Neon Breaker',
    descripcion:
        'Rompe muros de ladrillos de neón con la pelota. Cinco niveles, '
        'ladrillos reforzados y un power-up que ensancha la pala.',
    dificultad: 2,
    color: AppColores.neonCian,
    pintor: MiniaturaBreaker.new,
    crearJuego: NeonBreakerGame.new,
  ),
  JuegoInfo(
    id: IdsJuego.galaxy,
    titulo: 'Galaxy Run',
    descripcion:
        'Pilota una nave por el espacio y resiste oleadas de platillos '
        'enemigos y meteoritos. Tu nave dispara sola: tú esquiva.',
    dificultad: 2,
    color: AppColores.neonVioleta,
    pintor: MiniaturaGalaxy.new,
    crearJuego: GalaxyRunGame.new,
  ),
];
