// DATOS SIMULADOS DE UDITFLIX

// En esta primera versión no tenemos una API ni una base de datos.
// Por eso utilizamos una lis de objetos creada manualmente

// Más adelante sustituiremos estos datos por información
// que recibiremos desde el servidor mediante una API REST

// Origen de los recursos (todas las URLs se han comprobado con curl):
// - Pósters y fondos de títulos comerciales: The Movie Database (TMDB).
// - Vídeos de demostración: películas libres de la Blender Foundation
//   (Creative Commons BY), alojadas en Internet Archive. Los tráileres
//   oficiales están en YouTube y video_player no puede reproducirlos.
// - Imágenes de los cortos libres: fotogramas y carteles oficiales de la
//   Blender Foundation (CC BY), empaquetados en assets/cortos/ para que
//   funcionen sin conexión. Detalle en assets/cortos/CREDITOS.md.

import '../models/contenido.dart';

// Prefijos de las imágenes de TMDB: w500 para pósters verticales
// y w1280 para fondos horizontales.
const String _poster = 'https://image.tmdb.org/t/p/w500';
const String _fondo = 'https://image.tmdb.org/t/p/w1280';

// Vídeos libres de la Blender Foundation (H.264 + AAC, aptos para Android).
const String _videoBunny =
    'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4';
const String _videoSintel =
    'https://archive.org/download/Sintel/sintel-2048-stereo_512kb.mp4';
const String _videoTears =
    'https://archive.org/download/Tears-of-Steel/tears_of_steel_720p.mp4';
const String _videoElephants =
    'https://archive.org/download/ElephantsDream/ed_hd_512kb.mp4';

// Vídeo de respaldo: muy ligero (2,4 MB) y alojado en GitHub Pages.
// El reproductor lo usa si el vídeo principal falla o tarda demasiado.
const String videoRespaldoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
const String creditosVideoRespaldo =
    'Vídeo de respaldo: «Butterfly» · © The Flutter Authors · licencia BSD';

// Textos de atribución que exige la licencia CC BY.
const String _creditosBunny =
    'Vídeo de demostración: Big Buck Bunny © Blender Foundation · CC BY 3.0';
const String _creditosSintel =
    'Vídeo de demostración: Sintel © Blender Foundation · CC BY 3.0';
const String _creditosTears =
    'Vídeo de demostración: Tears of Steel © Blender Foundation · CC BY 3.0';
const String _creditosElephants =
    'Vídeo de demostración: Elephants Dream © Blender Foundation · CC BY 2.5';

// Lista de contenidos que aparecerán en nuestra aplicación
// Cada elemento de lista es un objeto de tipo Contenido

const List<Contenido> contenidos = [
  // ------------------------------- SERIES -------------------------------
  Contenido(
    id: 1,
    titulo: 'Stranger Things',
    descripcion:
        'Cuando un niño desaparece en un pequeño pueblo de Indiana, sus '
        'amigos, su familia y la policía se ven envueltos en un misterio de '
        'experimentos secretos y fuerzas sobrenaturales.',
    tipo: 'Vídeo',
    duracion: '5 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
    fondoUrl: '$_fondo/56v2KjBlU4XaOv9rVYEQypROD7P.jpg',
    videoUrl: _videoTears,
    anio: 2016,
    edad: '16+',
    coincidencia: 98,
    generos: ['Ciencia ficción', 'Terror', 'Drama'],
    creditosVideo: _creditosTears,
    destacado: true,
    esTop10: true,
  ),
  Contenido(
    id: 2,
    titulo: 'Miércoles',
    descripcion:
        'Miércoles Addams llega a la academia Nunca Más, donde intenta '
        'controlar sus poderes mientras investiga los extraños sucesos que '
        'aterrorizan al pueblo.',
    tipo: 'Vídeo',
    duracion: '2 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/9PFonBhy4cQy7Jz20NpMygczOkv.jpg',
    fondoUrl: '$_fondo/iHSwvRVsRyxpX7FE7GbviaDvgGZ.jpg',
    videoUrl: _videoElephants,
    anio: 2022,
    edad: '13+',
    coincidencia: 96,
    generos: ['Misterio', 'Comedia', 'Fantasía'],
    creditosVideo: _creditosElephants,
    esTop10: true,
  ),
  Contenido(
    id: 3,
    titulo: 'La casa de papel',
    descripcion:
        'Un misterioso hombre conocido como el Profesor reúne a ocho '
        'atracadores con un plan sin precedentes: asaltar la Fábrica '
        'Nacional de Moneda y Timbre.',
    tipo: 'Vídeo',
    duracion: '5 partes',
    categoria: 'Serie',
    imagenUrl: '$_poster/reEMJA1uzscCbkpeRJeTT2bjqUp.jpg',
    fondoUrl: '$_fondo/gFZriCkpJYsApPZEF3jhxL4yLzG.jpg',
    videoUrl: _videoTears,
    anio: 2017,
    edad: '16+',
    coincidencia: 95,
    generos: ['Acción', 'Suspense', 'Crimen'],
    creditosVideo: _creditosTears,
    esTop10: true,
  ),
  Contenido(
    id: 4,
    titulo: 'Breaking Bad',
    descripcion:
        'Un profesor de química con una enfermedad terminal se asocia con un '
        'antiguo alumno para fabricar metanfetamina y asegurar el futuro de '
        'su familia.',
    tipo: 'Vídeo',
    duracion: '5 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
    fondoUrl: '$_fondo/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
    videoUrl: _videoSintel,
    anio: 2008,
    edad: '18+',
    coincidencia: 97,
    generos: ['Drama', 'Crimen', 'Suspense'],
    creditosVideo: _creditosSintel,
  ),
  Contenido(
    id: 5,
    titulo: 'The Last of Us',
    descripcion:
        'Veinte años después de la caída de la civilización, Joel, un '
        'superviviente curtido, recibe el encargo de sacar a Ellie, una '
        'adolescente, de una zona de cuarentena.',
    tipo: 'Vídeo',
    duracion: '2 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
    fondoUrl: '$_fondo/uDgy6hyPd82kOHh6I95FLtLnj6p.jpg',
    videoUrl: _videoTears,
    anio: 2023,
    edad: '18+',
    coincidencia: 94,
    generos: ['Drama', 'Ciencia ficción', 'Acción'],
    creditosVideo: _creditosTears,
    esTop10: true,
  ),
  Contenido(
    id: 6,
    titulo: 'El juego del calamar',
    descripcion:
        'Cientos de personas con problemas económicos aceptan una extraña '
        'invitación para competir en juegos infantiles. Les espera un premio '
        'millonario… y un riesgo enorme.',
    tipo: 'Vídeo',
    duracion: '3 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/dDlEmu3EZ0Pgg93K2SVNLCjCSvE.jpg',
    fondoUrl: '$_fondo/qw3J9cNeLioOLoR68WX7z79aCdK.jpg',
    videoUrl: _videoSintel,
    anio: 2021,
    edad: '18+',
    coincidencia: 93,
    generos: ['Suspense', 'Drama', 'Acción'],
    creditosVideo: _creditosSintel,
    esTop10: true,
  ),
  Contenido(
    id: 7,
    titulo: 'Arcane',
    descripcion:
        'En pleno conflicto entre la próspera Piltover y la oprimida ciudad '
        'subterránea de Zaun, dos hermanas acaban luchando en bandos '
        'opuestos de una guerra de tecnologías mágicas.',
    tipo: 'Vídeo',
    duracion: '2 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/fqldf2t8ztc9aiwn3k6mlX3tvRT.jpg',
    fondoUrl: '$_fondo/rkB4LyZHo1NHXFEDHl9vSD9r1lI.jpg',
    videoUrl: _videoSintel,
    anio: 2021,
    edad: '16+',
    coincidencia: 99,
    generos: ['Animación', 'Acción', 'Fantasía'],
    creditosVideo: _creditosSintel,
    destacado: true,
    esTop10: true,
  ),
  Contenido(
    id: 8,
    titulo: 'Dark',
    descripcion:
        'La desaparición de dos niños en un pueblo alemán destapa los '
        'secretos de cuatro familias y un misterio que abarca varias '
        'generaciones.',
    tipo: 'Vídeo',
    duracion: '3 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/apbrbWs8M9lyOpJYU5WXrpFbk1Z.jpg',
    fondoUrl: '$_fondo/5LoHuHWA4H8jElFlZDvsmU2n63b.jpg',
    videoUrl: _videoElephants,
    anio: 2017,
    edad: '16+',
    coincidencia: 95,
    generos: ['Ciencia ficción', 'Misterio', 'Drama'],
    creditosVideo: _creditosElephants,
  ),
  Contenido(
    id: 9,
    titulo: 'Peaky Blinders',
    descripcion:
        'En la Birmingham de 1919, la familia Shelby dirige una banda '
        'criminal que aspira a ampliar su imperio a cualquier precio.',
    tipo: 'Vídeo',
    duracion: '6 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/vUUqzWa2LnHIVqkaKVlVGkVcZIW.jpg',
    fondoUrl: '$_fondo/wiE9doxiLwq3WCGamDIOb2PqBqc.jpg',
    videoUrl: _videoBunny,
    anio: 2013,
    edad: '18+',
    coincidencia: 91,
    generos: ['Drama', 'Crimen'],
    creditosVideo: _creditosBunny,
  ),
  Contenido(
    id: 10,
    titulo: 'The Mandalorian',
    descripcion:
        'Tras la caída del Imperio, un cazarrecompensas solitario recorre '
        'los confines de la galaxia, lejos de la autoridad de la Nueva '
        'República.',
    tipo: 'Vídeo',
    duracion: '3 temporadas',
    categoria: 'Serie',
    imagenUrl: '$_poster/eU1i6eHXlzMOlEq0ku1Rzq7Y4wA.jpg',
    fondoUrl: '$_fondo/9ijMGlJKqcslswWUzTEwScm82Gs.jpg',
    videoUrl: _videoTears,
    anio: 2019,
    edad: '13+',
    coincidencia: 92,
    generos: ['Ciencia ficción', 'Aventura', 'Acción'],
    creditosVideo: _creditosTears,
  ),

  // ------------------------------ PELÍCULAS ------------------------------
  Contenido(
    id: 11,
    titulo: 'Oppenheimer',
    descripcion:
        'La historia del físico J. Robert Oppenheimer y de su papel en el '
        'desarrollo de la bomba atómica durante la Segunda Guerra Mundial.',
    tipo: 'Vídeo',
    duracion: '3 h 1 min',
    categoria: 'Película',
    imagenUrl: '$_poster/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
    fondoUrl: '$_fondo/fm6KqXpk3M2HVveHwCrBSSBaO0V.jpg',
    videoUrl: _videoElephants,
    anio: 2023,
    edad: '16+',
    coincidencia: 97,
    generos: ['Drama', 'Historia'],
    creditosVideo: _creditosElephants,
    destacado: true,
    esTop10: true,
  ),
  Contenido(
    id: 12,
    titulo: 'Barbie',
    descripcion:
        'Barbie vive feliz en Barbieland hasta que empieza a hacerse '
        'preguntas inesperadas. Su búsqueda de respuestas la lleva, junto a '
        'Ken, al mundo real.',
    tipo: 'Vídeo',
    duracion: '1 h 54 min',
    categoria: 'Película',
    imagenUrl: '$_poster/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
    fondoUrl: '$_fondo/ctMserH8g2SeOAnCw5gFjdQF8mo.jpg',
    videoUrl: _videoBunny,
    anio: 2023,
    edad: '7+',
    coincidencia: 89,
    generos: ['Comedia', 'Aventura', 'Fantasía'],
    creditosVideo: _creditosBunny,
    esTop10: true,
  ),
  Contenido(
    id: 13,
    titulo: 'Spider-Man: Cruzando el Multiverso',
    descripcion:
        'Miles Morales viaja a través del multiverso y se encuentra con un '
        'equipo de Spider-Personas encargado de proteger su existencia.',
    tipo: 'Vídeo',
    duracion: '2 h 20 min',
    categoria: 'Película',
    imagenUrl: '$_poster/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
    fondoUrl: '$_fondo/4HodYYKEIsGOdinkGi2Ucz6X9i0.jpg',
    videoUrl: _videoBunny,
    anio: 2023,
    edad: '7+',
    coincidencia: 96,
    generos: ['Animación', 'Acción', 'Aventura'],
    creditosVideo: _creditosBunny,
  ),
  Contenido(
    id: 14,
    titulo: 'Dune: Parte Dos',
    descripcion:
        'Paul Atreides se une a Chani y a los Fremen mientras busca '
        'venganza contra quienes destruyeron a su familia.',
    tipo: 'Vídeo',
    duracion: '2 h 46 min',
    categoria: 'Película',
    imagenUrl: '$_poster/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
    fondoUrl: '$_fondo/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
    videoUrl: _videoTears,
    anio: 2024,
    edad: '13+',
    coincidencia: 98,
    generos: ['Ciencia ficción', 'Aventura', 'Drama'],
    creditosVideo: _creditosTears,
    destacado: true,
    esTop10: true,
  ),
  Contenido(
    id: 15,
    titulo: 'Interstellar',
    descripcion:
        'Con la Tierra al borde del colapso, un grupo de exploradores '
        'atraviesa un agujero de gusano en busca de un nuevo hogar para la '
        'humanidad.',
    tipo: 'Vídeo',
    duracion: '2 h 49 min',
    categoria: 'Película',
    imagenUrl: '$_poster/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    fondoUrl: '$_fondo/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
    videoUrl: _videoElephants,
    anio: 2014,
    edad: '13+',
    coincidencia: 97,
    generos: ['Ciencia ficción', 'Drama', 'Aventura'],
    creditosVideo: _creditosElephants,
  ),
  Contenido(
    id: 16,
    titulo: 'Origen',
    descripcion:
        'Dom Cobb es un ladrón experto en robar secretos del subconsciente '
        'mientras la gente sueña. Ahora le proponen algo aún más difícil: '
        'implantar una idea.',
    tipo: 'Vídeo',
    duracion: '2 h 28 min',
    categoria: 'Película',
    imagenUrl: '$_poster/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    fondoUrl: '$_fondo/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
    videoUrl: _videoTears,
    anio: 2010,
    edad: '13+',
    coincidencia: 95,
    generos: ['Ciencia ficción', 'Acción', 'Suspense'],
    creditosVideo: _creditosTears,
  ),
  Contenido(
    id: 17,
    titulo: 'Coco',
    descripcion:
        'Miguel sueña con ser músico, aunque su familia se lo prohíbe. Un '
        'misterioso suceso le lleva a la colorida Tierra de los Muertos.',
    tipo: 'Vídeo',
    duracion: '1 h 45 min',
    categoria: 'Película',
    imagenUrl: '$_poster/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg',
    fondoUrl: '$_fondo/askg3SMvhqEl4OL52YuvdtY40Yb.jpg',
    videoUrl: _videoBunny,
    anio: 2017,
    edad: '7+',
    coincidencia: 94,
    generos: ['Animación', 'Familia', 'Fantasía'],
    creditosVideo: _creditosBunny,
  ),
  Contenido(
    id: 18,
    titulo: 'Top Gun: Maverick',
    descripcion:
        'Tras más de treinta años de servicio, Pete «Maverick» Mitchell '
        'entrena a un grupo de pilotos de élite para una misión '
        'especialmente peligrosa.',
    tipo: 'Vídeo',
    duracion: '2 h 11 min',
    categoria: 'Película',
    imagenUrl: '$_poster/62HCnUTziyWcpDaBO2i1DX17ljH.jpg',
    fondoUrl: '$_fondo/AaV1YIdWKnjAIAOe8UUKBFm327v.jpg',
    videoUrl: _videoTears,
    anio: 2022,
    edad: '13+',
    coincidencia: 90,
    generos: ['Acción', 'Drama'],
    creditosVideo: _creditosTears,
  ),
  Contenido(
    id: 19,
    titulo: 'Del revés 2',
    descripcion:
        'Riley entra en la adolescencia y, en el cuartel general de su '
        'mente, las emociones de siempre deben hacer sitio a otras nuevas e '
        'inesperadas.',
    tipo: 'Vídeo',
    duracion: '1 h 36 min',
    categoria: 'Película',
    imagenUrl: '$_poster/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
    fondoUrl: '$_fondo/stKGOm8UyhuLPR9sZLjs5AkmncA.jpg',
    videoUrl: _videoBunny,
    anio: 2024,
    edad: '7+',
    coincidencia: 92,
    generos: ['Animación', 'Familia', 'Comedia'],
    creditosVideo: _creditosBunny,
    esTop10: true,
  ),
  Contenido(
    id: 20,
    titulo: 'The Batman',
    descripcion:
        'En su segundo año como justiciero, Batman sigue el rastro de un '
        'asesino en serie que tiene en el punto de mira a la élite de '
        'Gotham.',
    tipo: 'Vídeo',
    duracion: '2 h 56 min',
    categoria: 'Película',
    imagenUrl: '$_poster/74xTEgt7R36Fpooo50r9T25onhq.jpg',
    fondoUrl: '$_fondo/b0PlSFdDwbyK0cf5RxwDpaOJQvQ.jpg',
    videoUrl: _videoSintel,
    anio: 2022,
    edad: '16+',
    coincidencia: 93,
    generos: ['Crimen', 'Misterio', 'Acción'],
    creditosVideo: _creditosSintel,
  ),
  Contenido(
    id: 21,
    titulo: 'Joker',
    descripcion:
        'Arthur Fleck, un cómico fracasado que lucha por encajar en una '
        'Gotham cada vez más hostil, inicia un lento descenso hacia la '
        'locura.',
    tipo: 'Vídeo',
    duracion: '2 h 2 min',
    categoria: 'Película',
    imagenUrl: '$_poster/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
    fondoUrl: '$_fondo/hO7KbdvGOtDdeg0W4Y5nKEHeDDh.jpg',
    videoUrl: _videoElephants,
    anio: 2019,
    edad: '18+',
    coincidencia: 88,
    generos: ['Crimen', 'Suspense', 'Drama'],
    creditosVideo: _creditosElephants,
  ),
  Contenido(
    id: 22,
    titulo: 'Parásitos',
    descripcion:
        'La familia Kim, sin empleo y con pocos recursos, empieza a '
        'interesarse por el estilo de vida de los adinerados Park, hasta '
        'que todo se complica de forma inesperada.',
    tipo: 'Vídeo',
    duracion: '2 h 12 min',
    categoria: 'Película',
    imagenUrl: '$_poster/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
    fondoUrl: '$_fondo/hiKmpZMGZsrkA3cdce8a7Dpos1j.jpg',
    videoUrl: _videoSintel,
    anio: 2019,
    edad: '16+',
    coincidencia: 91,
    generos: ['Suspense', 'Drama', 'Comedia'],
    creditosVideo: _creditosSintel,
  ),

  // ---------------- CORTOS DE ANIMACIÓN LIBRES (Blender) -----------------
  // Son películas completas con licencia Creative Commons: se pueden
  // ver, compartir y usar citando a sus autores.
  Contenido(
    id: 23,
    titulo: 'Big Buck Bunny',
    descripcion:
        'Un conejo gigante y bonachón decide dar una lección a tres '
        'roedores abusones que no paran de molestar a los animales del '
        'bosque.',
    tipo: 'Vídeo',
    duracion: '10 min',
    categoria: 'Película',
    imagenUrl: 'assets/cortos/big_buck_bunny_poster.jpg',
    fondoUrl: 'assets/cortos/big_buck_bunny_fondo.jpg',
    videoUrl: _videoBunny,
    anio: 2008,
    edad: '7+',
    coincidencia: 90,
    generos: ['Animación', 'Comedia', 'Familia'],
    creditosVideo:
        'Big Buck Bunny © Blender Foundation · peach.blender.org · CC BY 3.0',
    esCortoLibre: true,
  ),
  Contenido(
    id: 24,
    titulo: 'Sintel',
    descripcion:
        'Una joven guerrera recorre tierras heladas en busca del pequeño '
        'dragón al que cuidó y que le fue arrebatado.',
    tipo: 'Vídeo',
    duracion: '15 min',
    categoria: 'Película',
    imagenUrl: 'assets/cortos/sintel_poster.jpg',
    fondoUrl: 'assets/cortos/sintel_fondo.jpg',
    videoUrl: _videoSintel,
    anio: 2010,
    edad: '13+',
    coincidencia: 94,
    generos: ['Animación', 'Fantasía', 'Aventura'],
    creditosVideo:
        'Sintel © Blender Foundation · durian.blender.org · CC BY 3.0',
    esCortoLibre: true,
  ),
  Contenido(
    id: 25,
    titulo: 'Tears of Steel',
    descripcion:
        'En una Ámsterdam futurista, un grupo de científicos intenta salvar '
        'el mundo de un ejército de robots reviviendo un momento del pasado.',
    tipo: 'Vídeo',
    duracion: '12 min',
    categoria: 'Película',
    imagenUrl: 'assets/cortos/tears_of_steel_poster.jpg',
    fondoUrl: 'assets/cortos/tears_of_steel_fondo.jpg',
    videoUrl: _videoTears,
    anio: 2012,
    edad: '13+',
    coincidencia: 87,
    generos: ['Ciencia ficción', 'Acción'],
    creditosVideo:
        'Tears of Steel © Blender Foundation · mango.blender.org · CC BY 3.0',
    esCortoLibre: true,
  ),
  Contenido(
    id: 26,
    titulo: 'Elephants Dream',
    descripcion:
        'Emo y Proog recorren una máquina infinita y surrealista que cada '
        'uno entiende de una forma muy distinta.',
    tipo: 'Vídeo',
    duracion: '11 min',
    categoria: 'Película',
    imagenUrl: 'assets/cortos/elephants_dream_poster.jpg',
    fondoUrl: 'assets/cortos/elephants_dream_fondo.jpg',
    videoUrl: _videoElephants,
    anio: 2006,
    edad: '13+',
    coincidencia: 86,
    generos: ['Animación', 'Ciencia ficción'],
    creditosVideo:
        'Elephants Dream © Blender Foundation · orange.blender.org · CC BY 2.5',
    esCortoLibre: true,
  ),
];

// ------------------------- CONSULTAS DEL CATÁLOGO -------------------------
// Pequeñas funciones que "preguntan" a la lista. Cuando haya una API REST,
// estas mismas consultas se harán al servidor y las pantallas no cambiarán.

// Títulos comerciales (sin los cortos libres), opcionalmente de una categoría.
Iterable<Contenido> _catalogo([String? categoria]) => contenidos.where(
  (c) => !c.esCortoLibre && (categoria == null || c.categoria == categoria),
);

// Busca un contenido por su id (null si no existe).
Contenido? contenidoPorId(int id) {
  for (final c in contenidos) {
    if (c.id == id) return c;
  }
  return null;
}

// Títulos del carrusel principal. Si la categoría no tiene destacados,
// usamos los tres mejor valorados para que el carrusel nunca quede vacío.
List<Contenido> destacados([String? categoria]) {
  final lista = _catalogo(categoria).where((c) => c.destacado).toList();
  if (lista.isNotEmpty) return lista;
  return (_catalogo(categoria).toList()
        ..sort((a, b) => b.coincidencia.compareTo(a.coincidencia)))
      .take(3)
      .toList();
}

// Top 10, en el orden en el que aparecen en la lista.
List<Contenido> top10([String? categoria]) =>
    _catalogo(categoria).where((c) => c.esTop10).take(10).toList();

// Tendencias: lo más reciente primero y, a igualdad, lo más afín al usuario.
List<Contenido> tendencias([String? categoria]) =>
    _catalogo(categoria).toList()..sort((a, b) {
      final porAnio = b.anio.compareTo(a.anio);
      return porAnio != 0 ? porAnio : b.coincidencia.compareTo(a.coincidencia);
    });

// Todas las series o todas las películas.
List<Contenido> porCategoria(String categoria) => _catalogo(categoria).toList();

// Títulos de un género (incluye los cortos libres).
List<Contenido> porGenero(String genero, [String? categoria]) => contenidos
    .where(
      (c) =>
          c.generos.contains(genero) &&
          (categoria == null || c.categoria == categoria),
    )
    .toList();

// Los cortos de animación de la Blender Foundation.
List<Contenido> cortosLibres() =>
    contenidos.where((c) => c.esCortoLibre).toList();

// "Más títulos como este": los que comparten más géneros con el contenido.
List<Contenido> similares(Contenido contenido, {int maximo = 9}) {
  int comunes(Contenido c) =>
      c.generos.where(contenido.generos.contains).length;
  final lista =
      contenidos.where((c) => c.id != contenido.id && comunes(c) > 0).toList()
        ..sort((a, b) {
          final porGeneros = comunes(b).compareTo(comunes(a));
          return porGeneros != 0
              ? porGeneros
              : b.coincidencia.compareTo(a.coincidencia);
        });
  return lista.take(maximo).toList();
}

// Pasa a minúsculas y quita las tildes para que buscar "accion"
// encuentre "Acción" y "miercoles" encuentre "Miércoles".
String normalizar(String texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüû';
  const sinTilde = 'aaaaeeeeiiiioooouuuu';
  final buffer = StringBuffer();
  for (final letra in texto.toLowerCase().trim().split('')) {
    final i = conTilde.indexOf(letra);
    buffer.write(i == -1 ? letra : sinTilde[i]);
  }
  return buffer.toString();
}

// Búsqueda por título o por género.
List<Contenido> buscarContenidos(String texto) {
  final consulta = normalizar(texto);
  if (consulta.isEmpty) return const [];
  return contenidos
      .where(
        (c) =>
            normalizar(c.titulo).contains(consulta) ||
            c.generos.any((g) => normalizar(g).contains(consulta)),
      )
      .toList();
}
