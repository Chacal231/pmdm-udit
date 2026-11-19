// CLASE BASE DE LOS JUEGOS DEL ARCADE

// Los tres juegos (UDIT Flap, Neon Breaker y Galaxy Run) comparten la
// misma "máquina de estados":
//
//   inicio ──toque──▶ jugando ──▶ fin (Game Over o victoria)
//                       │  ▲
//                 pausa ▼  │ continuar
//                       pausa
//
// Esta clase abstracta guarda ese estado, la puntuación, las vidas y un
// mensaje temporal ("Nivel 2", "Oleada 3"…) en ValueNotifier. Las capas
// de Flutter que van encima del juego (HUD, pausa, Game Over) escuchan
// esos ValueNotifier y se redibujan solas.
//
// Cada juego concreto hereda de aquí y solo tiene que implementar su
// mundo: qué pasa al empezar y cómo se reinicia la escena.

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../services/almacen_local.dart';
import 'medalla.dart';

enum EstadoJuego { inicio, jugando, pausa, fin }

// Nombres de las capas (overlays) de Flutter que se muestran encima.
abstract final class OverlaysJuego {
  static const String hud = 'hud';
  static const String inicio = 'inicio';
  static const String pausa = 'pausa';
  static const String fin = 'fin';
}

// Identificadores de los juegos (también son las claves de los récords).
abstract final class IdsJuego {
  static const String flap = 'flap';
  static const String breaker = 'breaker';
  static const String galaxy = 'galaxy';
}

// Datos que muestra la pantalla de Game Over.
class ResultadoPartida {
  const ResultadoPartida({
    required this.puntos,
    required this.record,
    required this.nuevoRecord,
    required this.victoria,
    this.medalla,
  });

  final int puntos;
  final int record;
  final bool nuevoRecord;
  final bool victoria;
  final Medalla? medalla;
}

abstract class JuegoArcade extends FlameGame {
  JuegoArcade({required this.idJuego});

  final String idJuego;

  // ---- Datos de presentación que usan las capas de Flutter ----
  String get titulo;
  String get instrucciones;
  Color get acento;
  // ¿Se dibujan los puntos en el HUD de Flutter? (UDIT Flap los dibuja
  // dentro del propio juego, grandes y en el centro).
  bool get puntosEnHud => true;
  bool get usaVidas => false;
  bool get usaMedallas => false;

  // ---- Estado observable ----
  final ValueNotifier<EstadoJuego> estado = ValueNotifier(EstadoJuego.inicio);
  final ValueNotifier<int> puntos = ValueNotifier(0);
  final ValueNotifier<int> vidas = ValueNotifier(0);
  final ValueNotifier<String?> mensaje = ValueNotifier(null);
  ResultadoPartida? resultado;

  bool get jugando => estado.value == EstadoJuego.jugando;

  // ---- Lo que cada juego debe implementar ----

  // Se llama al pasar de "inicio" a "jugando".
  void alComenzar();

  // Deja la escena como al abrir el juego (posiciones, niveles, etc.).
  void reiniciarEscena();

  // ---- Transiciones de estado ----

  void comenzar() {
    if (estado.value != EstadoJuego.inicio) return;
    estado.value = EstadoJuego.jugando;
    overlays.remove(OverlaysJuego.inicio);
    alComenzar();
  }

  void pausar() {
    if (!jugando) return;
    estado.value = EstadoJuego.pausa;
    overlays.add(OverlaysJuego.pausa);
    pauseEngine();
  }

  void reanudar() {
    if (estado.value != EstadoJuego.pausa) return;
    overlays.remove(OverlaysJuego.pausa);
    estado.value = EstadoJuego.jugando;
    resumeEngine();
  }

  // Termina la partida, guarda el récord y muestra el Game Over.
  Future<void> terminar({bool victoria = false}) async {
    if (estado.value == EstadoJuego.fin) return;
    estado.value = EstadoJuego.fin;
    final almacen = AlmacenLocal.instancia;
    final recordAnterior = almacen.recordDe(idJuego);
    final esRecord = await almacen.registrarPuntuacion(idJuego, puntos.value);
    resultado = ResultadoPartida(
      puntos: puntos.value,
      record: math.max(recordAnterior, puntos.value),
      nuevoRecord: esRecord,
      victoria: victoria,
      medalla: usaMedallas ? medallaPara(puntos.value) : null,
    );
    // Si mientras guardábamos el usuario ya reinició, no mostramos nada.
    if (estado.value == EstadoJuego.fin) overlays.add(OverlaysJuego.fin);
  }

  void reiniciar() {
    overlays
      ..remove(OverlaysJuego.fin)
      ..remove(OverlaysJuego.pausa);
    resultado = null;
    puntos.value = 0;
    mensaje.value = null;
    reiniciarEscena();
    estado.value = EstadoJuego.inicio;
    overlays.add(OverlaysJuego.inicio);
    resumeEngine();
  }

  // Muestra un mensaje grande unos segundos ("Nivel 2", "Oleada 3"…).
  // Un TimerComponent de Flame lo borra después; al ser parte del juego,
  // se congela con la pausa y desaparece al cerrar el juego.
  void mostrarMensaje(String texto, {double segundos = 1.6}) {
    mensaje.value = texto;
    add(
      TimerComponent(
        period: segundos,
        removeOnFinish: true,
        onTick: () {
          if (mensaje.value == texto) mensaje.value = null;
        },
      ),
    );
  }

  @override
  void onDispose() {
    // Liberamos los notificadores al cerrar el juego.
    estado.dispose();
    puntos.dispose();
    vidas.dispose();
    mensaje.dispose();
    super.onDispose();
  }
}
