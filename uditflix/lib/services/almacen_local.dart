// SERVICIO DE ALMACENAMIENTO LOCAL

// UDITflix todavía no tiene servidor, así que lo que el usuario
// "personaliza" se guarda en el propio móvil con shared_preferences,
// un pequeño almacén clave → valor que sobrevive al cerrar la app.
//
// Guardamos tres cosas:
//   1. Mi lista: los ids de los títulos guardados.
//   2. Continuar viendo: id → segundo en el que se quedó y duración total.
//   3. Récords de los juegos del Arcade: nombre del juego → puntuación.
//
// La clase extiende ChangeNotifier: cuando algo cambia avisa a las
// pantallas que la escuchan (por ejemplo, Mi lista se actualiza sola
// al pulsar "+ Mi lista" en la ficha de un título).

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progreso_visionado.dart';

class AlmacenLocal extends ChangeNotifier {
  AlmacenLocal();

  // Instancia única que comparte toda la aplicación.
  static final AlmacenLocal instancia = AlmacenLocal();

  // Claves con las que se guardan los datos.
  static const String _claveMiLista = 'mi_lista';
  static const String _claveContinuar = 'continuar_viendo';
  static const String _prefijoRecord = 'record_';

  SharedPreferences? _prefs;

  // Copias en memoria para no leer y decodificar en cada build.
  final List<int> _miLista = [];
  final Map<int, ProgresoVisionado> _progresos = {};

  // Carga los datos guardados. Se llama una vez al arrancar la app.
  // Si ya se cargaron antes, no hace nada.
  Future<void> iniciar() async {
    if (_prefs != null) return;
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    _miLista
      ..clear()
      ..addAll(
        (prefs.getStringList(_claveMiLista) ?? const <String>[])
            .map(int.tryParse)
            .whereType<int>(),
      );

    _progresos.clear();
    final json = prefs.getString(_claveContinuar);
    if (json != null) {
      try {
        final lista = jsonDecode(json) as List<dynamic>;
        for (final item in lista) {
          final progreso = ProgresoVisionado.fromJson(
            item as Map<String, dynamic>,
          );
          _progresos[progreso.idContenido] = progreso;
        }
      } catch (e) {
        // Si el dato estuviera corrupto, empezamos de cero en vez de fallar.
        debugPrint('Continuar viendo ilegible, se reinicia: $e');
      }
    }
    notifyListeners();
  }

  // ------------------------------ MI LISTA ------------------------------

  // Ids guardados, el último añadido primero (como en las apps de streaming).
  List<int> get miLista => List.unmodifiable(_miLista.reversed);

  bool estaEnMiLista(int id) => _miLista.contains(id);

  // Añade el título si no estaba y lo quita si ya estaba.
  // Devuelve true si después de la operación está en la lista.
  Future<bool> alternarMiLista(int id) async {
    final anadido = !_miLista.remove(id);
    if (anadido) _miLista.add(id);
    notifyListeners();
    await _prefs?.setStringList(
      _claveMiLista,
      _miLista.map((e) => '$e').toList(),
    );
    return anadido;
  }

  // -------------------------- CONTINUAR VIENDO --------------------------

  ProgresoVisionado? progresoDe(int id) => _progresos[id];

  // Progresos ordenados del más reciente al más antiguo.
  List<ProgresoVisionado> get continuarViendo {
    final lista = _progresos.values.toList()
      ..sort((a, b) => b.actualizado.compareTo(a.actualizado));
    return lista;
  }

  // Guarda la posición actual de un vídeo.
  Future<void> guardarProgreso(
    int id, {
    required int segundos,
    required int duracionTotal,
  }) async {
    _progresos[id] = ProgresoVisionado(
      idContenido: id,
      segundos: segundos,
      duracionTotal: duracionTotal,
      actualizado: DateTime.now(),
    );
    notifyListeners();
    await _guardarProgresos();
  }

  // Elimina el progreso (por ejemplo, cuando el vídeo se ha visto entero).
  Future<void> borrarProgreso(int id) async {
    if (_progresos.remove(id) == null) return;
    notifyListeners();
    await _guardarProgresos();
  }

  Future<void> _guardarProgresos() async {
    final json = jsonEncode(_progresos.values.map((p) => p.toJson()).toList());
    await _prefs?.setString(_claveContinuar, json);
  }

  // ------------------------------- RÉCORDS -------------------------------

  // Mejor puntuación de un juego (0 si nunca se ha jugado).
  int recordDe(String juego) => _prefs?.getInt('$_prefijoRecord$juego') ?? 0;

  // Registra una puntuación. Solo se guarda si supera el récord anterior.
  // Devuelve true cuando es un nuevo récord.
  Future<bool> registrarPuntuacion(String juego, int puntos) async {
    if (puntos <= recordDe(juego)) return false;
    await _prefs?.setInt('$_prefijoRecord$juego', puntos);
    notifyListeners();
    return true;
  }
}
