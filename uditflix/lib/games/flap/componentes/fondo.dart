// COMPONENTES DE FONDO: CIELO, SKYLINE Y SUELO CON PARALLAX

// El "parallax" consiste en mover cada capa del fondo a una velocidad
// distinta: lo lejano se mueve despacio y lo cercano deprisa. Eso crea
// sensación de profundidad con dibujos completamente planos.
//   1. Cielo degradado con estrellas que titilan y un sol retro (fijo).
//   2. Skyline lejano (se mueve al 15 % de la velocidad del juego).
//   3. Skyline cercano con ventanas encendidas (al 40 %).
//   4. Suelo con rayas que se desplaza al 100 % (en SueloFlap).
//
// Los edificios se generan una sola vez con una semilla fija y se repiten
// en "baldosas" horizontales, así no se crea nada nuevo en cada frame.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../theme/app_theme.dart';
import '../flap_game.dart';

// Edificio en unidades de referencia: x dentro de la baldosa, ancho, alto
// y las ventanas encendidas (rectángulos relativos al edificio).
typedef _Edificio = ({
  double x,
  double ancho,
  double alto,
  List<Rect> ventanas,
});

class FondoFlap extends Component with HasGameReference<UditFlapGame> {
  FondoFlap() : super(priority: -10);

  // Ancho de una "baldosa" de edificios en unidades de referencia.
  static const double _baldosa = 640;

  final Paint _cielo = Paint();
  final Paint _sol = Paint();
  final Paint _rayaSol = Paint()..color = PaletaArcade.cieloMedio;
  final Paint _estrella = Paint();
  final Paint _lejano = Paint()..color = PaletaArcade.skylineLejano;
  final Paint _cercano = Paint()..color = PaletaArcade.skylineCercano;
  final Paint _ventana = Paint()
    ..color = PaletaArcade.ventana.withValues(alpha: 0.75);

  late final List<_Edificio> _edificiosLejanos = _generar(7, 70, 230, false);
  late final List<_Edificio> _edificiosCercanos = _generar(21, 40, 150, true);
  late final List<(double, double, double, double)> _estrellas =
      _generarEstrellas();

  Rect _rectCielo = Rect.zero;
  Offset _centroSol = Offset.zero;
  double _radioSol = 0;
  double _tiempo = 0;
  double _desplazamientoLejano = 0;
  double _desplazamientoCercano = 0;

  static List<_Edificio> _generar(
    int semilla,
    double altoMinimo,
    double altoMaximo,
    bool conVentanas,
  ) {
    final azar = math.Random(semilla);
    final edificios = <_Edificio>[];
    var x = 0.0;
    while (x < _baldosa) {
      final ancho = math.min(34 + azar.nextDouble() * 46, _baldosa - x);
      final alto = altoMinimo + azar.nextDouble() * (altoMaximo - altoMinimo);
      final ventanas = <Rect>[];
      if (conVentanas) {
        for (var vy = 12.0; vy < alto - 14; vy += 16) {
          for (var vx = 7.0; vx < ancho - 10; vx += 12) {
            if (azar.nextDouble() < 0.35) {
              ventanas.add(Rect.fromLTWH(vx, vy, 5, 7));
            }
          }
        }
      }
      edificios.add((x: x, ancho: ancho, alto: alto, ventanas: ventanas));
      x += ancho + 2 + azar.nextDouble() * 6;
    }
    return edificios;
  }

  // Estrellas: posición relativa (0-1), tamaño y fase del parpadeo.
  static List<(double, double, double, double)> _generarEstrellas() {
    final azar = math.Random(3);
    return List.generate(
      60,
      (_) => (
        azar.nextDouble(),
        azar.nextDouble() * 0.6,
        0.6 + azar.nextDouble() * 1.2,
        azar.nextDouble() * math.pi * 2,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final suelo = game.sueloY;
    final e = game.escala;
    _rectCielo = Rect.fromLTWH(0, 0, size.x, suelo);
    _cielo.shader = Gradient.linear(
      Offset.zero,
      Offset(0, suelo),
      const [
        PaletaArcade.cieloAlto,
        PaletaArcade.cieloMedio,
        PaletaArcade.cieloHorizonte,
      ],
      const [0, 0.6, 1],
    );
    _radioSol = 78 * e;
    _centroSol = Offset(size.x * 0.68, suelo - 150 * e);
    _sol.shader = Gradient.linear(
      _centroSol.translate(0, -_radioSol),
      _centroSol.translate(0, _radioSol),
      [AppColores.neonAmarillo, AppColores.neonMagenta],
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tiempo += dt;
    final v = game.velocidadFondo;
    _desplazamientoLejano += v * 0.15 * dt;
    _desplazamientoCercano += v * 0.4 * dt;
  }

  @override
  void render(Canvas canvas) {
    final ancho = game.size.x;
    final suelo = game.sueloY;
    final e = game.escala;
    canvas.drawRect(_rectCielo, _cielo);

    // Estrellas que titilan.
    for (final (x, y, r, fase) in _estrellas) {
      final brillo = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(_tiempo * 1.6 + fase));
      _estrella.color = PaletaArcade.estrella.withValues(alpha: brillo);
      canvas.drawCircle(Offset(x * ancho, y * suelo), r * e, _estrella);
    }

    // Sol retro con franjas horizontales en su mitad inferior.
    canvas.drawCircle(_centroSol, _radioSol, _sol);
    for (var i = 0; i < 5; i++) {
      final y = _centroSol.dy + _radioSol * (0.15 + i * 0.18);
      final grosor = (2 + i * 1.6) * e;
      canvas.drawRect(
        Rect.fromLTWH(_centroSol.dx - _radioSol, y, _radioSol * 2, grosor),
        _rayaSol,
      );
    }

    _pintarSkyline(
      canvas,
      _edificiosLejanos,
      _desplazamientoLejano,
      _lejano,
      ancho,
      suelo,
      e,
      false,
    );
    _pintarSkyline(
      canvas,
      _edificiosCercanos,
      _desplazamientoCercano,
      _cercano,
      ancho,
      suelo,
      e,
      true,
    );
  }

  void _pintarSkyline(
    Canvas canvas,
    List<_Edificio> edificios,
    double desplazamiento,
    Paint pincel,
    double ancho,
    double suelo,
    double e,
    bool ventanas,
  ) {
    final anchoBaldosa = _baldosa * e;
    // Repetimos la baldosa las veces necesarias para cubrir la pantalla.
    for (
      var inicio = -(desplazamiento % anchoBaldosa);
      inicio < ancho;
      inicio += anchoBaldosa
    ) {
      for (final ed in edificios) {
        final x = inicio + ed.x * e;
        if (x > ancho || x + ed.ancho * e < 0) continue;
        final arriba = suelo - ed.alto * e;
        canvas.drawRect(
          Rect.fromLTWH(x, arriba, ed.ancho * e, ed.alto * e),
          pincel,
        );
        if (!ventanas) continue;
        for (final v in ed.ventanas) {
          canvas.drawRect(
            Rect.fromLTWH(
              x + v.left * e,
              arriba + v.top * e,
              v.width * e,
              v.height * e,
            ),
            _ventana,
          );
        }
      }
    }
  }
}

// Suelo: banda inferior con una línea de neón y rayas diagonales que se
// desplazan a la misma velocidad que las columnas.
class SueloFlap extends Component with HasGameReference<UditFlapGame> {
  SueloFlap() : super(priority: 4);

  final Paint _suelo = Paint()..color = PaletaArcade.suelo;
  final Paint _raya = Paint()..color = PaletaArcade.sueloRaya;
  final Paint _linea = Paint()..color = AppColores.neonMagenta;
  final Paint _brillo = Paint()
    ..color = AppColores.neonMagenta.withValues(alpha: 0.6);
  double _desplazamiento = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _brillo.maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * game.escala);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _desplazamiento += game.velocidadFondo * dt;
  }

  @override
  void render(Canvas canvas) {
    final ancho = game.size.x;
    final alto = game.size.y;
    final suelo = game.sueloY;
    final e = game.escala;
    canvas.drawRect(Rect.fromLTWH(0, suelo, ancho, alto - suelo), _suelo);

    // Rayas diagonales: inclinamos el lienzo y dibujamos rectángulos.
    final separacion = 34 * e;
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, suelo, ancho, alto - suelo))
      ..translate(0, suelo)
      ..skew(-0.7, 0);
    final altoBanda = alto - suelo;
    final desfase = _desplazamiento % separacion;
    for (var x = -desfase; x < ancho + altoBanda; x += separacion) {
      canvas.drawRect(Rect.fromLTWH(x, 0, separacion * 0.45, altoBanda), _raya);
    }
    canvas.restore();

    final linea = Rect.fromLTWH(0, suelo - 1.5 * e, ancho, 3 * e);
    canvas
      ..drawRect(linea.inflate(2 * e), _brillo)
      ..drawRect(linea, _linea);
  }
}
