// FILA HORIZONTAL DE CONTENIDOS

// Cada "estantería" del catálogo: un título de sección y una lista de
// pósters que se desplaza en horizontal. El tamaño de los pósters se
// adapta al ancho de la pantalla (móvil o tablet).

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../theme/app_theme.dart';
import 'tarjeta_poster.dart';

class FilaContenidos extends StatelessWidget {
  const FilaContenidos({
    super.key,
    required this.titulo,
    required this.contenidos,
    required this.seccion,
    this.progresos,
  });

  final String titulo;
  final List<Contenido> contenidos;
  // Nombre corto de la fila, usado para que las etiquetas Hero sean únicas.
  final String seccion;
  // Solo en "Continuar viendo": id del contenido → fracción vista.
  final Map<int, double>? progresos;

  @override
  Widget build(BuildContext context) {
    final ancho = AppMedidas.anchoPoster(MediaQuery.sizeOf(context).width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSeccion(titulo),
        SizedBox(
          height: ancho * 1.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppEspacios.margenPantalla,
            ),
            itemCount: contenidos.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppEspacios.s),
            itemBuilder: (context, index) {
              final contenido = contenidos[index];
              return TarjetaPoster(
                contenido: contenido,
                heroTag: '$seccion-${contenido.id}',
                ancho: ancho,
                progreso: progresos?[contenido.id],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Título de una sección del catálogo, con su margen estándar.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppEspacios.margenPantalla,
        AppEspacios.xl,
        AppEspacios.margenPantalla,
        AppEspacios.s,
      ),
      child: Text(texto, style: AppTexto.tituloSeccion),
    );
  }
}
