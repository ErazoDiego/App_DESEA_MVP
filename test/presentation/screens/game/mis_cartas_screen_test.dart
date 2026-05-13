import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/screens/game/mis_cartas_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// In-memory FakeBox for CartaPersonalizadaModel — no disk I/O.
// ---------------------------------------------------------------------------

class _FakePersBox extends Box<CartaPersonalizadaModel> {
  final _map = <String, CartaPersonalizadaModel>{};

  @override
  String get name => 'test_pers_fake';

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
  Iterable<CartaPersonalizadaModel> get values => _map.values;

  @override
  Iterable<CartaPersonalizadaModel> valuesBetween({
    dynamic startKey,
    dynamic endKey,
  }) =>
      _map.values;

  @override
  CartaPersonalizadaModel? get(dynamic key,
          {CartaPersonalizadaModel? defaultValue}) =>
      _map[key] ?? defaultValue;

  @override
  CartaPersonalizadaModel? getAt(int index) =>
      index < _map.length ? _map.values.elementAt(index) : null;

  @override
  Map<dynamic, CartaPersonalizadaModel> toMap() => Map.of(_map);

  @override
  Future<void> put(dynamic key, CartaPersonalizadaModel value) async {
    _map[key.toString()] = value;
  }

  @override
  Future<void> putAt(int index, CartaPersonalizadaModel value) async {
    final key = _map.keys.elementAt(index);
    _map[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, CartaPersonalizadaModel> entries) async {
    _map.addAll(entries.cast<String, CartaPersonalizadaModel>());
  }

  @override
  Future<int> add(CartaPersonalizadaModel value) async {
    final key = 'fake_${_map.length}';
    _map[key] = value;
    return _map.length - 1;
  }

  @override
  Future<Iterable<int>> addAll(
      Iterable<CartaPersonalizadaModel> values) async {
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

CartaPersonalizadaModel _createPersonalizada({
  required String id,
  required String texto,
  String? categoria,
  String nivel = 'suave',
  int? tiempoSegundos,
  String? dirigida,
}) {
  return CartaPersonalizadaModel(
    id: id,
    texto: texto,
    categoria: categoria,
    nivel: nivel,
    tiempoSegundos: tiempoSegundos,
    dirigida: dirigida,
    creadaEn: DateTime(2025, 1, 1, 0, 0, 0, 0, 0),
  );
}

List<CartaPersonalizadaModel> _buildTestPersonalizadas() {
  return [
    _createPersonalizada(
      id: 'p1',
      texto: '¿Cuál es tu fantasía secreta?',
      categoria: 'verdad',
      nivel: 'suave',
    ),
    _createPersonalizada(
      id: 'p2',
      texto: 'Bailá pegados por 5 minutos',
      categoria: 'reto',
      nivel: 'picante',
      tiempoSegundos: 300,
    ),
    _createPersonalizada(
      id: 'p3',
      texto: 'Describí tu lugar favorito',
      categoria: 'verdad',
      nivel: 'intenso',
    ),
    _createPersonalizada(
      id: 'p4',
      texto: 'Elegí la próxima canción',
      categoria: 'deseo',
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
    tempDir = Directory.systemTemp.createTempSync('mis_cartas_screen_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('MisCartasScreen — empty state', () {
    testWidgets('6.1 shows empty message when no personal cards',
        (tester) async {
      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.misCartasEmpty), findsOneWidget);
    });
  });

  group('MisCartasScreen — card rendering', () {
    testWidgets('6.2 shows personal cards with texto, categoria, nivel badge',
        (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // All four card textos visible
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsOneWidget);
      expect(find.text('Bailá pegados por 5 minutos'), findsOneWidget);
      expect(find.text('Describí tu lugar favorito'), findsOneWidget);
      expect(find.text('Elegí la próxima canción'), findsOneWidget);

      // Categoria labels visible (uppercase style)
      expect(find.text('VERDAD'), findsWidgets);
      expect(find.text('RETO'), findsOneWidget);
      expect(find.text('DESEO'), findsOneWidget);

      // Level badges visible
      expect(find.text('Suave'), findsWidgets);
      expect(find.text('Picante'), findsOneWidget);
      expect(find.text('Intenso'), findsOneWidget);
    });
  });

  group('MisCartasScreen — filter by categoria', () {
    testWidgets('6.3a filter shows only Verdad cards', (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "Verdad" chip
      await tester.tap(find.text('Verdad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Only Verdad cards visible
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsOneWidget);
      expect(find.text('Describí tu lugar favorito'), findsOneWidget);
      expect(find.text('Bailá pegados por 5 minutos'), findsNothing);
      expect(find.text('Elegí la próxima canción'), findsNothing);
    });

    testWidgets('6.3b filter shows only Reto cards', (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Reto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 5 minutos'), findsOneWidget);
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsNothing);
      expect(find.text('Describí tu lugar favorito'), findsNothing);
      expect(find.text('Elegí la próxima canción'), findsNothing);
    });

    testWidgets('6.3c Todas shows all cards after filter', (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Filter to Verdad first
      await tester.tap(find.text('Verdad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 5 minutos'), findsNothing);

      // Tap Todas to reset filter
      await tester.tap(find.text(AppStrings.savedCardsFilterAll));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // All cards visible again
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsOneWidget);
      expect(find.text('Bailá pegados por 5 minutos'), findsOneWidget);
      expect(find.text('Describí tu lugar favorito'), findsOneWidget);
      expect(find.text('Elegí la próxima canción'), findsOneWidget);
    });
  });

  group('MisCartasScreen — delete', () {
    testWidgets('6.4a shows confirm dialog and deletes on confirm',
        (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the delete icon
      expect(find.byIcon(Icons.delete), findsNWidgets(4));
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm dialog shows
      expect(find.text(AppStrings.misCartasDeleteTitle), findsOneWidget);
      expect(find.text(AppStrings.misCartasDeleteConfirm), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text(AppStrings.misCartasDeleteConfirm));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Card removed from box and screen
      expect(fakeBox.length, 3);
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsNothing);
      expect(find.text('Bailá pegados por 5 minutos'), findsOneWidget);
    });

    testWidgets('6.4b cancels delete when cancel is tapped', (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // All cards still present
      expect(fakeBox.length, 4);
      expect(find.text('¿Cuál es tu fantasía secreta?'), findsOneWidget);
    });

    testWidgets('6.5 deletes during active filter', (tester) async {
      final fakeBox = _FakePersBox();
      for (final c in _buildTestPersonalizadas()) {
        await fakeBox.put(c.id, c);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider.overrideWithValue(AsyncValue.data(fakeBox)),
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: MisCartasScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Filter by Reto
      await tester.tap(find.text('Reto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bailá pegados por 5 minutos'), findsOneWidget);
      expect(fakeBox.length, 4);

      // Delete the only visible Reto card
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text(AppStrings.misCartasDeleteConfirm));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Card deleted from box
      expect(fakeBox.length, 3);

      // No Reto cards left — should show no match message
      expect(find.text(AppStrings.savedCardsNoMatch), findsOneWidget);
    });
  });
}
