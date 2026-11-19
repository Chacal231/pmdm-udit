// ESTRUCTURA PRINCIPAL CON NAVEGACIÓN INFERIOR

// Contiene las cuatro pestañas de la app (Inicio, Buscar, Arcade y
// Mi lista) y la barra de navegación inferior.
//
// Usamos IndexedStack: las cuatro pantallas se crean una vez y se quedan
// vivas aunque no se vean. Así, al volver a una pestaña, conserva su
// scroll, el texto buscado, etc., igual que en las apps profesionales.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'arcade_screen.dart';
import 'buscar_screen.dart';
import 'catalogo_screen.dart';
import 'mi_lista_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _pestana = 0;

  void _irA(int pestana) {
    // Al cambiar de pestaña cerramos el teclado si estaba abierto.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _pestana = pestana);
  }

  // Las pantallas se crean una sola vez y el IndexedStack las conserva.
  late final List<Widget> _pantallas = [
    CatalogoScreen(onAbrirArcade: () => _irA(2)),
    const BuscarScreen(),
    const ArcadeScreen(),
    const MiListaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: IndexedStack(
          index: _pestana,
          children: [
            // En las pestañas que no se ven desactivamos las animaciones
            // Hero (para que no interfieran) y los tickers con TickerMode
            // (así, por ejemplo, las miniaturas del Arcade no se animan
            // en segundo plano gastando batería).
            for (var i = 0; i < _pantallas.length; i++)
              TickerMode(
                enabled: i == _pestana,
                child: HeroMode(enabled: i == _pestana, child: _pantallas[i]),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _pestana,
          onDestinationSelected: _irA,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon: Icon(Icons.sports_esports_rounded),
              label: 'Arcade',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Mi lista',
            ),
          ],
        ),
      ),
    );
  }
}
