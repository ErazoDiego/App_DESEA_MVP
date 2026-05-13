/// Fase actual de una sesión de juego.
///
/// Las sesiones progresan a través de cuatro fases:
/// - [calentamiento]: Fase de entrada con cartas más livianas.
/// - [tension]: Aumento de intensidad con cartas desafiantes.
/// - [climax]: Fase cumbre con las cartas más intensas.
/// - [cierre]: Fase de cierre para terminar la sesión.
enum Fase { calentamiento, tension, climax, cierre }

/// Modo de juego de una sesión.
///
/// - [sesion]: Sesión estructurada que progresa por fases.
/// - [libre]: Sesión libre sin progresión de fases.
enum Modo { sesion, libre }

/// Representa una sesión de juego con su estado y progreso.
///
/// Una [Sesion] lleva el registro del estado actual de juego,
/// incluyendo el modo (estructurado o libre), la fase actual,
/// el índice de carta en curso y los tiempos de inicio y cierre.
class Sesion {
  final String id;
  final Modo modo;
  final Fase fase;
  final int currentCardIndex;
  final List<String> cartasUsadasIds;
  final List<String> cartasIds;
  final DateTime? iniciadaEn;
  final DateTime? completadaEn;

  const Sesion({
    required this.id,
    this.modo = Modo.sesion,
    this.fase = Fase.calentamiento,
    this.currentCardIndex = 0,
    this.cartasUsadasIds = const [],
    this.cartasIds = const [],
    this.iniciadaEn,
    this.completadaEn,
  });

  Sesion copyWith({
    String? id,
    Modo? modo,
    Fase? fase,
    int? currentCardIndex,
    List<String>? cartasUsadasIds,
    List<String>? cartasIds,
    DateTime? iniciadaEn,
    DateTime? completadaEn,
  }) {
    return Sesion(
      id: id ?? this.id,
      modo: modo ?? this.modo,
      fase: fase ?? this.fase,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      cartasUsadasIds: cartasUsadasIds ?? this.cartasUsadasIds,
      cartasIds: cartasIds ?? this.cartasIds,
      iniciadaEn: iniciadaEn ?? this.iniciadaEn,
      completadaEn: completadaEn ?? this.completadaEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sesion &&
        other.id == id &&
        other.modo == modo &&
        other.fase == fase &&
        other.currentCardIndex == currentCardIndex &&
        _listEquals(other.cartasUsadasIds, cartasUsadasIds) &&
        _listEquals(other.cartasIds, cartasIds) &&
        other.iniciadaEn == iniciadaEn &&
        other.completadaEn == completadaEn;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      modo,
      fase,
      currentCardIndex,
      Object.hashAll(cartasUsadasIds),
      Object.hashAll(cartasIds),
      iniciadaEn,
      completadaEn,
    );
  }

  @override
  String toString() {
    return 'Sesion(id: $id, modo: $modo, fase: $fase, '
        'currentCardIndex: $currentCardIndex, '
        'cartasUsadasIds: $cartasUsadasIds, '
        'cartasIds: $cartasIds, '
        'iniciadaEn: $iniciadaEn, completadaEn: $completadaEn)';
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
