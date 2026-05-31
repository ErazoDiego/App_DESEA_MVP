import '../../domain/entities/carta.dart';
import '../../domain/entities/sesion.dart';

/// Estado inmutable de la sesión activa.
///
/// Mantiene toda la información necesaria para la sesión en curso:
/// las cartas seleccionadas, el progreso, cartas guardadas, y estado
/// de pausa/finalización.
class SesionActivaState {
  /// Entidad de sesión persistida.
  final Sesion? sesion;

  /// Lista completa de cartas de la sesión (20 cartas).
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

  const SesionActivaState({
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

  SesionActivaState copyWith({
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
    return SesionActivaState(
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

  /// Cantidad total de cartas en la sesión.
  int get totalCartas => cartas.length;

  /// Progreso como fracción (0.0 a 1.0).
  double get progreso => totalCartas > 0 ? (currentIndex + 1) / totalCartas : 0;

  /// Fase narrativa basada en el índice actual:
  /// - 0-4: calentamiento
  /// - 5-12: tension
  /// - 13-18: climax
  /// - 19: cierre
  String get faseActual {
    if (currentIndex < 5) return 'calentamiento';
    if (currentIndex < 13) return 'tension';
    if (currentIndex < 19) return 'climax';
    return 'cierre';
  }

  /// Nivel de intensidad basado en el índice actual:
  /// - 0-4: suave
  /// - 5-12: picante
  /// - 13+: intenso
  String get nivelActual {
    if (currentIndex < 5) return 'suave';
    if (currentIndex < 13) return 'picante';
    return 'intenso';
  }

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
    return other is SesionActivaState &&
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
    return 'SesionActivaState('
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
