// PANTALLA "MI LISTA"

// Cuadrícula con los títulos que el usuario ha guardado con "+ Mi lista".
// Escucha al AlmacenLocal, así que se actualiza sola en cuanto se añade
// o se quita algo desde cualquier otra pantalla.

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../services/almacen_local.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/tarjeta_poster.dart';

class MiListaScreen extends StatelessWidget {
  const MiListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: AlmacenLocal.instancia,
          builder: (context, _) {
            final guardados = AlmacenLocal.instancia.miLista
                .map(contenidoPorId)
                .whereType<Contenido>()
                .toList();

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppEspacios.margenPantalla,
                      AppEspacios.l,
                      AppEspacios.margenPantalla,
                      AppEspacios.l,
                    ),
                    child: Text('Mi lista', style: AppTexto.titulo),
                  ),
                ),
                if (guardados.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EstadoVacio(
                      icono: Icons.bookmark_add_outlined,
                      titulo: 'Tu lista está vacía',
                      mensaje:
                          'Pulsa «+ Mi lista» en cualquier título para '
                          'guardarlo aquí y verlo cuando quieras.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppEspacios.margenPantalla,
                      0,
                      AppEspacios.margenPantalla,
                      AppEspacios.xl,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppMedidas.columnasRejilla(ancho),
                        childAspectRatio: 2 / 3,
                        mainAxisSpacing: AppEspacios.s,
                        crossAxisSpacing: AppEspacios.s,
                      ),
                      itemCount: guardados.length,
                      itemBuilder: (context, index) => TarjetaPoster(
                        contenido: guardados[index],
                        heroTag: 'milista-${guardados[index].id}',
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
