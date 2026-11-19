// Tests de widgets de la app completa: arranque, catálogo, ficha y Arcade.
//
// Reglas para que sean fiables:
//   - No dependen de la red: en los tests las peticiones HTTP fallan y las
//     imágenes muestran su "plan B" (degradado y título).
//   - No se abre nunca el reproductor (VideoPlayerController necesita la
//     plataforma real).
//   - No se usa pumpAndSettle: hay animaciones infinitas (shimmer, carrusel,
//     miniaturas del Arcade). Avanzamos el reloj con pump(duración).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uditflix/main.dart';
import 'package:uditflix/screens/arcade_screen.dart';
import 'package:uditflix/screens/catalogo_screen.dart';
import 'package:uditflix/screens/ficha_screen.dart';
import 'package:uditflix/screens/home_shell.dart';
import 'package:uditflix/services/almacen_local.dart';
import 'package:uditflix/widgets/tarjeta_poster.dart';

// Arranca la app en un "móvil" de 360×800 y deja pasar el splash.
Future<void> arrancarApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MyApp());
  // Splash: 1,8 s de animación y 0,5 s de fundido hacia el inicio.
  await tester.pump(const Duration(milliseconds: 1900));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AlmacenLocal.instancia.iniciar();
  });

  testWidgets('arranca, pasa el splash y muestra el catálogo', (tester) async {
    await arrancarApp(tester);

    expect(find.byType(HomeShell), findsOneWidget);
    // El logotipo es un Text.rich con "UDIT" + "flix".
    expect(find.text('UDITflix', findRichText: true), findsWidgets);
    expect(find.text('Top 10 en España hoy'), findsOneWidget);
    // Chips de filtro de la barra superior.
    expect(find.text('Series'), findsWidgets);
    expect(find.text('Películas'), findsWidgets);
    // Las demás filas están más abajo: hacemos scroll como un usuario.
    final catalogo = find
        .descendant(
          of: find.byType(CatalogoScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    for (final fila in ['Tendencias', 'Cortos de animación libres']) {
      await tester.scrollUntilVisible(
        find.text(fila),
        250,
        scrollable: catalogo,
      );
      expect(find.text(fila), findsOneWidget);
    }
    // Barra de navegación inferior.
    for (final pestana in ['Inicio', 'Buscar', 'Arcade', 'Mi lista']) {
      expect(find.text(pestana), findsOneWidget);
    }
  });

  testWidgets('al tocar una tarjeta se abre la ficha', (tester) async {
    await arrancarApp(tester);

    // La primera tarjeta (fila Top 10) ya se ve sin hacer scroll.
    await tester.tap(find.byType(TarjetaPoster).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Se abre la ficha del nº 1 del Top 10 (Stranger Things).
    final ficha = find.byType(FichaScreen);
    expect(ficha, findsOneWidget);
    Finder enFicha(Finder f) => find.descendant(of: ficha, matching: f);
    expect(enFicha(find.text('Stranger Things')), findsWidgets);
    expect(enFicha(find.textContaining('% para ti')), findsOneWidget);
    expect(enFicha(find.text('Reproducir')), findsOneWidget);
    expect(enFicha(find.text('Ver tráiler')), findsOneWidget);
  });

  testWidgets('la pestaña Arcade muestra los tres juegos', (tester) async {
    await arrancarApp(tester);

    await tester.tap(find.text('Arcade'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('UDIT Arcade'), findsOneWidget);
    final lista = find.descendant(
      of: find.byType(ArcadeScreen),
      matching: find.byType(Scrollable),
    );
    for (final juego in ['UDIT Flap', 'Neon Breaker', 'Galaxy Run']) {
      await tester.scrollUntilVisible(find.text(juego), 200, scrollable: lista);
      expect(find.text(juego), findsOneWidget);
    }
    expect(find.text('Jugar'), findsWidgets);
  });
}
