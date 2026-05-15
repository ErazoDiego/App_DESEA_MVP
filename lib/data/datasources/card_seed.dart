import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/carta_model.dart';

/// Seeds the Hive cartas box from embedded JSON assets.
///
/// Only adds cards whose [id] doesn't already exist in the box — safe to
/// call on every launch without overwriting user data or existing cards.
Future<void> seedCartasIfNeeded(Box<CartaModel> cartasBox) async {
  const sources = ['suave.json', 'picante.json', 'intenso.json', 'cierre.json'];

  for (final source in sources) {
    final jsonString = await rootBundle.loadString('assets/cartas/$source');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    for (final jsonItem in jsonList) {
      final map = jsonItem as Map<String, dynamic>;
      final id = map['id'] as String;

      // Skip if card already exists — never overwrite
      if (cartasBox.containsKey(id)) continue;

      final carta = CartaModel(
        id: id,
        tipo: map['tipo'] as String,
        texto: map['texto'] as String,
        dirigida: map['dirigida'] as String,
        tiempoSegundos: map['tiempo_segundos'] as int?,
        imagenUrl: map['imagen_url'] as String?,
      );
      await cartasBox.put(carta.id, carta);
    }
  }
}
