/// Tipos de carta disponibles en el juego.
///
/// Cada carta pertenece a una de tres categorías:
/// - [verdad]: Pregunta o desafío basado en verdad.
/// - [reto]: Desafío basado en acción.
/// - [deseo]: Expresión o acción basada en deseo.
enum TipoCarta { verdad, reto, deseo }

/// Audiencia objetivo para una carta.
///
/// - [mixta]: Apropiada para ambos miembros de la pareja.
/// - [paraEl]: Pensada para el miembro masculino.
/// - [paraElla]: Pensada para el miembro femenino.
enum Dirigida { mixta, paraEl, paraElla }

/// Representa una carta individual del juego.
///
/// Una [Carta] es la unidad fundamental del juego, con un tipo (verdad, reto
/// o deseo), texto descriptivo, audiencia objetivo y un límite de tiempo
/// opcional.
class Carta {
  final String id;
  final TipoCarta tipo;
  final String texto;
  final Dirigida dirigida;
  final Duration? tiempoSegundos;

  /// URL o path de asset para imagen de fondo (opcional).
  final String? imagenUrl;

  const Carta({
    required this.id,
    required this.tipo,
    required this.texto,
    this.dirigida = Dirigida.mixta,
    this.tiempoSegundos,
    this.imagenUrl,
  });

  Carta copyWith({
    String? id,
    TipoCarta? tipo,
    String? texto,
    Dirigida? dirigida,
    Duration? tiempoSegundos,
    String? imagenUrl,
  }) {
    return Carta(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      texto: texto ?? this.texto,
      dirigida: dirigida ?? this.dirigida,
      tiempoSegundos: tiempoSegundos ?? this.tiempoSegundos,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Carta &&
        other.id == id &&
        other.tipo == tipo &&
        other.texto == texto &&
        other.dirigida == dirigida &&
        other.tiempoSegundos == tiempoSegundos &&
        other.imagenUrl == imagenUrl;
  }

  @override
  int get hashCode {
    return Object.hash(id, tipo, texto, dirigida, tiempoSegundos, imagenUrl);
  }

  @override
  String toString() {
    return 'Carta(id: $id, tipo: $tipo, texto: $texto, dirigida: $dirigida, '
        'tiempoSegundos: $tiempoSegundos, imagenUrl: $imagenUrl)';
  }
}
