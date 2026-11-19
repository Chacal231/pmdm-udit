// PANTALLA DE BIENVENIDA (SPLASH)

// Lo primero que ve el usuario: el logotipo UDITflix aparece creciendo
// con un resplandor rojo y, al terminar, se pasa con un fundido a la
// pantalla principal. Todo con un único AnimationController (sin paquetes):
//   - Del 0 % al 55 %: el logo crece con un pequeño rebote.
//   - Del 20 % al 80 %: el brillo rojo sube y vuelve a bajar.
//   - Del 0 % al 25 %: el logo pasa de invisible a visible.

import 'package:flutter/material.dart';

import '../navigation/transiciones.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_uditflix.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: AppDuraciones.splash,
  );

  late final Animation<double> _escala = Tween(begin: 0.6, end: 1.0).animate(
    CurvedAnimation(
      parent: _controlador,
      curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _opacidad = CurvedAnimation(
    parent: _controlador,
    curve: const Interval(0, 0.25, curve: Curves.easeOut),
  );

  // El brillo sube hasta 1 y baja a 0.35 (un "destello" de luz).
  late final Animation<double> _brillo =
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1, end: 0.35), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _controlador,
          curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
        ),
      );

  @override
  void initState() {
    super.initState();
    _controlador.forward().whenComplete(_irAlInicio);
  }

  void _irAlInicio() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(rutaFundido<void>(const HomeShell()));
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamano = MediaQuery.sizeOf(context).shortestSide * 0.14;
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controlador,
          builder: (context, _) => Opacity(
            opacity: _opacidad.value,
            child: Transform.scale(
              scale: _escala.value,
              child: LogoUditflix(tamano: tamano, brillo: _brillo.value),
            ),
          ),
        ),
      ),
    );
  }
}
