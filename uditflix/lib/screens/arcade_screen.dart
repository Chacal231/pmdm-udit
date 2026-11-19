// PANTALLA UDIT ARCADE

// Pestaña de los minijuegos. Muestra una cabecera de neón y una tarjeta
// grande por juego con:
//   - Una miniatura animada dibujada con CustomPainter.
//   - Descripción, dificultad y récord personal (se actualiza solo).
//   - Botón "Jugar", que abre el juego en su propia pantalla.
// Un único AnimationController mueve todas las miniaturas. Como la
// pestaña vive dentro de un IndexedStack con TickerMode, la animación se
// detiene sola cuando la pestaña no se ve.

import 'package:flutter/material.dart';

import '../games/catalogo_juegos.dart';
import '../games/comun/pantalla_juego.dart';
import '../navigation/transiciones.dart';
import '../services/almacen_local.dart';
import '../theme/app_theme.dart';
import '../widgets/pulsable.dart';

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animacion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  void _jugar(JuegoInfo juego) {
    Navigator.of(context)
        .push(rutaUdit<void>(PantallaJuego(crearJuego: juego.crearJuego)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Cabecera()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.margenPantalla,
                0,
                AppEspacios.margenPantalla,
                AppEspacios.xl,
              ),
              sliver: SliverList.separated(
                itemCount: juegosArcade.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppEspacios.l),
                itemBuilder: (context, index) {
                  final juego = juegosArcade[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _TarjetaJuego(
                        juego: juego,
                        animacion: _animacion,
                        onJugar: () => _jugar(juego),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppEspacios.margenPantalla,
        AppEspacios.l,
        AppEspacios.margenPantalla,
        AppEspacios.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UDIT Arcade',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: AppColores.texto,
              shadows: [
                Shadow(color: AppColores.neonCian, blurRadius: 12),
                Shadow(color: AppColores.neonMagenta, blurRadius: 28),
              ],
            ),
          ),
          SizedBox(height: AppEspacios.xs),
          Text(
            'Tres minijuegos hechos con Flame. ¡Bate tu récord!',
            style: AppTexto.cuerpoSecundario,
          ),
        ],
      ),
    );
  }
}

class _TarjetaJuego extends StatelessWidget {
  const _TarjetaJuego({
    required this.juego,
    required this.animacion,
    required this.onJugar,
  });

  final JuegoInfo juego;
  final Animation<double> animacion;
  final VoidCallback onJugar;

  @override
  Widget build(BuildContext context) {
    final color = juego.color;
    return Pulsable(
      etiqueta: juego.titulo,
      onTap: onJugar,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColores.superficie,
          borderRadius: AppRadios.grande,
          border: Border.all(color: color.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 24),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadios.grande,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 160,
                child: RepaintBoundary(
                  child: CustomPaint(painter: juego.pintor(animacion)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppEspacios.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      juego.titulo,
                      style: AppTexto.titulo.copyWith(
                        shadows: [Shadow(color: color, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: AppEspacios.xs),
                    Text(juego.descripcion, style: AppTexto.cuerpoSecundario),
                    const SizedBox(height: AppEspacios.m),
                    Wrap(
                      spacing: AppEspacios.l,
                      runSpacing: AppEspacios.s,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Dificultad(
                          nivel: juego.dificultad,
                          color: color,
                          texto: juego.textoDificultad,
                        ),
                        ListenableBuilder(
                          listenable: AlmacenLocal.instancia,
                          builder: (context, _) {
                            final record = AlmacenLocal.instancia.recordDe(
                              juego.id,
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  size: 18,
                                  color: AppColores.neonAmarillo,
                                ),
                                const SizedBox(width: AppEspacios.xs),
                                Text(
                                  record > 0
                                      ? 'Récord: $record'
                                      : 'Sin récord aún',
                                  style: AppTexto.etiqueta,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppEspacios.l),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: AppColores.fondo,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: onJugar,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Jugar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Indicador de dificultad: tres barritas y el texto.
class _Dificultad extends StatelessWidget {
  const _Dificultad({
    required this.nivel,
    required this.color,
    required this.texto,
  });

  final int nivel;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 3; i++)
          Container(
            margin: const EdgeInsets.only(right: 3),
            width: 6,
            height: 6.0 + i * 4,
            decoration: BoxDecoration(
              color: i <= nivel ? color : AppColores.superficieAlta,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: AppEspacios.xs),
        Text('Dificultad: $texto', style: AppTexto.etiqueta),
      ],
    );
  }
}
