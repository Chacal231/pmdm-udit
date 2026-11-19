// COMPONENTE JUGADOR: LA PALOMITA

// Componente de Flame que representa al personaje. Se encarga de:
//   - Flotar suavemente en la pantalla de inicio.
//   - Aplicar la física (gravedad, salto, velocidad terminal) mientras
//     se juega, usando las funciones puras de FisicaFlap.
//   - Inclinarse hacia arriba al saltar y hacia abajo al caer.
//   - Detectar el choque con las columnas gracias a su CircleHitbox.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../comun/juego_arcade.dart';
import '../flap_fisica.dart';
import '../flap_game.dart';
import 'columnas.dart';
import 'dibujo_palomita.dart';

class Palomita extends PositionComponent
    with CollisionCallbacks, HasGameReference<UditFlapGame> {
  Palomita() : super(anchor: Anchor.center, priority: 5);

  // Radio del dibujo en unidades de referencia (pantalla de 720 de alto).
  static const double radioReferencia = 22;

  // Velocidad vertical en unidades de referencia por segundo.
  double velocidad = 0;
  bool aturdida = false;
  double _tiempo = 0;
  double _aleteo = 0;
  double _yReposo = 0;

  // Hitbox circular más pequeña que el dibujo: así un roce con el borde
  // del dibujo no cuenta como choque (se siente más justo).
  final CircleHitbox _hitbox = CircleHitbox(anchor: Anchor.center);

  double get radio => size.x / 2;
  double get radioColision => radio * 0.78;

  @override
  Future<void> onLoad() async {
    add(_hitbox);
  }

  // Ajusta tamaño y posición de reposo a la escala de la pantalla.
  // Si [colocar] es true, además lleva al personaje a esa posición.
  void ajustar(double escala, Vector2 reposo, {required bool colocar}) {
    size = Vector2.all(radioReferencia * 2 * escala);
    _hitbox
      ..radius = radioColision
      ..position = size / 2;
    _yReposo = reposo.y;
    x = reposo.x;
    if (colocar) y = _yReposo;
  }

  void reiniciar() {
    velocidad = 0;
    angle = 0;
    aturdida = false;
    y = _yReposo;
  }

  void saltar() {
    velocidad = FisicaFlap.impulso;
    _aleteo = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;
    // Al subir aletea deprisa; al caer, más despacio.
    _aleteo += dt * (velocidad < 0 ? 26 : 12);

    if (game.estado.value == EstadoJuego.inicio) {
      // Pantalla de inicio: flota arriba y abajo.
      y = _yReposo + math.sin(_tiempo * 3.2) * 7 * game.escala;
      angle = math.sin(_tiempo * 3.2) * 0.08;
      return;
    }
    if (!game.jugando && !game.muriendo) return;

    // Física: la gravedad cambia la velocidad y la velocidad la posición.
    velocidad = FisicaFlap.aplicarGravedad(velocidad, dt);
    y += velocidad * game.escala * dt;

    // Nunca atraviesa el suelo (al morir se queda apoyada en él).
    final limite = game.sueloY - radioColision;
    if (y > limite) {
      y = limite;
      velocidad = 0;
    }

    // Giro suave hacia el ángulo que corresponde a su velocidad.
    final objetivo = FisicaFlap.rotacion(velocidad);
    angle += (objetivo - angle) * math.min(1, dt * 10);
  }

  @override
  void render(Canvas canvas) {
    DibujoPalomita.pintar(
      canvas,
      Offset(size.x / 2, size.y / 2),
      radio,
      aleteo: aturdida ? 0 : math.sin(_aleteo),
      aturdida: aturdida,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Columna) game.chocar();
  }
}
