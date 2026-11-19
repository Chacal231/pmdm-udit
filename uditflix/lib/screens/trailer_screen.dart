// PANTALLA DEL TRÁILER OFICIAL (YOUTUBE)

// Los tráileres oficiales están en YouTube, y video_player no puede
// reproducir vídeos de YouTube. Para verlos dentro de la app usamos el
// paquete youtube_player_iframe, que inserta el reproductor oficial de
// YouTube (un iframe) tanto en Android como en la versión web.
//
// Como el reproductor propio, se abre en horizontal e inmersivo y, al
// salir, deja la orientación y las barras del sistema como estaban.

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/contenido.dart';
import '../services/sistema_pantalla.dart';
import '../theme/app_theme.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({
    super.key,
    required this.contenido,
    required this.videoId,
  });

  final Contenido contenido;
  // ID del vídeo de YouTube (Contenido.trailerYoutubeId).
  final String videoId;

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late final YoutubePlayerController _controlador =
      YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: false,
          strictRelatedVideos: true,
          interfaceLanguage: 'es',
          captionLanguage: 'es',
        ),
      );
  bool _restaurado = false;

  @override
  void initState() {
    super.initState();
    SistemaPantalla.modoReproductor();
  }

  // Devuelve la app a su modo normal (solo una vez).
  void _restaurar() {
    if (_restaurado) return;
    _restaurado = true;
    SistemaPantalla.modoNormal();
  }

  @override
  void dispose() {
    // Cerramos el reproductor de YouTube para liberar el iframe/webview.
    _controlador.close();
    _restaurar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (seHaCerrado, _) {
        if (seHaCerrado) _restaurar();
      },
      child: Scaffold(
        backgroundColor: AppColores.negro,
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior separada del vídeo: el iframe de YouTube
              // captura los toques que caen encima de él.
              Row(
                children: [
                  IconButton(
                    tooltip: 'Volver',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppEspacios.s),
                  Expanded(
                    child: Text(
                      widget.contenido.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTexto.tituloSeccion,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppEspacios.l),
                    child: Text(
                      'Tráiler oficial · YouTube',
                      style: AppTexto.pequeno,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: YoutubePlayer(
                    controller: _controlador,
                    autoFullScreen: false,
                    enableFullScreenOnVerticalDrag: false,
                    backgroundColor: AppColores.negro,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
