import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/domain/entities/carta_personalizada.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/widgets/card_form_widget.dart';
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

CartaPersonalizada _createPersonalizada({
  required String id,
  required String texto,
  String? categoria,
  String nivel = 'suave',
  int? tiempoSegundos,
  String? dirigida,
  DateTime? creadaEn,
}) {
  return CartaPersonalizada(
    id: id,
    texto: texto,
    categoria: categoria,
    nivel: nivel,
    tiempoSegundos:
        tiempoSegundos != null ? Duration(seconds: tiempoSegundos) : null,
    dirigida: dirigida,
    creadaEn: creadaEn ?? DateTime(2025, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('card_form_widget_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('CardFormWidget — create mode', () {
    testWidgets('5.1 shows all form fields in create mode', (tester) async {
      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: Scaffold(body: CardFormWidget())),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.libreInstruccionLabel), findsOneWidget);
      expect(find.text(AppStrings.libreCategoriaLabel), findsOneWidget);
      expect(find.text(AppStrings.libreNivelLabel), findsOneWidget);
      expect(find.text(AppStrings.libreTiempoLabel), findsOneWidget);
      expect(find.text(AppStrings.libreDirigidaLabel), findsOneWidget);
      expect(find.text(AppStrings.libreGuardarCarta), findsOneWidget);
    });

    testWidgets('5.2 validates texto is required', (tester) async {
      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: Scaffold(body: CardFormWidget())),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppStrings.libreInstruccionRequired), findsOneWidget);
    });

    testWidgets('5.3 saves new card and calls onSaved', (tester) async {
      final fakeBox = _FakePersBox();
      bool saved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CardFormWidget(
                onSaved: () => saved = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        'Hacé algo divertido',
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first.texto, 'Hacé algo divertido');
      expect(saved, true);
    });

    testWidgets('5.4 allows categoria dropdown selection', (tester) async {
      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: const MaterialApp(home: Scaffold(body: CardFormWidget())),
        ),
      );
      await tester.pump();

      // Tap the categoria dropdown
      await tester.tap(find.text(AppStrings.libreCategoriaLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Select "Reto"
      await tester.tap(find.text('Reto').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter texto and save
      await tester.enterText(
        find.byType(TextFormField).first,
        'Un reto divertido',
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first.categoria, 'reto');
    });
  });

  group('CardFormWidget — edit mode', () {
    final existingCard = _createPersonalizada(
      id: 'pers_test_1',
      texto: 'Texto existente',
      categoria: 'reto',
      nivel: 'picante',
      tiempoSegundos: 60,
      dirigida: 'Para ella',
      creadaEn: DateTime(2025, 6, 15),
    );

    testWidgets('5.5 pre-populates fields from existingCard',
        (tester) async {
      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CardFormWidget(existingCard: existingCard),
            ),
          ),
        ),
      );
      await tester.pump();

      // Texto field should contain existing texto
      expect(find.text('Texto existente'), findsOneWidget);
    });

    testWidgets('5.6 updates existing card on save', (tester) async {
      final fakeBox = _FakePersBox();
      final model = CartaPersonalizadaModel.fromEntity(existingCard);
      await fakeBox.put(existingCard.id, model);

      bool saved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CardFormWidget(
                existingCard: existingCard,
                onSaved: () => saved = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Modify the texto
      await tester.enterText(
        find.byType(TextFormField).first,
        'Texto actualizado',
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.libreGuardarCarta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first.texto, 'Texto actualizado');
      expect(fakeBox.values.first.id, 'pers_test_1');
      expect(saved, true);
    });
  });
}
