// BOTONES COMPARTIDOS

// "Reproducir" (blanco) y "Mi lista" aparecen tanto en el destacado
// como en la ficha. Mi lista escucha al AlmacenLocal, así que si se
// añade un título desde la ficha, el botón del destacado también cambia.

import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../navigation/navegacion.dart';
import '../services/almacen_local.dart';
import '../theme/app_theme.dart';

// Botón blanco "▶ Reproducir".
class BotonReproducir extends StatelessWidget {
  const BotonReproducir({
    super.key,
    required this.contenido,
    this.anchoCompleto = false,
  });

  final Contenido contenido;
  final bool anchoCompleto;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: anchoCompleto
          ? FilledButton.styleFrom(minimumSize: const Size.fromHeight(46))
          : null,
      onPressed: () => reproducir(context, contenido),
      icon: const Icon(Icons.play_arrow_rounded, size: 28),
      label: const Text('Reproducir'),
    );
  }
}

// Botón "Mi lista": añade o quita el título y lo guarda en el móvil.
// Tiene dos formatos: vertical (icono + texto debajo, para el destacado)
// y de ancho completo (para la ficha).
class BotonMiLista extends StatelessWidget {
  const BotonMiLista({
    super.key,
    required this.contenido,
    this.anchoCompleto = false,
  });

  final Contenido contenido;
  final bool anchoCompleto;

  Future<void> _alternar(BuildContext context) async {
    final mensajero = ScaffoldMessenger.of(context);
    final anadido = await AlmacenLocal.instancia.alternarMiLista(contenido.id);
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            anadido
                ? '«${contenido.titulo}» añadido a Mi lista'
                : '«${contenido.titulo}» eliminado de Mi lista',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AlmacenLocal.instancia,
      builder: (context, _) {
        final enLista = AlmacenLocal.instancia.estaEnMiLista(contenido.id);
        // Al cambiar de estado el icono gira y se funde con el nuevo.
        final icono = AnimatedSwitcher(
          duration: AppDuraciones.media,
          transitionBuilder: (hijo, animacion) => RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animacion),
            child: FadeTransition(opacity: animacion, child: hijo),
          ),
          child: Icon(
            enLista ? Icons.check_rounded : Icons.add_rounded,
            key: ValueKey(enLista),
          ),
        );

        if (anchoCompleto) {
          return OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
            ),
            onPressed: () => _alternar(context),
            icon: icono,
            label: Text(enLista ? 'En Mi lista' : 'Mi lista'),
          );
        }
        return BotonVertical(
          icono: icono,
          texto: 'Mi lista',
          onTap: () => _alternar(context),
        );
      },
    );
  }
}

// Botón de icono con texto pequeño debajo ("+ Mi lista", "ⓘ Info").
class BotonVertical extends StatelessWidget {
  const BotonVertical({
    super.key,
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  final Widget icono;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: const IconThemeData(size: 26, color: AppColores.texto),
              child: icono,
            ),
            const SizedBox(height: AppEspacios.xxs),
            Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTexto.pequeno.copyWith(color: AppColores.texto),
            ),
          ],
        ),
      ),
    );
  }
}
