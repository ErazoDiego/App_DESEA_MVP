/// Representa una carta personalizada creada por el usuario en modo libre.
///
/// A diferencia de [Carta], esta entidad usa valores de tipo `String` para
/// [categoria], [nivel] y [dirigida] porque el usuario los escribe libremente
/// sin restricciones de enumeraciones predefinidas.
class CartaPersonalizada {
  final String id;
  final String texto;

  /// Categoría libre: "verdad", "reto", "deseo", "sinLimites", etc.
  final String? categoria;

  /// Nivel de intensidad: "suave", "picante", "intenso".
  final String nivel;

  /// Límite de tiempo opcional para ejecutar la carta.
  final Duration? tiempoSegundos;

  /// A quién va dirigida: opcional, valor libre.
  final String? dirigida;

  /// Fecha y hora de creación de la carta.
  final DateTime creadaEn;

  /// URL o path de asset para imagen de fondo (opcional).
  final String? imagenUrl;

  const CartaPersonalizada({
    required this.id,
    required this.texto,
    this.categoria,
    required this.nivel,
    this.tiempoSegundos,
    this.dirigida,
    required this.creadaEn,
    this.imagenUrl,
  });

  CartaPersonalizada copyWith({
    String? id,
    String? texto,
    String? categoria,
    String? nivel,
    Duration? tiempoSegundos,
    String? dirigida,
    DateTime? creadaEn,
    String? imagenUrl,
  }) {
    return CartaPersonalizada(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      categoria: categoria ?? this.categoria,
      nivel: nivel ?? this.nivel,
      tiempoSegundos: tiempoSegundos ?? this.tiempoSegundos,
      dirigida: dirigida ?? this.dirigida,
      creadaEn: creadaEn ?? this.creadaEn,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartaPersonalizada &&
        other.id == id &&
        other.texto == texto &&
        other.categoria == categoria &&
        other.nivel == nivel &&
        other.tiempoSegundos == tiempoSegundos &&
        other.dirigida == dirigida &&
        other.creadaEn == creadaEn &&
        other.imagenUrl == imagenUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      texto,
      categoria,
      nivel,
      tiempoSegundos,
      dirigida,
      creadaEn,
      imagenUrl,
    );
  }

  @override
  String toString() {
    return 'CartaPersonalizada(id: $id, texto: $texto, categoria: $categoria, '
        'nivel: $nivel, tiempoSegundos: $tiempoSegundos, dirigida: $dirigida, '
        'creadaEn: $creadaEn, imagenUrl: $imagenUrl)';
  }
}
