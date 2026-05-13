import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../data/datasources/hive_datasource.dart';
import '../../data/models/carta_guardada_model.dart';
import '../../data/models/carta_model.dart';
import '../../data/models/carta_personalizada_model.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/carta_personalizada.dart';
import '../../domain/entities/mazo.dart';
import '../../domain/entities/sesion.dart';
import 'libre_state.dart';
import 'sesion_providers.dart';

// ---------------------------------------------------------------------------
// Sync box providers
// ---------------------------------------------------------------------------

/// Proporciona acceso síncrono a la caja de cartas semilla (CartaModel).
final cartaBoxProvider2 = Provider<Box<CartaModel>>((ref) {
  final box = ref.watch(cartaBoxProvider).asData?.value;
  if (box == null) throw Exception('Cartas box not initialized');
  return box;
});

/// Proporciona acceso síncrono a la caja de cartas personalizadas.
final personalizadasBoxProvider2 = Provider<Box<CartaPersonalizadaModel>>((ref) {
  final box = ref.watch(personalizadasBoxProvider).asData?.value;
  if (box == null) throw Exception('Personalizadas box not initialized');
  return box;
});

// ---------------------------------------------------------------------------
// LibreActivaNotifier — state machine for Modo Libre sessions
// ---------------------------------------------------------------------------

class LibreActivaNotifier extends Notifier<LibreActivaState> {
  @override
  LibreActivaState build() => const LibreActivaState();

  /// Inicia una sesión en modo libre con el [mazo] proporcionado.
  ///
  /// Resuelve cada [Mazo.cartaIds] buscando primero en la caja de cartas
  /// semilla ([cartaBoxProvider2]) y luego en la caja de cartas
  /// personalizadas ([personalizadasBoxProvider2]). Las cartas no
  /// encontradas en ninguna caja se omiten.
  Future<void> playDeck(Mazo mazo) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cartaBox = ref.read(cartaBoxProvider2);
      final personalizadasBox = ref.read(personalizadasBoxProvider2);

      final cartas = <Carta>[];
      for (final id in mazo.cartaIds) {
        // Try seed cartas box first
        final cartaModel = cartaBox.get(id);
        if (cartaModel != null) {
          cartas.add(cartaModel.toEntity());
          continue;
        }

        // Try personalizadas box
        final personalizadaModel = personalizadasBox.get(id);
        if (personalizadaModel != null) {
          cartas.add(_personalizadaToCarta(personalizadaModel.toEntity()));
          continue;
        }
      }

      final sesion = Sesion(
        id: 'libre_${DateTime.now().millisecondsSinceEpoch}',
        modo: Modo.libre,
        fase: Fase.calentamiento,
        currentCardIndex: 0,
        cartasUsadasIds: cartas.isNotEmpty ? [cartas.first.id] : [],
        cartasIds: cartas.map((c) => c.id).toList(),
        iniciadaEn: DateTime.now(),
      );

      // Pre-populate savedCardIds from any cartas already saved in Hive.
      final guardadasBox = ref.read(guardadasBoxProvider2);
      final existingGuardadasIds =
          guardadasBox.values.map((m) => m.cartaId).toSet();
      final savedFromHive = cartas
          .where((c) => existingGuardadasIds.contains(c.id))
          .map((c) => c.id)
          .toSet();

      state = LibreActivaState(
        mazo: mazo,
        sesion: sesion,
        cartas: cartas,
        currentIndex: 0,
        savedCardIds: savedFromHive,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar mazo: $e',
      );
    }
  }

  /// Avanza a la siguiente carta. Si es la última, completa la sesión.
  void nextCard() {
    if (state.isCompleted || state.isLastCard) {
      if (state.isLastCard) {
        state = state.copyWith(isCompleted: true);
      }
      return;
    }

    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  /// Retrocede a la carta anterior si es posible.
  void previousCard() {
    if (state.canGoBack) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Pausa o reanuda la sesión.
  void pausar() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Guarda la carta actual en la caja de guardadas y la marca como guardada.
  ///
  /// Si la carta ya existe en la caja de guardadas (mismo [cartaId]), omite
  /// la persistencia para evitar duplicados, pero igual la marca como
  /// guardada en el estado.
  Future<void> guardarCartaActual() async {
    final carta = state.currentCarta;
    final box = ref.read(guardadasBoxProvider2);

    final isDuplicate = box.values.any((m) => m.cartaId == carta.id);
    if (!isDuplicate) {
      final model = CartaGuardadaModel.fromCarta(
        carta,
        nivel: 'libre',
      );
      await box.put(model.id, model);
    }

    state = state.copyWith(
      savedCardIds: {...state.savedCardIds, carta.id},
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Convierte una [CartaPersonalizada] a [Carta] mapeando los campos de
  /// texto a los enum values correspondientes.
  Carta _personalizadaToCarta(CartaPersonalizada personalizada) {
    return Carta(
      id: personalizada.id,
      tipo: _parseTipoCarta(personalizada.categoria),
      texto: personalizada.texto,
      dirigida: _parseDirigida(personalizada.dirigida),
      tiempoSegundos: personalizada.tiempoSegundos,
    );
  }

  /// Parsea el campo [categoria] de [CartaPersonalizada] a [TipoCarta].
  /// Por defecto retorna [TipoCarta.verdad].
  TipoCarta _parseTipoCarta(String? categoria) {
    switch (categoria) {
      case 'verdad':
        return TipoCarta.verdad;
      case 'reto':
        return TipoCarta.reto;
      case 'deseo':
        return TipoCarta.deseo;
      default:
        return TipoCarta.verdad;
    }
  }

  /// Parsea el campo [dirigida] de [CartaPersonalizada] a [Dirigida].
  /// Por defecto retorna [Dirigida.mixta].
  Dirigida _parseDirigida(String? dirigida) {
    switch (dirigida) {
      case 'mixta':
        return Dirigida.mixta;
      case 'paraEl':
        return Dirigida.paraEl;
      case 'paraElla':
        return Dirigida.paraElla;
      default:
        return Dirigida.mixta;
    }
  }
}

final libreActivaProvider =
    NotifierProvider<LibreActivaNotifier, LibreActivaState>(
  LibreActivaNotifier.new,
);
