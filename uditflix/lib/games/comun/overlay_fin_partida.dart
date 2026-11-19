// PANTALLA DE GAME OVER (COMÚN A LOS TRES JUEGOS)

// Aparece al terminar la partida con una pequeña animación de entrada:
//   - Título "Game Over" o "¡Victoria!".
//   - Medalla (solo en UDIT Flap): bronce, plata, oro o platino.
//   - Puntuación (con efecto de contador) y récord personal.
//   - Aviso "¡Nuevo récord!" que palpita.
//   - Botones "Reiniciar" y "Salir al Arcade".

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'juego_arcade.dart';
import 'medalla.dart';
import 'overlays_juego.dart';

class OverlayFinPartida extends StatelessWidget {
  const OverlayFinPartida({super.key, required this.juego});

  final JuegoArcade juego;

  @override
  Widget build(BuildContext context) {
    final resultado = juego.resultado;
    if (resultado == null) return const SizedBox.shrink();
    final color = juego.acento;

    return ColoredBox(
      color: AppColores.sombra(0.6),
      child: Center(
        child: SingleChildScrollView(
          // Entrada: la tarjeta crece un poco y aparece.
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppDuraciones.lenta,
            curve: Curves.easeOutBack,
            builder: (context, t, hijo) => Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.85 + 0.15 * t, child: hijo),
            ),
            child: TarjetaNeon(
              color: color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    resultado.victoria ? '¡Victoria!' : 'Game Over',
                    textAlign: TextAlign.center,
                    style: estiloNeon(color, 36),
                  ),
                  if (resultado.medalla != null) ...[
                    const SizedBox(height: AppEspacios.l),
                    Center(
                      child: _InsigniaMedalla(medalla: resultado.medalla!),
                    ),
                  ],
                  const SizedBox(height: AppEspacios.l),
                  Row(
                    children: [
                      Expanded(
                        child: _Dato(
                          etiqueta: 'PUNTOS',
                          valor: resultado.puntos,
                          animado: true,
                        ),
                      ),
                      Expanded(
                        child: _Dato(
                          etiqueta: 'RÉCORD',
                          valor: resultado.record,
                        ),
                      ),
                    ],
                  ),
                  if (resultado.nuevoRecord) ...[
                    const SizedBox(height: AppEspacios.m),
                    const Center(child: _AvisoNuevoRecord()),
                  ],
                  const SizedBox(height: AppEspacios.xl),
                  BotonMenuJuego.principal(
                    texto: 'Reiniciar',
                    icono: Icons.replay_rounded,
                    color: color,
                    onPressed: juego.reiniciar,
                  ),
                  const SizedBox(height: AppEspacios.s),
                  BotonMenuJuego.secundario(
                    texto: 'Salir al Arcade',
                    icono: Icons.logout_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Un número grande con su etiqueta. Si es animado, cuenta desde 0.
class _Dato extends StatelessWidget {
  const _Dato({
    required this.etiqueta,
    required this.valor,
    this.animado = false,
  });

  final String etiqueta;
  final int valor;
  final bool animado;

  @override
  Widget build(BuildContext context) {
    const estiloValor = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      color: AppColores.texto,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return Column(
      children: [
        Text(
          etiqueta,
          style: AppTexto.pequeno.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppEspacios.xs),
        if (animado)
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: valor),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, n, _) => Text('$n', style: estiloValor),
          )
        else
          Text('$valor', style: estiloValor),
      ],
    );
  }
}

// Medalla circular con degradado metálico.
class _InsigniaMedalla extends StatelessWidget {
  const _InsigniaMedalla({required this.medalla});

  final Medalla medalla;

  Color get _color => switch (medalla) {
    Medalla.bronce => AppColores.bronce,
    Medalla.plata => AppColores.plata,
    Medalla.oro => AppColores.oro,
    Medalla.platino => AppColores.platino,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, t, hijo) => Transform.scale(scale: t, child: hijo),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.lerp(color, AppColores.texto, 0.55)!,
                  color,
                  Color.lerp(color, AppColores.negro, 0.35)!,
                ],
                stops: const [0, 0.6, 1],
              ),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 18),
              ],
            ),
            child: Icon(
              Icons.military_tech_rounded,
              size: 40,
              color: Color.lerp(color, AppColores.negro, 0.55),
            ),
          ),
          const SizedBox(height: AppEspacios.xs),
          Text(
            'Medalla de ${medalla.nombre.toLowerCase()}',
            style: AppTexto.etiqueta.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// "¡Nuevo récord!" con un latido continuo.
class _AvisoNuevoRecord extends StatefulWidget {
  const _AvisoNuevoRecord();

  @override
  State<_AvisoNuevoRecord> createState() => _AvisoNuevoRecordState();
}

class _AvisoNuevoRecordState extends State<_AvisoNuevoRecord>
    with SingleTickerProviderStateMixin {
  late final AnimationController _latido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.92,
        end: 1.08,
      ).animate(CurvedAnimation(parent: _latido, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacios.l,
          vertical: AppEspacios.xs,
        ),
        decoration: BoxDecoration(
          color: AppColores.neonAmarillo,
          borderRadius: BorderRadius.circular(AppRadios.pastilla),
          boxShadow: [
            BoxShadow(
              color: AppColores.neonAmarillo.withValues(alpha: 0.6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Text(
          '¡Nuevo récord!',
          style: AppTexto.etiqueta.copyWith(
            color: AppColores.fondo,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
