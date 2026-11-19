// ESTADO VACÍO

// Lo que se muestra cuando una pantalla no tiene nada que enseñar
// (Mi lista vacía, búsqueda sin resultados…). Un icono grande, un
// título y una explicación: mucho mejor que una pantalla en negro.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppEspacios.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppEspacios.xl),
              decoration: const BoxDecoration(
                color: AppColores.superficieAlta,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 48, color: AppColores.textoSecundario),
            ),
            const SizedBox(height: AppEspacios.xl),
            Text(titulo, textAlign: TextAlign.center, style: AppTexto.titulo),
            const SizedBox(height: AppEspacios.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                mensaje,
                textAlign: TextAlign.center,
                style: AppTexto.cuerpoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
