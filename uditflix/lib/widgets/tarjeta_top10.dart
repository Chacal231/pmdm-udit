// FILA "TOP 10 EN ESPAÑA HOY"

// Cada elemento muestra un número enorme, solo con el contorno, que
// asoma por detrás del póster. Es el recurso visual típico de las
// plataformas de streaming para destacar lo más visto del día.

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../theme/app_theme.dart';
import 'fila_contenidos.dart';
import 'tarjeta_poster.dart';

class FilaTop10 extends StatelessWidget {
  const FilaTop10({super.key, required this.titulo, required this.contenidos});

  final String titulo;
  final List<Contenido> contenidos;

  @override
  Widget build(BuildContext context) {
    final ancho = AppMedidas.anchoPoster(MediaQuery.sizeOf(context).width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSeccion(titulo),
        SizedBox(
          height: ancho * 1.5,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppEspacios.margenPantalla,
            ),
            itemCount: contenidos.length,
            itemBuilder: (context, index) => _ElementoTop10(
              posicion: index + 1,
              contenido: contenidos[index],
              anchoPoster: ancho,
            ),
          ),
        ),
      ],
    );
  }
}

class _ElementoTop10 extends StatelessWidget {
  const _ElementoTop10({
    required this.posicion,
    required this.contenido,
    required this.anchoPoster,
  });

  final int posicion;
  final Contenido contenido;
  final double anchoPoster;

  @override
  Widget build(BuildContext context) {
    final alto = anchoPoster * 1.5;
    // El "10" tiene dos cifras y necesita más hueco que el resto.
    final anchoNumero = anchoPoster * (posicion == 10 ? 0.95 : 0.62);
    return SizedBox(
      width: anchoNumero + anchoPoster,
      height: alto,
      child: Stack(
        children: [
          // Número en contorno, detrás del póster.
          Positioned(
            left: 0,
            bottom: -alto * 0.12,
            child: Text(
              '$posicion',
              style: TextStyle(
                fontSize: alto * 0.78,
                fontWeight: FontWeight.w900,
                letterSpacing: -alto * 0.09,
                height: 1,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = AppColores.textoSecundario,
              ),
            ),
          ),
          Positioned(
            right: AppEspacios.s,
            top: 0,
            bottom: 0,
            child: TarjetaPoster(
              contenido: contenido,
              heroTag: 'top10-${contenido.id}',
              ancho: anchoPoster - AppEspacios.s,
            ),
          ),
        ],
      ),
    );
  }
}
