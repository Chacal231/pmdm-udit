// COMPONENTES DE GALAXY RUN

// Todas las piezas del shooter, dibujadas por código:
//   - FondoEstrellas: tres capas de estrellas con parallax.
//   - Nave: la nave del jugador (con llama del motor animada).
//   - Laser: disparo de la nave.
//   - Objetivo: base común de lo que se puede destruir:
//       · NaveEnemiga: platillo que baja haciendo eses.
//       · Meteorito: roca irregular que gira.
// Las colisiones y los puntos los gestiona GalaxyRunGame.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../theme/app_theme.dart';
import '../galaxy_logica.dart';
import '../galaxy_game.dart';

// ---------------------------------------------------------------------
// FONDO DE ESTRELLAS
// ---------------------------------------------------------------------

class FondoEstrellas extends Component with HasGameReference<GalaxyRunGame> {
  FondoEstrellas() : super(priority: -10);

  // Cada capa: velocidad (unidades/s), tamaño y opacidad. Las lejanas son
  // pequeñas, tenues y lentas; las cercanas, grandes, brillantes y rápidas.
  static const List<(double, double, double)> _capas = [
    (18, 0.8, 0.45),
    (42, 1.3, 0.7),
    (95, 1.9, 1),
  ];

  final math.Random _azar = math.Random(5);
  late final List<List<Vector2>> _estrellas = [
    for (var i = 0; i < _capas.length; i++)
      List.generate(28, (_) => Vector2(_azar.nextDouble(), _azar.nextDouble())),
  ];
  final Paint _fondo = Paint();
  final Paint _nebulosa = Paint();
  final Paint _estrella = Paint();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _fondo.shader = Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      const [
        PaletaArcade.espacio,
        PaletaArcade.espacioClaro,
        PaletaArcade.espacio,
      ],
      const [0, 0.55, 1],
    );
    _nebulosa.shader = Gradient.radial(
      Offset(size.x * 0.75, size.y * 0.3),
      size.x * 0.7,
      [
        AppColores.neonVioleta.withValues(alpha: 0.22),
        AppColores.neonVioleta.withValues(alpha: 0),
      ],
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final alto = game.size.y;
    if (alto <= 0) return;
    for (var c = 0; c < _capas.length; c++) {
      // Avance relativo (0-1) de cada capa; al salir por abajo, vuelve arriba.
      final avance = _capas[c].$1 * game.escala * dt / alto;
      for (final e in _estrellas[c]) {
        e.y += avance;
        if (e.y > 1) {
          e.y -= 1;
          e.x = _azar.nextDouble();
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final ancho = game.size.x;
    final alto = game.size.y;
    final rect = Rect.fromLTWH(0, 0, ancho, alto);
    canvas
      ..drawRect(rect, _fondo)
      ..drawRect(rect, _nebulosa);
    for (var c = 0; c < _capas.length; c++) {
      final (_, tamano, opacidad) = _capas[c];
      _estrella.color = PaletaArcade.estrella.withValues(alpha: opacidad);
      for (final e in _estrellas[c]) {
        canvas.drawCircle(
          Offset(e.x * ancho, e.y * alto),
          tamano * game.escala,
          _estrella,
        );
      }
    }
  }
}

// ---------------------------------------------------------------------
// NAVE DEL JUGADOR
// ---------------------------------------------------------------------

// Dibujo de la nave, reutilizado en la miniatura del Arcade.
abstract final class DibujoNave {
  static final Paint _cuerpo = Paint()..color = PaletaArcade.naveCuerpo;
  static final Paint _sombra = Paint()..color = PaletaArcade.naveSombra;
  static final Paint _ala = Paint()..color = AppColores.neonMagenta;
  static final Paint _cabina = Paint()..color = AppColores.neonCian;
  static final Paint _llama = Paint();
  static final Paint _nucleoLlama = Paint()..color = AppColores.neonAmarillo;

  // [e] es la escala; [t] el tiempo, para que la llama parpadee.
  static void pintar(Canvas canvas, Offset centro, double e, double t) {
    canvas
      ..save()
      ..translate(centro.dx, centro.dy);
    // Llama del motor, de largo variable.
    final largo = (16 + math.sin(t * 38) * 4) * e;
    _llama.color = PaletaArcade.propulsor.withValues(alpha: 0.9);
    canvas
      ..drawPath(
        Path()
          ..moveTo(-6 * e, 16 * e)
          ..lineTo(0, 16 * e + largo)
          ..lineTo(6 * e, 16 * e)
          ..close(),
        _llama,
      )
      ..drawPath(
        Path()
          ..moveTo(-3 * e, 16 * e)
          ..lineTo(0, 16 * e + largo * 0.6)
          ..lineTo(3 * e, 16 * e)
          ..close(),
        _nucleoLlama,
      );
    // Alas en flecha con puntas de neón.
    final alas = Path()
      ..moveTo(0, -4 * e)
      ..lineTo(22 * e, 14 * e)
      ..lineTo(18 * e, 19 * e)
      ..lineTo(0, 12 * e)
      ..lineTo(-18 * e, 19 * e)
      ..lineTo(-22 * e, 14 * e)
      ..close();
    canvas.drawPath(alas, _ala);
    // Fuselaje: mitad iluminada y mitad en sombra para dar volumen.
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, -24 * e)
          ..lineTo(9 * e, 16 * e)
          ..lineTo(-9 * e, 16 * e)
          ..close(),
        _sombra,
      )
      ..drawPath(
        Path()
          ..moveTo(0, -24 * e)
          ..lineTo(2 * e, 16 * e)
          ..lineTo(-9 * e, 16 * e)
          ..close(),
        _cuerpo,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(0, -4 * e),
          width: 7 * e,
          height: 13 * e,
        ),
        _cabina,
      )
      ..restore();
  }
}

class Nave extends PositionComponent with HasGameReference<GalaxyRunGame> {
  Nave() : super(anchor: Anchor.center, priority: 10);

  // Radio de colisión: más pequeño que el dibujo para que sea justo.
  double get radio => 15 * game.escala;
  bool invulnerable = false;
  bool destruida = false;
  double _tiempo = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;
  }

  @override
  void render(Canvas canvas) {
    if (destruida) return;
    // Mientras es invulnerable, parpadea (se dibuja frames alternos).
    if (invulnerable && (_tiempo * 12).floor().isEven) return;
    DibujoNave.pintar(canvas, Offset.zero, game.escala, _tiempo);
  }
}

// ---------------------------------------------------------------------
// LÁSER
// ---------------------------------------------------------------------

class Laser extends Component {
  Laser({required Vector2 inicio, required this.escala})
    : centro = inicio.clone(),
      super(priority: 8) {
    _brillo.maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * escala);
  }

  final Vector2 centro;
  final double escala;
  double get radio => 4 * escala;

  final Paint _nucleo = Paint()..color = AppColores.texto;
  final Paint _brillo = Paint()..color = AppColores.neonCian;

  @override
  void update(double dt) {
    super.update(dt);
    centro.y -= LogicaGalaxy.velocidadLaser * escala * dt;
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centro.x, centro.y),
        width: 4 * escala,
        height: 16 * escala,
      ),
      Radius.circular(2 * escala),
    );
    canvas
      ..drawRRect(r.inflate(2 * escala), _brillo)
      ..drawRRect(r, _nucleo);
  }
}

// ---------------------------------------------------------------------
// OBJETIVOS
// ---------------------------------------------------------------------

abstract class Objetivo extends Component {
  Objetivo({
    required Vector2 inicio,
    required this.radio,
    required this.vida,
    required this.escala,
  }) : centro = inicio.clone(),
       super(priority: 6);

  final Vector2 centro;
  final double radio;
  final double escala;
  int vida;
  double destello = 0;

  // Puntos que da al ser destruido y colores de su explosión.
  int get puntos;
  List<Color> get coloresExplosion;

  // Resta un impacto. Devuelve true si queda destruido.
  bool golpear() {
    vida--;
    destello = 0.1;
    return vida <= 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (destello > 0) destello = math.max(0, destello - dt);
  }
}

class NaveEnemiga extends Objetivo {
  NaveEnemiga({
    required super.inicio,
    required super.vida,
    required super.escala,
    required this.velocidad,
    required this.amplitud,
    required this.frecuencia,
  }) : _xBase = inicio.x,
       super(radio: 17 * escala);

  final double velocidad;
  final double amplitud;
  final double frecuencia;
  final double _xBase;
  double _tiempo = 0;

  final Paint _casco = Paint()..color = PaletaArcade.enemigo;
  final Paint _borde = Paint()
    ..color = AppColores.neonMagenta
    ..style = PaintingStyle.stroke;
  final Paint _cupula = Paint()
    ..color = AppColores.neonCian.withValues(alpha: 0.85);
  final Paint _luz = Paint();
  final Paint _blanco = Paint();

  @override
  int get puntos => LogicaGalaxy.puntosEnemigo;
  @override
  List<Color> get coloresExplosion => const [
    AppColores.neonMagenta,
    PaletaArcade.enemigo,
    AppColores.neonAmarillo,
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;
    // Baja recto mientras se balancea de lado a lado (función seno).
    centro
      ..y += velocidad * dt
      ..x = _xBase + math.sin(_tiempo * frecuencia) * amplitud;
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(centro.x, centro.y);
    final e = escala;
    final casco = Rect.fromCenter(center: c, width: 36 * e, height: 14 * e);
    _borde.strokeWidth = 1.8 * e;
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: c.translate(0, -5 * e),
          width: 16 * e,
          height: 14 * e,
        ),
        _cupula,
      )
      ..drawOval(casco, _casco)
      ..drawOval(casco, _borde);
    // Lucecitas que se encienden por turnos.
    for (var i = -1; i <= 1; i++) {
      final encendida = ((_tiempo * 6).floor() + i) % 3 == 0;
      _luz.color = encendida
          ? AppColores.neonAmarillo
          : AppColores.superficieAlta;
      canvas.drawCircle(c.translate(i * 10 * e, 1 * e), 2.2 * e, _luz);
    }
    if (destello > 0) {
      _blanco.color = AppColores.texto.withValues(alpha: destello * 8);
      canvas.drawOval(casco, _blanco);
    }
  }
}

class Meteorito extends Objetivo {
  Meteorito({
    required super.inicio,
    required this.radioReferencia,
    required super.escala,
    required this.velocidad,
    required this.giro,
    required math.Random azar,
  }) : super(
         radio: radioReferencia * escala,
         vida: LogicaGalaxy.vidaMeteorito(radioReferencia),
       ) {
    // Forma irregular: 9 vértices a distancias distintas del centro.
    for (var i = 0; i < 9; i++) {
      final angulo = i / 9 * math.pi * 2;
      final distancia = radio * (0.75 + azar.nextDouble() * 0.3);
      _forma.add(Offset(math.cos(angulo), math.sin(angulo)) * distancia);
    }
    _contorno = Path()..addPolygon(_forma, true);
  }

  final double radioReferencia;
  final Vector2 velocidad;
  final double giro;
  final List<Offset> _forma = [];
  late final Path _contorno;
  double _angulo = 0;

  final Paint _roca = Paint()..color = PaletaArcade.meteorito;
  final Paint _crater = Paint()..color = PaletaArcade.meteoritoSombra;
  final Paint _blanco = Paint();

  @override
  int get puntos => LogicaGalaxy.puntosMeteorito(radioReferencia);
  @override
  List<Color> get coloresExplosion => const [
    PaletaArcade.meteorito,
    PaletaArcade.propulsor,
    AppColores.textoSecundario,
  ];

  @override
  void update(double dt) {
    super.update(dt);
    centro.addScaled(velocidad, dt);
    _angulo += giro * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas
      ..save()
      ..translate(centro.x, centro.y)
      ..rotate(_angulo)
      ..drawPath(_contorno, _roca)
      ..drawCircle(Offset(radio * 0.25, -radio * 0.2), radio * 0.22, _crater)
      ..drawCircle(Offset(-radio * 0.3, radio * 0.25), radio * 0.15, _crater);
    if (destello > 0) {
      _blanco.color = AppColores.texto.withValues(alpha: destello * 8);
      canvas.drawPath(_contorno, _blanco);
    }
    canvas.restore();
  }
}
