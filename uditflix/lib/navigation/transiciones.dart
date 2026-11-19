// TRANSICIONES DE PÁGINA

// Todas las pantallas de UDITflix se abren con la misma animación:
// la nueva página aparece con un fundido mientras sube ligeramente.
// Centralizarla aquí da coherencia a toda la app.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Crea una ruta con fundido y desplazamiento vertical suave.
Route<T> rutaUdit<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: AppDuraciones.media,
    reverseTransitionDuration: AppDuraciones.media,
    pageBuilder: (context, animacion, animacionSecundaria) => pagina,
    transitionsBuilder: (context, animacion, animacionSecundaria, hijo) {
      final curva = CurvedAnimation(
        parent: animacion,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curva,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curva),
          child: hijo,
        ),
      );
    },
  );
}

// Variante de solo fundido, más lenta, para salir del splash.
Route<T> rutaFundido<T>(Widget pagina) {
  return PageRouteBuilder<T>(
    transitionDuration: AppDuraciones.lenta,
    pageBuilder: (context, animacion, animacionSecundaria) => pagina,
    transitionsBuilder: (context, animacion, animacionSecundaria, hijo) =>
        FadeTransition(opacity: animacion, child: hijo),
  );
}
