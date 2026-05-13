import '../../domain/entities/carta.dart';
import '../../domain/entities/mazo.dart';
import '../../domain/entities/sesion.dart';

/// Estado inmutable de la sesión en modo libre.
///
/// Mantiene toda la información necesaria para la sesión en modo libre:
/// el mazo seleccionado, las cartas resueltas, el progreso, cartas
/// guardadas, y estado de pausa/finalización.
class LibreActivaState {
  /// Mazo seleccionado para la sesión libre.
  final Mazo? mazo;

  /// Entidad de sesión creada al iniciar el mazo.
  final Sesion? sesion;

  /// Lista completa de cartas del mazo resueltas desde las cajas.
  final List<Carta> cartas;

  /// Índice de la carta actual en la lista [cartas].
  final int currentIndex;

  /// Indica si la sesión está en pausa.
  final bool isPaused;

  /// Indica si la sesión fue completada.
  final bool isCompleted;

  /// IDs de cartas que el usuario ha guardado.
  final Set<String> savedCardIds;

  /// Segundos restantes para el timer de la carta actual.
  final int? remainingSeconds;

  /// Indica si hay una operación asíncrona en curso.
  final bool isLoading;

  /// Mensaje de error si ocurrió una falla.
  final String? error;

  const LibreActivaState({
    this.mazo,
    this.sesion,
    this.cartas = const [],
    this.currentIndex = 0,
    this.isPaused = false,
    this.isCompleted = false,
    this.savedCardIds = const {},
    this.remainingSeconds,
    this.isLoading = false,
    this.error,
  });

  LibreActivaState copyWith({
    Mazo? mazo,
    Sesion? sesion,
    List<Carta>? cartas,
    int? currentIndex,
    bool? isPaused,
    bool? isCompleted,
    Set<String>? savedCardIds,
    int? remainingSeconds,
    bool? isLoading,
    String? error,
  }) {
    return LibreActivaState(
      mazo: mazo ?? this.mazo,
      sesion: sesion ?? this.sesion,
      cartas: cartas ?? this.cartas,
      currentIndex: currentIndex ?? this.currentIndex,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      savedCardIds: savedCardIds ?? this.savedCardIds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Carta actual basada en [currentIndex].
  Carta get currentCarta => cartas[currentIndex];

  /// Cantidad total de cartas en el mazo.
  int get totalCartas => cartas.length;

  /// Progreso como fracción (0.0 a 1.0).
  double get progreso => totalCartas > 0 ? (currentIndex + 1) / totalCartas : 0;

  /// Indica si estamos en la primera carta.
  bool get isFirstCard => currentIndex == 0;

  /// Indica si estamos en la última carta.
  bool get isLastCard => currentIndex >= totalCartas - 1;

  /// Indica si se puede retroceder (no es la primera carta).
  bool get canGoBack => !isFirstCard;

  /// Indica si se puede saltar a la siguiente carta.
  bool get canSkipAhead => !isLastCard;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibreActivaState &&
        other.mazo == mazo &&
        other.sesion == sesion &&
        _listEquals(other.cartas, cartas) &&
        other.currentIndex == currentIndex &&
        other.isPaused == isPaused &&
        other.isCompleted == isCompleted &&
        other.savedCardIds.length == savedCardIds.length &&
        other.savedCardIds.containsAll(savedCardIds) &&
        other.remainingSeconds == remainingSeconds &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      mazo,
      sesion,
      Object.hashAll(cartas),
      currentIndex,
      isPaused,
      isCompleted,
      Object.hashAll(savedCardIds),
      remainingSeconds,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'LibreActivaState('
        'mazo: $mazo, '
        'sesion: $sesion, '
        'cartas: ${cartas.length} cartas, '
        'currentIndex: $currentIndex, '
        'isPaused: $isPaused, '
        'isCompleted: $isCompleted, '
        'savedCardIds: $savedCardIds, '
        'remainingSeconds: $remainingSeconds, '
        'isLoading: $isLoading, '
        'error: $error)';
  }

  bool _listEquals(List<Carta> a, List<Carta> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
