/// Nivel de intensidad de un mazo de cartas.
///
/// - [suave]: Suave, apto para jugadores principiantes.
/// - [picante]: Moderado, para jugadores aventureros.
/// - [intenso]: Intenso, para jugadores experimentados.
enum Nivel { suave, picante, intenso }

/// Representa un mazo (baraja) de cartas con un tema y dificultad.
///
/// Un [Mazo] agrupa cartas por temática y nivel de intensidad,
/// proveyendo una forma estructurada de organizar y seleccionar
/// cartas para una sesión de juego.
class Mazo {
  final String id;
  final String nombre;
  final Nivel nivel;
  final List<String> cartaIds;

  const Mazo({
    required this.id,
    required this.nombre,
    this.nivel = Nivel.suave,
    this.cartaIds = const [],
  });

  Mazo copyWith({
    String? id,
    String? nombre,
    Nivel? nivel,
    List<String>? cartaIds,
  }) {
    return Mazo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nivel: nivel ?? this.nivel,
      cartaIds: cartaIds ?? this.cartaIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mazo &&
        other.id == id &&
        other.nombre == nombre &&
        other.nivel == nivel &&
        _listEquals(other.cartaIds, cartaIds);
  }

  @override
  int get hashCode {
    return Object.hash(id, nombre, nivel, Object.hashAll(cartaIds));
  }

  @override
  String toString() {
    return 'Mazo(id: $id, nombre: $nombre, nivel: $nivel, '
        'cartaIds: $cartaIds)';
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
