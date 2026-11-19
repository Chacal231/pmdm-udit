// COMPONENTES DE NEON BREAKER

// Todas las piezas visibles del juego, dibujadas por código con estética
// de neón:
//   - FondoNeon: degradado con una rejilla en perspectiva (estilo retro).
//   - Pala: la barra que controla el jugador (puede ensancharse).
//   - Pelota: con una estela que deja rastro.
//   - Ladrillo: 1, 2 o 3 golpes de resistencia (cian, magenta, amarillo).
//   - PowerUp: cápsula que cae y ensancha la pala.
// La lógica (rebotes, colisiones, puntos) está en NeonBreakerGame y en
// breaker_logica.dart; aquí solo se dibuja y se guarda el estado propio.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../theme/app_theme.dart';
import '../breaker_game.dart';

// Color de cada nivel de resistencia.
Color colorResistencia(int resistencia) => switch (resistencia) {
  3 => AppColores.neonAmarillo,
  2 => AppColores.neonMagenta,
  _ => AppColores.neonCian,
};

// ---------------------------------------------------------------------
// FONDO
// ---------------------------------------------------------------------

class FondoNeon extends Component with HasGameReference<NeonBreakerGame> {
  FondoNeon() : super(priority: -10);

  final Paint _fondo = Paint();
  final Paint _rejilla = Paint()
    ..color = PaletaArcade.rejilla
    ..strokeWidth = 1;
  final Paint _marco = Paint()
    ..color = AppColores.neonCian.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke;
  double _desplazamiento = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _fondo.shader = Gradient.linear(Offset.zero, Offset(0, size.y), const [
      PaletaArcade.espacio,
      PaletaArcade.espacioClaro,
    ]);
    _marco.strokeWidth = 2 * game.escala;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _desplazamiento = (_desplazamiento + dt * 0.35) % 1;
  }

  @override
  void render(Canvas canvas) {
    final ancho = game.size.x;
    final alto = game.size.y;
    canvas.drawRect(Rect.fromLTWH(0, 0, ancho, alto), _fondo);

    // Rejilla en perspectiva en la mitad inferior: líneas que salen de un
    // punto de fuga y líneas horizontales cada vez más separadas.
    final horizonte = alto * 0.55;
    final fuga = Offset(ancho / 2, horizonte);
    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(
        fuga,
        Offset(ancho / 2 + i * ancho * 0.22, alto),
        _rejilla,
      );
    }
    for (var i = 0; i < 8; i++) {
      final t = (i + _desplazamiento) / 8;
      final y = horizonte + (alto - horizonte) * t * t;
      canvas.drawLine(Offset(0, y), Offset(ancho, y), _rejilla);
    }

    // Marco: paredes laterales y techo donde rebota la pelota.
    final techo = game.techo;
    canvas.drawPath(
      Path()
        ..moveTo(1, alto)
        ..lineTo(1, techo)
        ..lineTo(ancho - 1, techo)
        ..lineTo(ancho - 1, alto),
      _marco,
    );
  }
}

// ---------------------------------------------------------------------
// PALA
// ---------------------------------------------------------------------

class Pala extends PositionComponent with HasGameReference<NeonBreakerGame> {
  Pala() : super(anchor: Anchor.center, priority: 10);

  double _anchoNormal = 0;
  double _anchoObjetivo = 0;
  final Paint _relleno = Paint();
  final Paint _brillo = Paint();

  void ajustar(double escala, Vector2 centro) {
    _anchoNormal = 86 * escala;
    _anchoObjetivo = _anchoNormal;
    size = Vector2(_anchoNormal, 14 * escala);
    position = centro;
    _brillo
      ..color = AppColores.neonCian.withValues(alpha: 0.55)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * escala);
    // Degradado preparado una vez (cubre también la pala ensanchada).
    _relleno.shader = Gradient.linear(
      Offset.zero,
      Offset(_anchoNormal * 1.6, 0),
      const [AppColores.neonCian, AppColores.neonMagenta],
    );
  }

  // Activa o desactiva el power-up "pala ancha" (60 % más ancha).
  set ancha(bool valor) =>
      _anchoObjetivo = valor ? _anchoNormal * 1.6 : _anchoNormal;

  void mover(double dx) {
    x = (x + dx).clamp(size.x / 2, game.size.x - size.x / 2);
  }

  Rect get rect =>
      Rect.fromCenter(center: Offset(x, y), width: size.x, height: size.y);

  @override
  void update(double dt) {
    super.update(dt);
    // Cambio de ancho suave en lugar de un salto brusco.
    size.x += (_anchoObjetivo - size.x) * math.min(1, dt * 10);
    x = x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size.toSize(),
      Radius.circular(size.y / 2),
    );
    canvas
      ..drawRRect(r.inflate(2), _brillo)
      ..drawRRect(r, _relleno);
  }
}

// ---------------------------------------------------------------------
// PELOTA
// ---------------------------------------------------------------------

// No usa position/anchor de Flame: guarda su centro en coordenadas de
// pantalla porque así es más cómodo calcular rebotes y dibujar la estela.
class Pelota extends Component {
  Pelota() : super(priority: 12);

  final Vector2 centro = Vector2.zero();
  final Vector2 velocidad = Vector2.zero();
  double radio = 8;

  // Estela: "búfer circular" de posiciones anteriores, reservado una vez.
  static const int _largoEstela = 10;
  final List<Vector2> _estela = List.generate(
    _largoEstela,
    (_) => Vector2.zero(),
  );
  int _indice = 0;
  bool _estelaActiva = false;

  final Paint _nucleo = Paint()..color = AppColores.texto;
  final Paint _halo = Paint();
  final Paint _rastro = Paint();

  void ajustar(double escala) {
    radio = 8 * escala;
    _halo
      ..color = AppColores.neonCian.withValues(alpha: 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * escala);
  }

  // Borra la estela (al volver a la pala).
  void limpiarEstela() => _estelaActiva = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (!_estelaActiva) {
      for (final p in _estela) {
        p.setFrom(centro);
      }
      _estelaActiva = true;
    }
    _estela[_indice].setFrom(centro);
    _indice = (_indice + 1) % _largoEstela;
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < _largoEstela; i++) {
      // Del punto más antiguo al más reciente, cada vez más visible.
      final p = _estela[(_indice + i) % _largoEstela];
      final t = (i + 1) / _largoEstela;
      _rastro.color = AppColores.neonCian.withValues(alpha: 0.35 * t);
      canvas.drawCircle(Offset(p.x, p.y), radio * (0.4 + 0.5 * t), _rastro);
    }
    final c = Offset(centro.x, centro.y);
    canvas
      ..drawCircle(c, radio * 1.6, _halo)
      ..drawCircle(c, radio, _nucleo);
  }
}

// ---------------------------------------------------------------------
// LADRILLO
// ---------------------------------------------------------------------

class Ladrillo extends PositionComponent {
  Ladrillo({
    required this.resistenciaInicial,
    required Vector2 posicion,
    required Vector2 tamano,
    required this.escala,
  }) : resistencia = resistenciaInicial,
       super(position: posicion, size: tamano, priority: 5) {
    _brillo
      ..strokeWidth = 5 * escala
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * escala);
    _borde.strokeWidth = 1.8 * escala;
    _grieta.strokeWidth = 1.4 * escala;
    _colorear();
  }

  final int resistenciaInicial;
  final double escala;
  int resistencia;
  // Tiempo restante del destello blanco tras un golpe.
  double _destello = 0;

  final Paint _relleno = Paint();
  final Paint _borde = Paint()..style = PaintingStyle.stroke;
  final Paint _brillo = Paint()..style = PaintingStyle.stroke;
  final Paint _blanco = Paint();
  final Paint _grieta = Paint()
    ..style = PaintingStyle.stroke
    ..color = AppColores.sombra(0.6);

  Rect get rect => Rect.fromLTWH(x, y, size.x, size.y);

  // Resta un golpe. Devuelve true si el ladrillo se ha roto.
  bool golpear() {
    resistencia--;
    _destello = 0.12;
    _colorear();
    return resistencia <= 0;
  }

  // El color depende de la resistencia que le queda.
  void _colorear() {
    final color = colorResistencia(resistencia);
    _relleno.color = color.withValues(alpha: 0.28);
    _borde.color = color;
    _brillo.color = color.withValues(alpha: 0.45);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destello > 0) _destello = math.max(0, _destello - dt);
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size.toSize(),
      Radius.circular(4 * escala),
    );
    canvas
      ..drawRRect(r, _brillo)
      ..drawRRect(r, _relleno)
      ..drawRRect(r, _borde);

    // Grietas si ya ha recibido algún golpe.
    if (resistencia < resistenciaInicial) {
      final w = size.x;
      final h = size.y;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.3, 0)
          ..lineTo(w * 0.42, h * 0.45)
          ..lineTo(w * 0.34, h * 0.7)
          ..lineTo(w * 0.46, h)
          ..moveTo(w * 0.42, h * 0.45)
          ..lineTo(w * 0.62, h * 0.38),
        _grieta,
      );
    }
    if (_destello > 0) {
      _blanco.color = AppColores.texto.withValues(
        alpha: _destello / 0.12 * 0.8,
      );
      canvas.drawRRect(r, _blanco);
    }
  }
}

// ---------------------------------------------------------------------
// POWER-UP: PALA ANCHA
// ---------------------------------------------------------------------

class PowerUp extends Component {
  PowerUp({required Vector2 inicio, required this.escala})
    : centro = inicio.clone(),
      super(priority: 8) {
    final mitad = 20 * escala;
    _capsula.shader = Gradient.linear(
      Offset(-mitad, 0),
      Offset(mitad, 0),
      const [AppColores.neonMagenta, AppColores.neonCian],
    );
    _flecha.strokeWidth = 2.2 * escala;
  }

  final Vector2 centro;
  final double escala;
  double _tiempo = 0;

  final Paint _capsula = Paint();
  final Paint _flecha = Paint()
    ..color = AppColores.fondo
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Rect get rect => Rect.fromCenter(
    center: Offset(centro.x, centro.y),
    width: 40 * escala,
    height: 18 * escala,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;
    centro.y += 150 * escala * dt;
  }

  @override
  void render(Canvas canvas) {
    final r = rect;
    // Late suavemente para llamar la atención.
    final pulso = 1 + math.sin(_tiempo * 8) * 0.06;
    canvas
      ..save()
      ..translate(r.center.dx, r.center.dy)
      ..scale(pulso);
    final local = Rect.fromCenter(
      center: Offset.zero,
      width: r.width,
      height: r.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(local, Radius.circular(r.height / 2)),
      _capsula,
    );
    // Flechas "↔" que indican que la pala se ensancha.
    final a = 9 * escala;
    final p = 4 * escala;
    canvas
      ..drawLine(Offset(-a, 0), Offset(a, 0), _flecha)
      ..drawPath(
        Path()
          ..moveTo(-a + p, -p)
          ..lineTo(-a, 0)
          ..lineTo(-a + p, p)
          ..moveTo(a - p, -p)
          ..lineTo(a, 0)
          ..lineTo(a - p, p),
        _flecha,
      )
      ..restore();
  }
}
