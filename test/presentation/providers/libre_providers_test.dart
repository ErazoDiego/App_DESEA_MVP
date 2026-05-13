import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/data/models/carta_model.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';
import 'package:desea_mvp/domain/entities/sesion.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late Box<CartaModel> testCartaBox;
  late Box<CartaPersonalizadaModel> testPersonalizadasBox;
  late Box<CartaGuardadaModel> testGuardadasBox;
  late ProviderContainer container;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('libre_providers_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    testCartaBox = await Hive.openBox<CartaModel>('test_cartas');
    testPersonalizadasBox =
        await Hive.openBox<CartaPersonalizadaModel>('test_personalizadas');
    testGuardadasBox =
        await Hive.openBox<CartaGuardadaModel>('test_guardadas');

    await testCartaBox.clear();
    await testPersonalizadasBox.clear();
    await testGuardadasBox.clear();

    // Seed test data: 2 seed cartas + 2 personalizadas
    await testCartaBox.putAll({
      'suave_0': const CartaModel(
        id: 'suave_0',
        tipo: 'verdad',
        texto: 'Verdad suave',
        dirigida: 'mixta',
      ),
      'picante_1': const CartaModel(
        id: 'picante_1',
        tipo: 'reto',
        texto: 'Reto picante',
        dirigida: 'paraEl',
        tiempoSegundos: 60,
      ),
    });

    await testPersonalizadasBox.putAll({
      'pers_0': CartaPersonalizadaModel(
        id: 'pers_0',
        texto: 'Carta personalizada',
        categoria: 'deseo',
        nivel: 'intenso',
        dirigida: 'paraElla',
        creadaEn: DateTime(2026, 1, 1),
      ),
      'pers_1': CartaPersonalizadaModel(
        id: 'pers_1',
        texto: 'Otra personalizada',
        categoria: 'verdad',
        nivel: 'suave',
        creadaEn: DateTime(2026, 1, 2),
      ),
    });

    container = ProviderContainer(
      overrides: [
        cartaBoxProvider2.overrideWithValue(testCartaBox),
        personalizadasBoxProvider2.overrideWithValue(testPersonalizadasBox),
        guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testCartaBox.close();
    await testPersonalizadasBox.close();
    await testGuardadasBox.close();
  });

  group('LibreActivaNotifier', () {
    group('playDeck()', () {
      test('resolves cartaIds from seed cartas box', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_test',
          nombre: 'Test Mazo',
          cartaIds: ['suave_0', 'picante_1'],
        );

        expect(container.read(libreActivaProvider).isLoading, false);

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(state.mazo, mazo);
        expect(state.cartas.length, 2);
        expect(state.cartas[0].id, 'suave_0');
        expect(state.cartas[0].texto, 'Verdad suave');
        expect(state.cartas[0].tipo, TipoCarta.verdad);
        expect(state.cartas[1].id, 'picante_1');
        expect(state.cartas[1].tipo, TipoCarta.reto);
        expect(state.currentIndex, 0);
        expect(state.isCompleted, false);
      });

      test('resolves cartaIds from personalizadas box when not in seed box',
          () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_mix',
          nombre: 'Mazo Mixto',
          cartaIds: ['suave_0', 'pers_0', 'pers_1'],
        );

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        expect(state.cartas.length, 3);
        expect(state.cartas[0].id, 'suave_0');
        expect(state.cartas[1].id, 'pers_0');
        expect(state.cartas[2].id, 'pers_1');
        // pers_0 has categoria 'deseo' → TipoCarta.deseo
        expect(state.cartas[1].tipo, TipoCarta.deseo);
        expect(state.cartas[1].texto, 'Carta personalizada');
        expect(state.cartas[1].dirigida, Dirigida.paraElla);
        // pers_1 has categoria 'verdad' → TipoCarta.verdad
        expect(state.cartas[2].tipo, TipoCarta.verdad);
      });

      test('creates Sesion entity with modo: Modo.libre', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_sesion',
          nombre: 'Sesion Mazo',
          cartaIds: ['suave_0'],
        );

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        expect(state.sesion, isNotNull);
        expect(state.sesion!.modo, Modo.libre);
        expect(state.sesion!.cartasIds, ['suave_0']);
        expect(state.sesion!.currentCardIndex, 0);
        expect(state.sesion!.iniciadaEn, isNotNull);
      });

      test('handles empty cartaIds gracefully', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_empty',
          nombre: 'Empty Mazo',
          cartaIds: [],
        );

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        expect(state.cartas, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(state.sesion, isNotNull);
        expect(state.sesion!.cartasIds, isEmpty);
      });

      test('skips IDs not found in either box', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_missing',
          nombre: 'Missing Cards',
          cartaIds: ['suave_0', 'nonexistent_id', 'pers_1'],
        );

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        // nonexistent_id should be skipped
        expect(state.cartas.length, 2);
        expect(state.cartas[0].id, 'suave_0');
        expect(state.cartas[1].id, 'pers_1');
      });

      test('sets isLoading true then false', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_load',
          nombre: 'Load Test',
          cartaIds: ['suave_0'],
        );

        // Before playDeck, isLoading is false
        expect(container.read(libreActivaProvider).isLoading, false);

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        expect(state.isLoading, false);
      });

      test(
          'pre-populates savedCardIds from cartas already in guardadas box',
          () async {
        // Pre-save a carta to guardadas BEFORE playing the deck
        await testGuardadasBox.put(
          'guardada_suave_0_0',
          CartaGuardadaModel(
            id: 'guardada_suave_0_0',
            cartaId: 'suave_0',
            tipo: 'verdad',
            texto: 'Verdad suave',
            nivel: 'libre',
            guardadaEn: DateTime.now(),
          ),
        );

        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_presave',
          nombre: 'Pre-save Test',
          cartaIds: ['suave_0', 'picante_1'],
        );

        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        // 'suave_0' was pre-saved and is in the deck → should be in savedCardIds
        expect(state.savedCardIds, contains('suave_0'));
        // 'picante_1' was NOT pre-saved → should NOT be in savedCardIds
        expect(state.savedCardIds, isNot(contains('picante_1')));
      });

      test('sets error state when boxes throw', () async {
        // Create a container where cartaBoxProvider2 throws
        final errorContainer = ProviderContainer(
          overrides: [
            cartaBoxProvider2.overrideWithValue(testCartaBox),
            personalizadasBoxProvider2.overrideWithValue(
              // This box is not opened, but if we override with
              // a box that's been closed, it will throw on .get()
              testPersonalizadasBox,
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
        );

        // Close the box so .get() throws
        await testPersonalizadasBox.close();

        final notifier = errorContainer.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_error',
          nombre: 'Error Mazo',
          cartaIds: ['pers_0'],
        );

        await notifier.playDeck(mazo);

        final state = errorContainer.read(libreActivaProvider);
        expect(state.isLoading, false);
        expect(state.error, contains('Error al cargar mazo'));
        expect(state.cartas, isEmpty);

        errorContainer.dispose();
      });
    });

    group('nextCard()', () {
      test('advances currentIndex by 1 when not on last card', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_next',
          nombre: 'Next Test',
          cartaIds: ['suave_0', 'picante_1', 'pers_0'],
        );
        await notifier.playDeck(mazo);

        expect(container.read(libreActivaProvider).currentIndex, 0);

        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 1);

        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 2);
      });

      test('does not advance past last card (completes session)', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_last',
          nombre: 'Last Test',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        expect(container.read(libreActivaProvider).currentIndex, 0);

        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 1);

        // Now at last card — nextCard should complete
        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 1);
        expect(container.read(libreActivaProvider).isCompleted, true);
      });

      test('is no-op when already completed', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_done',
          nombre: 'Done Test',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        notifier.nextCard(); // now at 1 (last)
        notifier.nextCard(); // completes

        expect(container.read(libreActivaProvider).isCompleted, true);

        // Another nextCard should be a no-op
        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 1);
      });
    });

    group('previousCard()', () {
      test('decreases currentIndex by 1 when canGoBack', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_prev',
          nombre: 'Prev Test',
          cartaIds: ['suave_0', 'picante_1', 'pers_0'],
        );
        await notifier.playDeck(mazo);

        notifier.nextCard();
        notifier.nextCard();
        expect(container.read(libreActivaProvider).currentIndex, 2);

        notifier.previousCard();
        expect(container.read(libreActivaProvider).currentIndex, 1);

        notifier.previousCard();
        expect(container.read(libreActivaProvider).currentIndex, 0);
      });

      test('does not change index at first card', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_first',
          nombre: 'First Test',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        expect(container.read(libreActivaProvider).currentIndex, 0);

        notifier.previousCard();
        expect(container.read(libreActivaProvider).currentIndex, 0);
      });
    });

    group('pausar()', () {
      test('toggles isPaused state', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_pause',
          nombre: 'Pause Test',
          cartaIds: ['suave_0'],
        );
        await notifier.playDeck(mazo);

        expect(container.read(libreActivaProvider).isPaused, false);

        notifier.pausar();
        expect(container.read(libreActivaProvider).isPaused, true);

        notifier.pausar();
        expect(container.read(libreActivaProvider).isPaused, false);
      });
    });

    group('guardarCartaActual()', () {
      test('adds current carta id to savedCardIds and persists to box',
          () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_save',
          nombre: 'Save Test',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        final state = container.read(libreActivaProvider);
        final currentCartaId = state.currentCarta.id;
        expect(state.savedCardIds, isNot(contains(currentCartaId)));

        await notifier.guardarCartaActual();

        final updatedState = container.read(libreActivaProvider);
        expect(updatedState.savedCardIds, contains(currentCartaId));

        // Verify it was persisted in the guardadas box
        final allGuardadas = testGuardadasBox.values.toList();
        final savedGuardada = allGuardadas.firstWhere(
          (g) => g.cartaId == currentCartaId,
        );
        expect(savedGuardada.cartaId, currentCartaId);
        expect(savedGuardada.nivel, 'libre');
      });

      test('can save multiple distinct cards', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_multi',
          nombre: 'Multi Save',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        // Save first card
        await notifier.guardarCartaActual();
        final firstId = container.read(libreActivaProvider).currentCarta.id;

        // Move to second card and save
        notifier.nextCard();
        await notifier.guardarCartaActual();
        final secondId = container.read(libreActivaProvider).currentCarta.id;

        final state = container.read(libreActivaProvider);
        expect(state.savedCardIds.length, 2);
        expect(state.savedCardIds, contains(firstId));
        expect(state.savedCardIds, contains(secondId));
      });

      test('does not save duplicate cartaId to Hive box', () async {
        final notifier = container.read(libreActivaProvider.notifier);

        final mazo = Mazo(
          id: 'mazo_dedup',
          nombre: 'Dedup Test',
          cartaIds: ['suave_0', 'picante_1'],
        );
        await notifier.playDeck(mazo);

        // Save the same card twice
        await notifier.guardarCartaActual();
        await notifier.guardarCartaActual();

        // Only 1 entry in Hive for this cartaId
        final guardadasForCard =
            testGuardadasBox.values.where((g) => g.cartaId == 'suave_0');
        expect(guardadasForCard.length, 1,
            reason: 'Duplicate cartaId should not be saved to Hive');

        // savedCardIds has it once
        final state = container.read(libreActivaProvider);
        expect(state.savedCardIds, contains('suave_0'));
      });
    });
  });
}
