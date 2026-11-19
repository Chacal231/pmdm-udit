// BANNER DEL ARCADE EN LA PANTALLA DE INICIO

// Tarjeta llamativa, con degradado de neón, que aparece entre las filas
// del catálogo y lleva directamente a la pestaña UDIT Arcade.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pulsable.dart';

class BannerArcade extends StatelessWidget {
  const BannerArcade({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppEspacios.margenPantalla,
        AppEspacios.xl,
        AppEspacios.margenPantalla,
        0,
      ),
      child: Pulsable(
        etiqueta: 'Abrir UDIT Arcade',
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppEspacios.l),
          decoration: BoxDecoration(
            borderRadius: AppRadios.grande,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PaletaArcade.cieloAlto, PaletaArcade.cieloMedio],
            ),
            border: Border.all(
              color: AppColores.neonCian.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColores.neonMagenta.withValues(alpha: 0.25),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppEspacios.m),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.sombra(0.3),
                  border: Border.all(color: AppColores.neonMagenta),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: AppColores.neonCian,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppEspacios.l),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UDIT Arcade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColores.texto,
                        shadows: [
                          Shadow(color: AppColores.neonCian, blurRadius: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: AppEspacios.xxs),
                    Text(
                      'Descansa entre capítulos con nuestros 3 minijuegos.',
                      style: AppTexto.cuerpoSecundario,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColores.neonCian,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
