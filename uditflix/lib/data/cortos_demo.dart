// CORTOS DE DEMOSTRACIÓN (BLENDER FOUNDATION, CC BY)

// No tenemos los derechos de las películas y series del catálogo, así que
// al pulsar "Reproducir" se ve un "episodio de demostración": uno de los
// cortos libres de la Blender Foundation. Para que encaje un poco con lo
// que el usuario esperaba ver, el corto se elige según el género:
//   - Ciencia ficción o acción  → Tears of Steel
//   - Fantasía o drama          → Sintel
//   - Animación o comedia       → Big Buck Bunny
// Elephants Dream solo se reproduce desde su propia ficha.
//
// Todas las URLs se han comprobado con curl (archive.org, H.264 + AAC,
// en la versión más ligera disponible de cada corto).

class CortoDemo {
  const CortoDemo({
    required this.titulo,
    required this.url,
    required this.creditos,
  });

  final String titulo;
  final String url;
  // Atribución que exige la licencia Creative Commons.
  final String creditos;
}

const String urlBigBuckBunny =
    'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4';
const String urlSintel =
    'https://archive.org/download/Sintel/sintel-2048-stereo_512kb.mp4';
const String urlTearsOfSteel =
    'https://archive.org/download/Tears-of-Steel/tears_of_steel_720p.mp4';
const String urlElephantsDream =
    'https://archive.org/download/ElephantsDream/ed_hd_512kb.mp4';

const String creditosBigBuckBunny =
    'Vídeo de demostración: Big Buck Bunny © Blender Foundation · CC BY 3.0';
const String creditosSintel =
    'Vídeo de demostración: Sintel © Blender Foundation · CC BY 3.0';
const String creditosTearsOfSteel =
    'Vídeo de demostración: Tears of Steel © Blender Foundation · CC BY 3.0';

const CortoDemo bigBuckBunny = CortoDemo(
  titulo: 'Big Buck Bunny',
  url: urlBigBuckBunny,
  creditos: creditosBigBuckBunny,
);
const CortoDemo sintel = CortoDemo(
  titulo: 'Sintel',
  url: urlSintel,
  creditos: creditosSintel,
);
const CortoDemo tearsOfSteel = CortoDemo(
  titulo: 'Tears of Steel',
  url: urlTearsOfSteel,
  creditos: creditosTearsOfSteel,
);
const CortoDemo elephantsDream = CortoDemo(
  titulo: 'Elephants Dream',
  url: urlElephantsDream,
  creditos:
      'Vídeo de demostración: Elephants Dream © Blender Foundation · CC BY 2.5',
);

// Vídeo de respaldo: muy ligero (2,4 MB) y alojado en GitHub Pages.
// El reproductor lo usa si el vídeo principal falla o tarda demasiado.
const String videoRespaldoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
const String creditosVideoRespaldo =
    'Vídeo de respaldo: «Butterfly» · © The Flutter Authors · licencia BSD';

const List<CortoDemo> cortosDemo = [
  bigBuckBunny,
  sintel,
  tearsOfSteel,
  elephantsDream,
];

// Elige el corto para un título real según sus géneros. Los géneros están
// ordenados del más importante al menos, así que manda el primero que
// encaje con alguna regla. Si ninguno encaja, Sintel (el más "dramático").
CortoDemo cortoParaGeneros(List<String> generos) {
  for (final genero in generos) {
    switch (genero) {
      case 'Ciencia ficción' || 'Acción':
        return tearsOfSteel;
      case 'Fantasía' || 'Drama':
        return sintel;
      case 'Animación' || 'Comedia':
        return bigBuckBunny;
    }
  }
  return sintel;
}

// Busca qué corto corresponde a una URL (null si no es ninguno).
CortoDemo? cortoPorUrl(String url) {
  for (final corto in cortosDemo) {
    if (corto.url == url) return corto;
  }
  return null;
}
