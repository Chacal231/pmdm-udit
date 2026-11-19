// CARRUSEL DE DESTACADOS

// La gran cabecera de la pantalla de inicio. Ocupa casi toda la altura
// y muestra el fondo del título destacado con degradados, sus géneros y
// los botones principales.
//
// Si hay varios destacados se pasan solos cada 6 segundos (con un Timer).
// En cuanto el usuario lo toca, el paso automático se detiene: si alguien
// está leyendo o eligiendo, no le cambiamos el título de golpe.
// El Timer se cancela en dispose para no dejar nada vivo al salir.

import 'dart:async';

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../navigation/navegacion.dart';
import '../theme/app_theme.dart';
import 'badges.dart';
import 'botones.dart';
import 'imagen_red.dart';

class CarruselDestacados extends StatefulWidget {
  const CarruselDestacados({
    super.key,
    required this.contenidos,
    required this.alto,
  });

  final List<Contenido> contenidos;
  final double alto;

  @override
  State<CarruselDestacados> createState() => _CarruselDestacadosState();
}

class _CarruselDestacadosState extends State<CarruselDestacados> {
  final PageController _paginas = PageController();
  Timer? _autoplay;
  int _actual = 0;

  @override
  void initState() {
    super.initState();
    if (widget.contenidos.length > 1) {
      _autoplay = Timer.periodic(AppDuraciones.carrusel, (_) => _siguiente());
    }
  }

  void _siguiente() {
    if (!_paginas.hasClients) return;
    final siguiente = (_actual + 1) % widget.contenidos.length;
    _paginas.animateToPage(
      siguiente,
      duration: AppDuraciones.lenta * 1.6,
      curve: Curves.easeInOutCubic,
    );
  }

  // El usuario ha tocado el carrusel: paramos el paso automático.
  void _detenerAutoplay() {
    _autoplay?.cancel();
    _autoplay = null;
  }

  @override
  void dispose() {
    _detenerAutoplay();
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.alto,
      child: Listener(
        onPointerDown: (_) => _detenerAutoplay(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _paginas,
              itemCount: widget.contenidos.length,
              onPageChanged: (pagina) => setState(() => _actual = pagina),
              itemBuilder: (context, index) =>
                  _PaginaDestacado(contenido: widget.contenidos[index]),
            ),
            if (widget.contenidos.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppEspacios.m,
                child: _Indicador(
                  total: widget.contenidos.length,
                  actual: _actual,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Una página del carrusel: fondo, degradados, textos y botones.
class _PaginaDestacado extends StatelessWidget {
  const _PaginaDestacado({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final posicionTop = top10().indexOf(contenido) + 1;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImagenRed(url: contenido.fondoUrl, titulo: contenido.titulo),
        // Degradado superior: da contraste a la barra con el logotipo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColores.velo(0.75), AppColores.transparente],
              stops: const [0, 0.3],
            ),
          ),
        ),
        // Degradado inferior: funde la imagen con el fondo de la app.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColores.transparente,
                AppColores.velo(0.65),
                AppColores.fondo,
              ],
              stops: const [0.35, 0.72, 1],
            ),
          ),
        ),
        Positioned(
          left: AppEspacios.margenPantalla,
          right: AppEspacios.margenPantalla,
          bottom: AppEspacios.xxl,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contenido.titulo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTexto.tituloGrande.copyWith(
                      shadows: [
                        Shadow(color: AppColores.velo(0.8), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppEspacios.s),
                  if (posicionTop > 0) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BadgeTop10(),
                        const SizedBox(width: AppEspacios.s),
                        Text(
                          'Nº $posicionTop en España hoy',
                          style: AppTexto.etiqueta.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppEspacios.s),
                  ],
                  Text(
                    contenido.generosTexto,
                    textAlign: TextAlign.center,
                    style: AppTexto.etiqueta.copyWith(
                      color: AppColores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: AppEspacios.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BotonMiLista(contenido: contenido),
                      const SizedBox(width: AppEspacios.s),
                      // Si no cabe (pantalla estrecha o letra grande), el
                      // botón se reduce en lugar de desbordarse.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: BotonReproducir(contenido: contenido),
                        ),
                      ),
                      const SizedBox(width: AppEspacios.s),
                      BotonVertical(
                        icono: const Icon(Icons.info_outline_rounded),
                        texto: 'Info',
                        onTap: () => abrirFicha(context, contenido),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Puntitos que indican en qué página del carrusel estamos.
class _Indicador extends StatelessWidget {
  const _Indicador({required this.total, required this.actual});

  final int total;
  final int actual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: AppDuraciones.media,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == actual ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == actual
                  ? AppColores.rojo
                  : AppColores.textoTerciario.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadios.pastilla),
            ),
          ),
      ],
    );
  }
}
