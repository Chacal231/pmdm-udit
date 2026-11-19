// Tests del catálogo: asignación de los cortos de demostración por género,
// tráileres de YouTube y botón "Ver tráiler" de la ficha.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uditflix/data/contenidos.dart';
import 'package:uditflix/data/cortos_demo.dart';
import 'package:uditflix/models/contenido.dart';
import 'package:uditflix/screens/ficha_screen.dart';
import 'package:uditflix/services/almacen_local.dart';
import 'package:uditflix/theme/app_theme.dart';

void main() {
  group('Cortos de demostración por género', () {
    test('ciencia ficción y acción → Tears of Steel', () {
      expect(cortoParaGeneros(['Ciencia ficción', 'Drama']), tearsOfSteel);
      expect(cortoParaGeneros(['Acción']), tearsOfSteel);
    });

    test('fantasía y drama → Sintel', () {
      expect(cortoParaGeneros(['Fantasía']), sintel);
      expect(cortoParaGeneros(['Drama', 'Historia']), sintel);
    });

    test('animación y comedia → Big Buck Bunny', () {
      expect(cortoParaGeneros(['Animación', 'Acción']), bigBuckBunny);
      expect(cortoParaGeneros(['Comedia']), bigBuckBunny);
    });

    test('manda el primer género que encaja y hay un valor por defecto', () {
      expect(cortoParaGeneros(['Misterio', 'Comedia']), bigBuckBunny);
      expect(cortoParaGeneros(['Crimen', 'Suspense']), sintel);
      expect(cortoParaGeneros(const []), sintel);
    });

    test('cada título real usa el corto que le toca por género', () {
      for (final c in contenidos.where((c) => !c.esCortoLibre)) {
        final corto = cortoParaGeneros(c.generos);
        expect(c.videoUrl, corto.url, reason: c.titulo);
        expect(c.creditosVideo, corto.creditos, reason: c.titulo);
      }
    });

    test('Elephants Dream solo se usa en su propia ficha', () {
      final usos = contenidos.where((c) => c.videoUrl == urlElephantsDream);
      expect(usos.map((c) => c.titulo), ['Elephants Dream']);
    });

    test('cortoPorUrl reconoce los cortos y devuelve null si no', () {
      expect(cortoPorUrl(urlSintel), sintel);
      expect(cortoPorUrl('https://ejemplo.com/otro.mp4'), isNull);
    });
  });

  group('Datos del catálogo', () {
    test('ids únicos y entre 18 y 24 títulos reales', () {
      final ids = contenidos.map((c) => c.id).toSet();
      expect(ids.length, contenidos.length);
      final reales = contenidos.where((c) => !c.esCortoLibre).length;
      expect(reales, inInclusiveRange(18, 24));
    });

    test('los IDs de YouTube tienen el formato correcto', () {
      final formato = RegExp(r'^[A-Za-z0-9_-]{11}$');
      for (final c in contenidos) {
        final id = c.trailerYoutubeId;
        if (id != null) expect(formato.hasMatch(id), isTrue, reason: c.titulo);
      }
    });
  });

  group('Botón "Ver tráiler"', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AlmacenLocal.instancia.iniciar();
    });

    Future<void> abrirFicha(WidgetTester tester, Contenido contenido) async {
      tester.view
        ..physicalSize = const Size(1080, 2400)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.oscuro,
          home: FichaScreen(contenido: contenido),
        ),
      );
      await tester.pump();
    }

    testWidgets('aparece si el título tiene tráiler', (tester) async {
      final conTrailer = contenidos.firstWhere(
        (c) => c.trailerYoutubeId != null,
      );
      await abrirFicha(tester, conTrailer);
      expect(find.text('Ver tráiler'), findsOneWidget);
    });

    testWidgets('no aparece si el título no tiene tráiler', (tester) async {
      final sinTrailer = contenidos.firstWhere(
        (c) => c.trailerYoutubeId == null,
      );
      await abrirFicha(tester, sinTrailer);
      expect(find.text('Ver tráiler'), findsNothing);
      // El resto de botones sigue ahí.
      expect(find.text('Reproducir'), findsOneWidget);
    });
  });
}
