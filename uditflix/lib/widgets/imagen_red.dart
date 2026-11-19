// IMAGEN CON CARGA, CACHÉ Y PLAN B

// Todas las portadas y fondos de UDITflix pasan por este widget:
// - Si la ruta empieza por "assets/" la carga del propio APK.
// - Si es una URL usa cached_network_image: la descarga una vez y la
//   guarda en caché, así al volver a la pantalla aparece al instante.
// - Mientras carga muestra el shimmer.
// - Si falla (sin conexión, URL rota…) muestra un fallback elegante con
//   un degradado y el título, en lugar del típico icono de error.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'shimmer.dart';

class ImagenRed extends StatelessWidget {
  const ImagenRed({
    super.key,
    required this.url,
    this.titulo,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.anchoLogico,
  });

  // URL https o ruta de asset.
  final String url;
  // Título que se pinta en el fallback si la imagen no carga.
  final String? titulo;
  final BoxFit fit;
  final Alignment alignment;
  // Ancho aproximado al que se va a mostrar. Sirve para decodificar la
  // imagen a ese tamaño y ahorrar memoria en las filas de pósters.
  final double? anchoLogico;

  @override
  Widget build(BuildContext context) {
    final anchoCache = anchoLogico == null
        ? null
        : (anchoLogico! * MediaQuery.devicePixelRatioOf(context)).round();
    final fallback = FallbackImagen(titulo: titulo);

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        alignment: alignment,
        cacheWidth: anchoCache,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: anchoCache,
      fadeInDuration: AppDuraciones.media,
      placeholder: (context, url) => const Shimmer(),
      errorWidget: (context, url, error) => fallback,
    );
  }
}

// Plan B cuando una imagen no se puede cargar.
class FallbackImagen extends StatelessWidget {
  const FallbackImagen({super.key, this.titulo});

  final String? titulo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColores.superficieAlta, AppColores.rojoOscuro],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppEspacios.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.movie_filter_outlined,
                color: AppColores.textoSecundario,
              ),
              if (titulo != null) ...[
                const SizedBox(height: AppEspacios.s),
                Text(
                  titulo!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTexto.etiqueta.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
