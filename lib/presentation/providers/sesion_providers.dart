import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../data/datasources/hive_datasource.dart';
import '../../data/models/carta_guardada_model.dart';
import '../../data/repositories/sesion_repository_impl.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/sesion.dart';
import '../../domain/repositories/sesion_repository.dart';
import 'carta_providers.dart';
import 'sesion_state.dart';

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final sesionRepositoryProvider = Provider<SesionRepository>((ref) {
  final box = ref.watch(sesionBoxProvider).asData?.value;
  if (box == null) throw Exception('Sesiones box not initialized');
  return SesionRepositoryImpl(box);
});

final guardadasBoxProvider2 = Provider<Box<CartaGuardadaModel>>((ref) {
  final box = ref.watch(guardadasBoxProvider).asData?.value;
  if (box == null) throw Exception('Guardadas box not ready');
  return box;
});

// ---------------------------------------------------------------------------
// SesionActivaNotifier — state machine for the active 20-card session
// ---------------------------------------------------------------------------

class SesionActivaNotifier extends Notifier<SesionActivaState> {
  @override
  SesionActivaState build() => const SesionActivaState();

  /// Inicia una nueva sesión: selecciona 20 cartas (5 suaves + 7 picantes +
  /// 6 intensas + 2 cierre), las mezcla y persiste la sesión.
  Future<void> iniciarSesion() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Wait for Hive boxes to initialize before reading repos
      await ref.read(cartaBoxProvider.future);
      await ref.read(sesionBoxProvider.future);

      final cartasRepo = ref.read(cartaRepositoryProvider);
      final sesionRepo = ref.read(sesionRepositoryProvider);

      final allCartas = await cartasRepo.getCartas();

      final suaves = _filtrarPorNivel(allCartas, 'suave');
      final picantes = _filtrarPorNivel(allCartas, 'picante');
      final intensas = _filtrarPorNivel(allCartas, 'intenso');
      final cierre = _filtrarPorNivel(allCartas, 'cierre');

      final random = Random();
      suaves.shuffle(random);
      picantes.shuffle(random);
      intensas.shuffle(random);

      final cartasSeleccionadas = <Carta>[
        ...suaves.take(5),
        ...picantes.take(7),
        ...intensas.take(6),
        ...cierre.take(2),
      ];

      final cartasIds = cartasSeleccionadas.map((c) => c.id).toList();

      final sesion = Sesion(
        id: 'sesion_${DateTime.now().millisecondsSinceEpoch}',
        modo: Modo.sesion,
        fase: Fase.calentamiento,
        currentCardIndex: 0,
        cartasUsadasIds: [cartasIds.first],
        cartasIds: cartasIds,
        iniciadaEn: DateTime.now(),
      );

      await sesionRepo.crearSesion(sesion);

      // Pre-populate savedCardIds from any cartas already saved in Hive
      // (e.g., from a previous session). This ensures the UI shows them as
      // saved from the start.
      final guardadasBox = ref.read(guardadasBoxProvider2);
      final existingGuardadasIds = guardadasBox.values
          .map((m) => m.cartaId)
          .toSet();
      final savedFromHive = cartasSeleccionadas
          .where((c) => existingGuardadasIds.contains(c.id))
          .map((c) => c.id)
          .toSet();

      state = SesionActivaState(
        sesion: sesion,
        cartas: cartasSeleccionadas,
        currentIndex: 0,
        savedCardIds: savedFromHive,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar sesión: $e',
      );
    }
  }

  /// Filtra cartas por nivel según el prefijo de su ID.
  List<Carta> _filtrarPorNivel(List<Carta> cartas, String nivel) {
    return cartas.where((c) {
      if (nivel == 'cierre') return c.id.startsWith('cierre_');
      return c.id.startsWith('${nivel}_');
    }).toList();
  }

  /// Avanza a la siguiente carta. Si es la última, completa la sesión.
  void nextCard() {
    if (state.isCompleted || state.isLastCard) {
      if (state.isLastCard) {
        _completarSesion();
      }
      return;
    }

    final newIndex = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: newIndex,
      remainingSeconds: state.cartas[newIndex].tiempoSegundos?.inSeconds,
    );
  }

  /// Retrocede a la carta anterior si es posible.
  void previousCard() {
    if (state.canGoBack) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Guarda la carta actual en la caja de guardadas y la marca como guardada.
  Future<void> guardarCartaActual() async {
    final carta = state.currentCarta;
    final box = ref.read(guardadasBoxProvider2);

    // Skip if this cartaId was already saved (prevents duplicates across
    // sessions or within the same session).
    final isDuplicate = box.values.any((m) => m.cartaId == carta.id);
    if (!isDuplicate) {
      final model = CartaGuardadaModel.fromCarta(
        carta,
        nivel: state.nivelActual,
      );
      await box.put(model.id, model);
    }

    state = state.copyWith(
      savedCardIds: {...state.savedCardIds, carta.id},
    );
  }

  /// Pausa o reanuda la sesión.
  void pausar() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Reinicia la sesión desde cero.
  Future<void> reiniciar() async {
    await iniciarSesion();
  }

  /// Resetea el estado al inicial sin sesión activa. Útil para cuando el
  /// usuario vuelve al inicio tras completar una sesión.
  void reset() {
    state = const SesionActivaState();
  }

  /// Marca la sesión como completada y persiste el cambio.
  Future<void> _completarSesion() async {
    if (state.sesion == null) return;

    final sesionRepo = ref.read(sesionRepositoryProvider);
    final updatedSesion = state.sesion!.copyWith(
      fase: Fase.cierre,
      completadaEn: DateTime.now(),
    );

    await sesionRepo.actualizarSesion(updatedSesion);

    state = state.copyWith(
      sesion: updatedSesion,
      isCompleted: true,
    );
  }
}

final sesionActivaProvider =
    NotifierProvider<SesionActivaNotifier, SesionActivaState>(
  SesionActivaNotifier.new,
);
