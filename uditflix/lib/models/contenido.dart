// MODELO CONTENIDO

// Esta clase representa un contenido de nuestra plataforma UDITflix.
// Por ejemplo: una película, un cómic o un videojuego

// En programación orientada a objetos, una clase define qué características tendrán los objetos que creemos

class Contenido {
  // ---------- Campos originales (no se tocan) ----------
  final int id;
  final String titulo;
  final String descripcion;
  // Tipo de contenido: vídeo, cómic o juego
  final String tipo;
  // Duración legible: "2 h 1 min" en películas o "4 temporadas" en series.
  final String duracion;

  // ---------- Campos nuevos para la versión "streaming" ----------

  // 'Película' o 'Serie'. Sirve para los filtros y las filas del catálogo.
  final String categoria;
  // Póster vertical (proporción 2:3). Puede ser una URL https
  // o la ruta de un asset local (los cortos libres van empaquetados).
  final String imagenUrl;
  // Imagen horizontal de fondo (backdrop) para el destacado y la ficha.
  final String fondoUrl;
  // Dirección del vídeo que reproduce el ReproductorScreen.
  final String videoUrl;
  // Año de estreno.
  final int anio;
  // Clasificación por edad, por ejemplo '13+' o '16+'.
  final String edad;
  // Porcentaje de coincidencia con el usuario ("97 % para ti"), entre 85 y 99.
  final int coincidencia;
  // Géneros del título, del más importante al menos.
  final List<String> generos;
  // Si es true aparece en el carrusel grande de la pantalla de inicio.
  final bool destacado;
  // Si es true aparece en la fila "Top 10 en España hoy".
  final bool esTop10;
  // Atribución del vídeo de demostración (licencias Creative Commons).
  final String creditosVideo;
  // Indica que es uno de los cortos libres de la Blender Foundation,
  // que tienen su propia fila en el catálogo.
  final bool esCortoLibre;

  // Constructor: permite crear nuevos Contenido

  const Contenido({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.duracion,
    required this.categoria,
    required this.imagenUrl,
    required this.fondoUrl,
    required this.videoUrl,
    required this.anio,
    required this.edad,
    required this.coincidencia,
    required this.generos,
    required this.creditosVideo,
    this.destacado = false,
    this.esTop10 = false,
    this.esCortoLibre = false,
  });

  // Getters de ayuda: datos calculados a partir de los campos.

  bool get esSerie => categoria == 'Serie';
  bool get esPelicula => categoria == 'Película';

  // Géneros listos para mostrar: "Drama • Historia • Suspense".
  String get generosTexto => generos.join(' • ');
}
