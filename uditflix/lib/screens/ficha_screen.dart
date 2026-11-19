// PANTALLA DE FICHA DE UN TÍTULO

// Muestra todo lo que hay que saber de una película o serie antes de
// verla: un gran fondo con degradado, la portada (que llega "volando"
// desde la tarjeta pulsada gracias a Hero), los metadatos, los botones
// Reproducir y Mi lista, la descripción y títulos parecidos.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../theme/app_theme.dart';
import '../widgets/badges.dart';
import '../widgets/botones.dart';
import '../widgets/fila_contenidos.dart';
import '../widgets/imagen_red.dart';
import '../widgets/tarjeta_poster.dart';

class FichaScreen extends StatefulWidget {
  const FichaScreen({super.key, required this.contenido, this.heroTag});

  // Título que se está consultando.
  final Contenido contenido;
  // Etiqueta Hero de la tarjeta desde la que se abrió (si la hay).
  final String? heroTag;

  @override
  State<FichaScreen> createState() => _FichaScreenState();
}

// Es StatefulWidget solo para escuchar el scroll: la barra superior con
// el botón de volver se vuelve opaca al bajar, igual que en el inicio.
class _FichaScreenState extends State<FichaScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _opacidadBarra = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      _opacidadBarra.value = (_scroll.offset / 180).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _opacidadBarra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contenido = widget.contenido;
    final ancho = MediaQuery.sizeOf(context).width;
    final relacionados = similares(contenido);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: _Cabecera(
                    contenido: contenido,
                    heroTag: widget.heroTag,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Centrado(child: _Detalles(contenido: contenido)),
                ),
                if (relacionados.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _Centrado(
                      child: TituloSeccion('Más títulos como este'),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _margenLateral(ancho),
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppMedidas.columnasRejilla(
                          ancho - _margenLateral(ancho) * 2,
                        ),
                        childAspectRatio: 2 / 3,
                        mainAxisSpacing: AppEspacios.s,
                        crossAxisSpacing: AppEspacios.s,
                      ),
                      itemCount: relacionados.length,
                      itemBuilder: (context, index) => TarjetaPoster(
                        contenido: relacionados[index],
                        heroTag: 'similar-${relacionados[index].id}',
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: _Centrado(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppEspacios.margenPantalla,
                        AppEspacios.xl,
                        AppEspacios.margenPantalla,
                        AppEspacios.xxxl,
                      ),
                      child: Text(
                        contenido.creditosVideo,
                        style: AppTexto.pequeno,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Barra superior con el botón de volver: transparente sobre el
            // fondo y opaca (mostrando el título) al hacer scroll.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _opacidadBarra,
                builder: (context, valor, _) => ColoredBox(
                  color: AppColores.velo(valor),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppEspacios.s),
                      child: Row(
                        children: [
                          IconButton.filled(
                            tooltip: 'Volver',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColores.velo(0.6),
                              foregroundColor: AppColores.texto,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: AppEspacios.m),
                          Expanded(
                            child: Opacity(
                              opacity: valor,
                              child: Text(
                                contenido.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTexto.tituloSeccion,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // En tablets centramos el contenido con un ancho cómodo de lectura.
  static double _margenLateral(double ancho) {
    final sobrante = ancho - AppMedidas.anchoMaximoLectura;
    return sobrante > 0
        ? sobrante / 2 + AppEspacios.margenPantalla
        : AppEspacios.margenPantalla;
  }
}

// Limita el ancho del contenido en pantallas grandes.
class _Centrado extends StatelessWidget {
  const _Centrado({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppMedidas.anchoMaximoLectura,
        ),
        // Ocupa todo el ancho permitido para que el texto quede a la izquierda.
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

// Fondo grande con degradado, portada (Hero) y título.
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.contenido, required this.heroTag});

  final Contenido contenido;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final altoFondo = (ancho * 9 / 16).clamp(220.0, 460.0);
    final anchoPoster = ancho >= AppMedidas.anchoTablet ? 150.0 : 108.0;

    final poster = ClipRRect(
      borderRadius: AppRadios.tarjeta,
      child: ImagenRed(
        url: contenido.imagenUrl,
        titulo: contenido.titulo,
        anchoLogico: anchoPoster,
      ),
    );

    return SizedBox(
      height: altoFondo + anchoPoster * 0.75,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: altoFondo,
            child: ImagenRed(url: contenido.fondoUrl, titulo: contenido.titulo),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: altoFondo + 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColores.velo(0.55),
                    AppColores.transparente,
                    AppColores.velo(0.7),
                    AppColores.fondo,
                  ],
                  stops: const [0, 0.3, 0.75, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Centrado(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacios.margenPantalla,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: anchoPoster,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: heroTag == null
                            ? poster
                            : Hero(tag: heroTag!, child: poster),
                      ),
                    ),
                    const SizedBox(width: AppEspacios.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contenido.categoria.toUpperCase(),
                            style: AppTexto.pequeno.copyWith(
                              color: AppColores.rojo,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: AppEspacios.xs),
                          Text(
                            contenido.titulo,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTexto.titulo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Metadatos, botones, descripción y géneros.
class _Detalles extends StatelessWidget {
  const _Detalles({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final posicionTop = top10().indexOf(contenido) + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppEspacios.margenPantalla,
        AppEspacios.l,
        AppEspacios.margenPantalla,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap en lugar de Row: si no cabe, salta de línea sin overflow.
          Wrap(
            spacing: AppEspacios.m,
            runSpacing: AppEspacios.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextoCoincidencia(contenido.coincidencia),
              Text('${contenido.anio}', style: AppTexto.cuerpoSecundario),
              BadgeEdad(contenido.edad),
              Text(contenido.duracion, style: AppTexto.cuerpoSecundario),
              const BadgeHD(),
            ],
          ),
          if (posicionTop > 0) ...[
            const SizedBox(height: AppEspacios.m),
            Row(
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
          ],
          const SizedBox(height: AppEspacios.l),
          BotonReproducir(contenido: contenido, anchoCompleto: true),
          const SizedBox(height: AppEspacios.s),
          BotonMiLista(contenido: contenido, anchoCompleto: true),
          BotonTrailer(contenido: contenido),
          const SizedBox(height: AppEspacios.l),
          Text(contenido.descripcion, style: AppTexto.cuerpo),
          const SizedBox(height: AppEspacios.m),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Géneros: ',
                  style: TextStyle(color: AppColores.textoTerciario),
                ),
                TextSpan(text: contenido.generos.join(', ')),
              ],
            ),
            style: AppTexto.cuerpoSecundario,
          ),
        ],
      ),
    );
  }
}
