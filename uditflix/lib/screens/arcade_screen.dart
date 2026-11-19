// PANTALLA UDIT ARCADE

// Pestaña de los minijuegos. En esta fase solo reserva su sitio en la
// navegación; los juegos y sus tarjetas llegan en la Fase 4.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';

class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppEspacios.margenPantalla),
              child: Text(
                'UDIT Arcade',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: AppColores.neonCian,
                  shadows: [Shadow(color: AppColores.neonCian, blurRadius: 14)],
                ),
              ),
            ),
            Expanded(
              child: EstadoVacio(
                icono: Icons.sports_esports_outlined,
                titulo: 'Próximamente',
                mensaje: 'Aquí encontrarás los minijuegos de UDITflix.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
