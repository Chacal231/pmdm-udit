// PANTALLA DE BÚSQUEDA

// Filtra el catálogo por título o por género mientras se escribe.
// Para no buscar en cada pulsación usamos un "debounce": esperamos
// 300 ms desde la última tecla antes de lanzar la búsqueda.
//   - Campo vacío → "Búsquedas populares".
//   - Sin resultados → un estado vacío con sugerencias.
//   - Con resultados → cuadrícula de pósters.

import 'dart:async';

import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../navigation/navegacion.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/fila_contenidos.dart';
import '../widgets/imagen_red.dart';
import '../widgets/pulsable.dart';
import '../widgets/tarjeta_poster.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final TextEditingController _texto = TextEditingController();
  Timer? _debounce;
  // Texto que realmente se ha buscado (tras el debounce).
  String _consulta = '';

  void _alEscribir(String valor) {
    // Cada tecla reinicia la cuenta atrás de 300 ms.
    _debounce?.cancel();
    _debounce = Timer(AppDuraciones.debounceBusqueda, () {
      if (mounted) setState(() => _consulta = valor);
    });
    // Redibujamos ya para mostrar u ocultar el botón de borrar.
    setState(() {});
  }

  void _limpiar() {
    _debounce?.cancel();
    _texto.clear();
    setState(() => _consulta = '');
  }

  @override
  void dispose() {
    // Cancelamos el temporizador y liberamos el controlador del texto.
    _debounce?.cancel();
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = buscarContenidos(_consulta);
    final Widget cuerpo;
    if (_consulta.trim().isEmpty) {
      cuerpo = const _BusquedasPopulares();
    } else if (resultados.isEmpty) {
      cuerpo = EstadoVacio(
        icono: Icons.search_off_rounded,
        titulo: 'Sin resultados para «${_consulta.trim()}»',
        mensaje:
            'Prueba con otro título o con un género, como «Animación», '
            '«Drama» o «Ciencia ficción».',
      );
    } else {
      cuerpo = _Resultados(resultados: resultados);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.margenPantalla,
                AppEspacios.m,
                AppEspacios.margenPantalla,
                AppEspacios.s,
              ),
              child: TextField(
                controller: _texto,
                onChanged: _alEscribir,
                textInputAction: TextInputAction.search,
                style: AppTexto.cuerpo,
                decoration: InputDecoration(
                  hintText: 'Busca series, películas o géneros',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _texto.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar',
                          onPressed: _limpiar,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDuraciones.rapida,
                child: KeyedSubtree(key: ValueKey(_consulta), child: cuerpo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Lista de "Búsquedas populares" (los títulos del Top 10), con una
// miniatura horizontal, el título y un botón de reproducir.
class _BusquedasPopulares extends StatelessWidget {
  const _BusquedasPopulares();

  @override
  Widget build(BuildContext context) {
    final populares = top10();
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppEspacios.xl),
      itemCount: populares.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const TituloSeccion('Búsquedas populares');
        return _FilaPopular(contenido: populares[index - 1]);
      },
    );
  }
}

class _FilaPopular extends StatelessWidget {
  const _FilaPopular({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      etiqueta: contenido.titulo,
      onTap: () => abrirFicha(context, contenido),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacios.margenPantalla,
          vertical: AppEspacios.xs,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 132,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: AppRadios.boton,
                  child: ImagenRed(
                    url: contenido.fondoUrl,
                    titulo: contenido.titulo,
                    anchoLogico: 132,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppEspacios.m),
            Expanded(
              child: Text(
                contenido.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTexto.etiqueta,
              ),
            ),
            IconButton(
              tooltip: 'Reproducir ${contenido.titulo}',
              onPressed: () => reproducir(context, contenido),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

// Cuadrícula de resultados.
class _Resultados extends StatelessWidget {
  const _Resultados({required this.resultados});

  final List<Contenido> resultados;

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: TituloSeccion(
            resultados.length == 1
                ? '1 resultado'
                : '${resultados.length} resultados',
          ),
        ),
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
            itemCount: resultados.length,
            itemBuilder: (context, index) => TarjetaPoster(
              contenido: resultados[index],
              heroTag: 'buscar-${resultados[index].id}',
            ),
          ),
        ),
      ],
    );
  }
}
