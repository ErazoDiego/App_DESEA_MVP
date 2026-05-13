import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/domain/entities/sesion.dart';
import 'package:desea_mvp/domain/repositories/carta_repository.dart';
import 'package:desea_mvp/domain/repositories/sesion_repository.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/carta_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_state.dart';
import 'dart:io';

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class FakeCartaRepository implements CartaRepository {
  final List<Carta> _cartas;

  FakeCartaRepository(this._cartas);

  @override
  Future<List<Carta>> getCartas() async => _cartas;

  @override
  Future<Carta?> getCartaById(String id) async {
    try {
      return _cartas.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

class FakeSesionRepository implements SesionRepository {
  Sesion? ultimaSesionCreada;
  Sesion? ultimaSesionActualizada;

  @override
  Future<Sesion> crearSesion(Sesion sesion) async {
    ultimaSesionCreada = sesion;
    return sesion;
  }

  @override
  Future<void> actualizarSesion(Sesion sesion) async {
    ultimaSesionActualizada = sesion;
  }

  @override
  Future<Sesion?> getSesionActiva() async => ultimaSesionCreada;
}

class _ErrorCartaRepository implements CartaRepository {
  @override
  Future<List<Carta>> getCartas() async =>
      throw Exception('Fallo simulado en getCartas');

  @override
  Future<Carta?> getCartaById(String id) async =>
      throw Exception('Fallo simulado');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late Box<CartaGuardadaModel> testGuardadasBox;
  late ProviderContainer container;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('sesion_providers_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    testGuardadasBox = await Hive.openBox<CartaGuardadaModel>('test_guardadas');

    // Clear any leftover data from previous test
    await testGuardadasBox.clear();

    container = ProviderContainer(
      overrides: [
        cartaRepositoryProvider.overrideWithValue(
          FakeCartaRepository(_buildTestCartas()),
        ),
        sesionRepositoryProvider.overrideWithValue(
          FakeSesionRepository(),
        ),
        guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testGuardadasBox.close();
  });

  group('SesionActivaNotifier', () {
    group('iniciarSesion()', () {
      test('sets isLoading true then false, creates session and picks 20 cards',
          () async {
        final notifier = container.read(sesionActivaProvider.notifier);

        // Initial state
        expect(container.read(sesionActivaProvider).isLoading, false);

        await notifier.iniciarSesion();

        final state = container.read(sesionActivaProvider);
        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(state.sesion, isNotNull);
        expect(state.cartas.length, 20);
        expect(state.currentIndex, 0);
        expect(state.isCompleted, false);
        expect(state.cartas.first.id, startsWith('suave_'));
      });

      test('creates sesion with correct cartasIds matching selected cartas',
          () async {
        final notifier = container.read(sesionActivaProvider.notifier);

        await notifier.iniciarSesion();

        final state = container.read(sesionActivaProvider);
        final cartaIds = state.cartas.map((c) => c.id).toList();
        expect(state.sesion!.cartasIds, cartaIds);
      });

      test('persists sesion via repository', () async {
        final notifier = container.read(sesionActivaProvider.notifier);

        await notifier.iniciarSesion();

        final fakeRepo =
            container.read(sesionRepositoryProvider) as FakeSesionRepository;
        expect(fakeRepo.ultimaSesionCreada, isNotNull);
        expect(fakeRepo.ultimaSesionCreada!.modo, Modo.sesion);
        expect(fakeRepo.ultimaSesionCreada!.fase, Fase.calentamiento);
        expect(fakeRepo.ultimaSesionCreada!.cartasIds.length, 20);
      });

      test(
          'pre-populates savedCardIds from cartas already in guardadas box',
          () async {
        // Pre-save ALL test cartas to the guardadas box BEFORE starting session.
        // This simulates cards that were saved in a previous session.
        final allCartas = _buildTestCartas();
        for (final carta in allCartas) {
          await testGuardadasBox.put(
            'guardada_${carta.id}_0',
            CartaGuardadaModel(
              id: 'guardada_${carta.id}_0',
              cartaId: carta.id,
              tipo: carta.tipo.name,
              texto: carta.texto,
              nivel: 'suave',
              guardadaEn: DateTime.now(),
            ),
          );
        }

        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final state = container.read(sesionActivaProvider);

        // Every selected card should be marked as saved since all were
        // pre-populated in the guardadas box.
        for (final carta in state.cartas) {
          expect(
            state.savedCardIds,
            contains(carta.id),
            reason:
                'Carta ${carta.id} was inside guardadas box but not in savedCardIds',
          );
        }
      });
    });

    group('nextCard()', () {
      test('advances currentIndex by 1 when not on last card', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        expect(container.read(sesionActivaProvider).currentIndex, 0);

        notifier.nextCard();

        expect(container.read(sesionActivaProvider).currentIndex, 1);
      });

      test('does not advance past last card (completes session instead)',
          () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final cartas = container.read(sesionActivaProvider).cartas;
        final lastIndex = cartas.length - 1;

        for (var i = 0; i < lastIndex; i++) {
          notifier.nextCard();
        }

        expect(container.read(sesionActivaProvider).currentIndex, lastIndex);

        // nextCard triggers _completarSesion which is async — flush microtasks
        notifier.nextCard();
        await Future.delayed(Duration.zero);

        final finalState = container.read(sesionActivaProvider);
        expect(finalState.isCompleted, true);
        expect(finalState.sesion!.completadaEn, isNotNull);
        expect(finalState.sesion!.fase, Fase.cierre);
      });
    });

    group('previousCard()', () {
      test('decreases currentIndex by 1 when canGoBack', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        notifier.nextCard();
        notifier.nextCard();
        expect(container.read(sesionActivaProvider).currentIndex, 2);

        notifier.previousCard();

        expect(container.read(sesionActivaProvider).currentIndex, 1);
      });

      test('does not change index at first card', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        expect(container.read(sesionActivaProvider).currentIndex, 0);

        notifier.previousCard();

        expect(container.read(sesionActivaProvider).currentIndex, 0);
      });
    });

    group('pausar()', () {
      test('toggles isPaused state', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        expect(container.read(sesionActivaProvider).isPaused, false);

        notifier.pausar();
        expect(container.read(sesionActivaProvider).isPaused, true);

        notifier.pausar();
        expect(container.read(sesionActivaProvider).isPaused, false);
      });
    });

    group('guardarCartaActual()', () {
      test('adds current carta id to savedCardIds and persists to box',
          () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final state = container.read(sesionActivaProvider);
        final currentCartaId = state.currentCarta.id;
        expect(state.savedCardIds, isNot(contains(currentCartaId)));

        await notifier.guardarCartaActual();

        final updatedState = container.read(sesionActivaProvider);
        expect(updatedState.savedCardIds, contains(currentCartaId));

        final allGuardadas = testGuardadasBox.values.toList();
        final savedGuardada = allGuardadas.firstWhere(
          (g) => g.cartaId == currentCartaId,
        );
        expect(savedGuardada.cartaId, currentCartaId);
        expect(savedGuardada.nivel, 'suave');
      });

      test('cannot navigate back to a saved card', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        // Save card 0, advance to 1, save card 1 (the "previous" card),
        // then advance to 2. Previous card (index 1) is saved → canGoBack false.
        await notifier.guardarCartaActual(); // save index 0
        notifier.nextCard();                  // now at index 1
        await notifier.guardarCartaActual(); // save index 1
        notifier.nextCard();                  // now at index 2

        expect(container.read(sesionActivaProvider).currentIndex, 2);
        expect(container.read(sesionActivaProvider).canGoBack, false);

        notifier.previousCard();
        expect(container.read(sesionActivaProvider).currentIndex, 2);
      });
    });

    group('reiniciar()', () {
      test('resets state and creates a new session', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final firstSesionId =
            container.read(sesionActivaProvider).sesion!.id;

        notifier.nextCard();
        notifier.nextCard();
        expect(container.read(sesionActivaProvider).currentIndex, 2);

        await notifier.reiniciar();

        final state = container.read(sesionActivaProvider);
        expect(state.currentIndex, 0);
        expect(state.sesion!.id, isNot(firstSesionId));
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });
    });

    group('error handling', () {
      test('nextCard is no-op when already completed', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final cartas = container.read(sesionActivaProvider).cartas;
        final lastIndex = cartas.length - 1;

        for (var i = 0; i < lastIndex; i++) {
          notifier.nextCard();
        }
        notifier.nextCard();
        await Future.delayed(Duration.zero);

        // Now session is completed
        expect(container.read(sesionActivaProvider).isCompleted, true);

        // Another nextCard should be a no-op
        notifier.nextCard();
        expect(container.read(sesionActivaProvider).currentIndex, lastIndex);
      });

      test('sets error state when cartasRepo fails', () async {
        // Create a container where the carta repo throws
        final errorContainer = ProviderContainer(
          overrides: [
            cartaRepositoryProvider.overrideWithValue(
              _ErrorCartaRepository(),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
        );

        final notifier = errorContainer.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        final state = errorContainer.read(sesionActivaProvider);
        expect(state.isLoading, false);
        expect(state.error, contains('Error al iniciar sesión'));
        expect(state.cartas, isEmpty);

        errorContainer.dispose();
      });
    });

    group('state getters', () {
      test('faseActual updates correctly as session progresses', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        expect(
          container.read(sesionActivaProvider).faseActual,
          'calentamiento',
        );

        for (var i = 0; i < 5; i++) {
          notifier.nextCard();
        }
        expect(container.read(sesionActivaProvider).faseActual, 'tension');
      });

      test('progreso updates correctly', () async {
        final notifier = container.read(sesionActivaProvider.notifier);
        await notifier.iniciarSesion();

        expect(
          container.read(sesionActivaProvider).progreso,
          closeTo(0.05, 0.001),
        );

        notifier.nextCard();
        expect(
          container.read(sesionActivaProvider).progreso,
          closeTo(0.1, 0.001),
        );
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build 21 test Carta entities with proper prefixes for filtering.
List<Carta> _buildTestCartas() {
  final cartas = <Carta>[];
  int index = 0;

  // 6 suaves
  for (var i = 0; i < 6; i++) {
    cartas.add(Carta(
      id: 'suave_$index',
      tipo: TipoCarta.verdad,
      texto: 'Suave $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  // 7 picantes
  for (var i = 0; i < 7; i++) {
    cartas.add(Carta(
      id: 'picante_$index',
      tipo: TipoCarta.reto,
      texto: 'Picante $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  // 6 intensas
  for (var i = 0; i < 6; i++) {
    cartas.add(Carta(
      id: 'intenso_$index',
      tipo: TipoCarta.deseo,
      texto: 'Intenso $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  // 2 cierre
  for (var i = 0; i < 2; i++) {
    cartas.add(Carta(
      id: 'cierre_$index',
      tipo: TipoCarta.verdad,
      texto: 'Cierre $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  return cartas;
}
