import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';
import 'package:desea_mvp/domain/repositories/mazo_repository.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/mazo_providers.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/screens/game/libre_screen.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/card_preview_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/category_selector_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/level_selector_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/time_selector_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/texto_field_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/cta_button_widget.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// In-memory FakeBox — no disk I/O, instant close, no cleanup hangs.
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
  Future<Iterable<int>> addAll(Iterable<CartaPersonalizadaModel> values) async {
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
// Fake MazoRepository
// ---------------------------------------------------------------------------

class FakeMazoRepository implements MazoRepository {
  final List<Mazo> _mazos;

  FakeMazoRepository(this._mazos);

  @override
  Future<List<Mazo>> getMazos() async => _mazos;

  @override
  Future<Mazo?> getMazoById(String id) async {
    try {
      return _mazos.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> crearMazo(Mazo mazo) async {
    _mazos.add(mazo);
  }

  @override
  Future<void> actualizarMazo(Mazo mazo) async {
    final index = _mazos.indexWhere((m) => m.id == mazo.id);
    if (index >= 0) {
      _mazos[index] = mazo;
    }
  }

  @override
  Future<void> eliminarMazo(String id) async {
    _mazos.removeWhere((m) => m.id == id);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Mazo> _buildTestMazos() {
  return [
    Mazo(
      id: 'mazo_1',
      nombre: 'Rompehielos',
      nivel: Nivel.suave,
      cartaIds: ['carta_1', 'carta_2', 'carta_3'],
    ),
    Mazo(
      id: 'mazo_2',
      nombre: 'Aventura',
      nivel: Nivel.intenso,
      cartaIds: ['carta_4', 'carta_5'],
    ),
  ];
}

/// Tall screen so CardFormWidget fields + CTA fit without scrolling.
Future<void> _setTallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('libre_screen_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LibreScreen — Deck List View', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows mazo list when data loads', (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Rompehielos'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);
    });

    testWidgets('shows card count for each mazo', (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('3 cartas'), findsOneWidget);
      expect(find.text('2 cartas'), findsOneWidget);
    });

    testWidgets('shows level badge for each mazo', (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('SUAVE'), findsOneWidget);
      expect(find.text('INTENSO'), findsOneWidget);
    });
  });

  group('LibreScreen — Expandable FAB', () {
    testWidgets('expandable FAB exists and options are tappable',
        (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('fab_expandable_main')), findsOneWidget);
      expect(find.text(AppStrings.libreCrearMazo), findsNothing);
      expect(find.text(AppStrings.libreCrearCartaPers), findsNothing);

      await tester.tap(find.byKey(const Key('fab_expandable_main')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text(AppStrings.libreCrearMazo), findsOneWidget);
      expect(find.text(AppStrings.libreCrearCartaPers), findsOneWidget);
    });

    testWidgets(
        'tapping Crear mazo navigates to card builder', (tester) async {
      final mazos = <Mazo>[];
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('fab_expandable_main')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text(AppStrings.libreCrearMazo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
    });

    testWidgets(
        'tapping Crear carta navigates to create card form',
        (tester) async {
      final mazos = <Mazo>[];
      final fakeRepo = FakeMazoRepository(mazos);
      final testPersBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
            personalizadasBoxProvider2.overrideWithValue(testPersBox),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('fab_expandable_main')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text(AppStrings.libreCrearCartaPers));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Gaming form has the gaming sub-widgets
      expect(find.text(AppStrings.libreInstruccionLabel), findsOneWidget);
      expect(find.byType(CardPreviewWidget), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
    });
  });

  group('LibreScreen — Card Builder View', () {
    testWidgets('shows filter tabs and deck name field', (tester) async {
      final mazos = _buildTestMazos();
      final fakeRepo = FakeMazoRepository(mazos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('fab_expandable_main')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text(AppStrings.libreCrearMazo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Originales'), findsOneWidget);
      expect(find.text('Guardadas'), findsOneWidget);
      expect(find.text('Creadas'), findsOneWidget);
      expect(find.textContaining('Añadir'), findsOneWidget);
    });
  });

  group('LibreScreen — Create Card Form View (CardFormWidget)', () {
    Future<void> _expandFabAndTapCrearCarta(
      WidgetTester tester,
    ) async {
      await tester.tap(find.byKey(const Key('fab_expandable_main')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(AppStrings.libreCrearCartaPers));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('shows gaming sub-widgets via CardFormWidget',
        (tester) async {
      await _setTallScreen(tester);

      final mazos = <Mazo>[];
      final fakeRepo = FakeMazoRepository(mazos);
      final testPersBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
            personalizadasBoxProvider2.overrideWithValue(testPersBox),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await _expandFabAndTapCrearCarta(tester);

      // Gaming form sub-widgets
      expect(find.text(AppStrings.libreInstruccionLabel), findsOneWidget);
      expect(find.text(AppStrings.libreDirigidaLabel), findsOneWidget);
      expect(find.byType(CardPreviewWidget), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.byType(LevelSelector), findsOneWidget);
      expect(find.byType(TimeSelector), findsOneWidget);
    });

    testWidgets('validates required fields on save', (tester) async {
      await _setTallScreen(tester);

      final mazos = <Mazo>[];
      final fakeRepo = FakeMazoRepository(mazos);
      final testPersBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
            personalizadasBoxProvider2.overrideWithValue(testPersBox),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await _expandFabAndTapCrearCarta(tester);

      // Tap save button (ensure visible first)
      await tester.ensureVisible(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(AppStrings.libreInstruccionRequired),
        findsOneWidget,
      );
    });

    testWidgets('saves card and persists to box', (tester) async {
      await _setTallScreen(tester);

      final mazos = <Mazo>[];
      final fakeRepo = FakeMazoRepository(mazos);
      final testPersBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mazoRepositoryProvider.overrideWithValue(fakeRepo),
            personalizadasBoxProvider2.overrideWithValue(testPersBox),
          ],
          child: const MaterialApp(home: LibreScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await _expandFabAndTapCrearCarta(tester);

      // Enter texto
      final textFields = find.byType(TextFormField);
      await tester.ensureVisible(textFields.first);
      await tester.pump();
      await tester.enterText(textFields.first, 'Hacé algo divertido');
      await tester.pump();

      // Tap save
      await tester.ensureVisible(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(AppStrings.libreCartaCreada), findsOneWidget);
      expect(testPersBox.values.length, 1);
      expect(testPersBox.values.first.texto, 'Hacé algo divertido');
    });
  });
}
