import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/presentation/screens/game/saved_cards_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// In-memory FakeBox for CartaGuardadaModel — no disk I/O.
// ---------------------------------------------------------------------------

class _FakeGuardadasBox extends Box<CartaGuardadaModel> {
  final _map = <String, CartaGuardadaModel>{};

  @override
  String get name => 'test_guardadas_fake';

  @override
  bool get isOpen => true;

  @override
  String? get path => null;

  @override
  bool get lazy => false;

  @override
  Iterable<dynamic> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  dynamic keyAt(int index) => _map.keys.elementAt(index);

  @override
  bool containsKey(dynamic key) => _map.containsKey(key);

  @override
  Iterable<CartaGuardadaModel> get values => _map.values;

  @override
  Iterable<CartaGuardadaModel> valuesBetween({
    dynamic startKey,
    dynamic endKey,
  }) =>
      _map.values;

  @override
  CartaGuardadaModel? get(dynamic key,
          {CartaGuardadaModel? defaultValue}) =>
      _map[key] ?? defaultValue;

  @override
  CartaGuardadaModel? getAt(int index) =>
      index < _map.length ? _map.values.elementAt(index) : null;

  @override
  Map<dynamic, CartaGuardadaModel> toMap() => Map.of(_map);

  @override
  Future<void> put(dynamic key, CartaGuardadaModel value) async {
    _map[key.toString()] = value;
  }

  @override
  Future<void> putAt(int index, CartaGuardadaModel value) async {
    final key = _map.keys.elementAt(index);
    _map[key] = value;
  }

  @override
  Future<void> putAll(
      Map<dynamic, CartaGuardadaModel> entries) async {
    _map.addAll(entries.cast<String, CartaGuardadaModel>());
  }

  @override
  Future<int> add(CartaGuardadaModel value) async {
    final key = 'fake_${_map.length}';
    _map[key] = value;
    return _map.length - 1;
  }

  @override
  Future<Iterable<int>> addAll(
      Iterable<CartaGuardadaModel> values) async {
    final indices = <int>[];
    for (final v in values) {
      indices.add(await add(v));
    }
    return indices;
  }

  @override
  Future<void> delete(dynamic key) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = _map.keys.elementAt(index);
    _map.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final k in keys) {
      _map.remove(k);
    }
  }

  @override
  Future<void> compact() async {}

  @override
  Future<int> clear() async {
    final count = _map.length;
    _map.clear();
    return count;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  Future<void> flush() async {}

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CartaGuardadaModel _createGuardada({
  required String id,
  required String texto,
  required String tipo,
  String nivel = 'suave',
}) {
  return CartaGuardadaModel(
    id: id,
    cartaId: 'carta_$id',
    tipo: tipo,
    texto: texto,
    nivel: nivel,
    guardadaEn: DateTime(2025, 1, 1, 0, 0, 0, 0, 0),
  );
}

List<CartaGuardadaModel> _buildTestGuardadas() {
  return [
    _createGuardada(
      id: 'g1',
      texto: '¿Cuál es tu fantasía?',
      tipo: 'verdad',
      nivel: 'suave',
    ),
    _createGuardada(
      id: 'g2',
      texto: 'Bailá pegados por 3 minutos',
      tipo: 'reto',
      nivel: 'picante',
    ),
    _createGuardada(
      id: 'g3',
      texto: 'Describí tu lugar favorito',
      tipo: 'verdad',
      nivel: 'intenso',
    ),
    _createGuardada(
      id: 'g4',
      texto: 'Elegí la próxima canción',
      tipo: 'deseo',
      nivel: 'suave',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('saved_cards_screen_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SavedCardsScreen — empty state', () {
    testWidgets('4.1 shows empty message when no saved cards', (tester) async {
      final fakeBox = _FakeGuardadasBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.savedCardsEmpty), findsOneWidget);
    });
  });

  group('SavedCardsScreen — card rendering', () {
    testWidgets('4.2 shows saved cards with texto, LevelBadge',
        (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // First 2 cards visible in grid viewport
      expect(find.text('¿Cuál es tu fantasía?'), findsOneWidget);
      expect(find.text('Bailá pegados por 3 minutos'), findsOneWidget);

      // Level badges visible (first row only)
      expect(find.text('Suave'), findsWidgets);
      expect(find.text('Picante'), findsOneWidget);
    });
  });

  group('SavedCardsScreen — filter by tipo', () {
    testWidgets('4.3a filter shows only Verdad cards', (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "Verdad" chip
      await tester.tap(find.text('Verdad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Only Verdad cards visible
      expect(find.text('¿Cuál es tu fantasía?'), findsOneWidget);
      expect(find.text('Describí tu lugar favorito'), findsOneWidget);
      expect(find.text('Bailá pegados por 3 minutos'), findsNothing);
      expect(find.text('Elegí la próxima canción'), findsNothing);
    });

    testWidgets('4.3b filter shows only Reto cards', (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Reto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 3 minutos'), findsOneWidget);
      expect(find.text('¿Cuál es tu fantasía?'), findsNothing);
      expect(find.text('Describí tu lugar favorito'), findsNothing);
      expect(find.text('Elegí la próxima canción'), findsNothing);
    });

    testWidgets('4.3c Todas shows all cards after filter',
        (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Filter to Verdad first
      await tester.tap(find.text('Verdad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 3 minutos'), findsNothing);

      // Tap Todas to reset filter
      await tester.tap(find.text(AppStrings.savedCardsFilterAll));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // First row cards visible again (grid viewport)
      expect(find.text('¿Cuál es tu fantasía?'), findsOneWidget);
      expect(find.text('Bailá pegados por 3 minutos'), findsOneWidget);
    });
  });

  group('SavedCardsScreen — delete', () {
    testWidgets('4.4a shows confirm dialog and deletes on confirm',
        (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the delete icon for the first visible card
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm dialog shows
      expect(find.text(AppStrings.savedCardsDeleteTitle), findsOneWidget);
      expect(find.text(AppStrings.savedCardsDeleteConfirm), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text(AppStrings.savedCardsDeleteConfirm));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Card removed from box and screen
      expect(fakeBox.length, 3);
      expect(find.text('¿Cuál es tu fantasía?'), findsNothing);
      expect(find.text('Bailá pegados por 3 minutos'), findsOneWidget);
    });

    testWidgets('4.4b cancels delete when cancel is tapped',
        (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // All cards still present
      expect(fakeBox.length, 4);
      expect(find.text('¿Cuál es tu fantasía?'), findsOneWidget);
    });

    testWidgets('4.5 deletes during active filter', (tester) async {
      final fakeBox = _FakeGuardadasBox();
      for (final g in _buildTestGuardadas()) {
        await fakeBox.put(g.id, g);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            guardadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: SavedCardsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Filter by Reto
      await tester.tap(find.text('Reto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 3 minutos'), findsOneWidget);
      expect(fakeBox.length, 4);

      // Delete the only visible Reto card
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text(AppStrings.savedCardsDeleteConfirm));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Card deleted from box
      expect(fakeBox.length, 3);

      // No Reto cards left — should show no match message
      expect(find.text(AppStrings.savedCardsNoMatch), findsOneWidget);
    });
  });
}
