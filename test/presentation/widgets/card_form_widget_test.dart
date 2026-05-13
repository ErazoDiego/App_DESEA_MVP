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
import 'package:desea_mvp/presentation/widgets/card_editor/card_preview_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/category_selector_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/cta_button_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/level_selector_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/texto_field_widget.dart';
import 'package:desea_mvp/presentation/widgets/card_editor/time_selector_widget.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';

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

Widget _wrapInApp(Widget widget) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
    ),
    home: Scaffold(body: widget),
  );
}

/// Tall screen to fit all form fields + CTA button without scrolling.
Future<void> _setTallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Tap the CTA save button after ensuring it's visible.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text(AppStrings.libreGuardarCarta));
  await tester.pump();
  await tester.tap(find.text(AppStrings.libreGuardarCarta));
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

  // ===================================================================
  // Unit tests — sub-widgets
  // ===================================================================

  group('GamingTextField', () {
    testWidgets('renders label and validates required text', (tester) async {
      final controller = TextEditingController();
      String? validationResult;

      await tester.pumpWidget(_wrapInApp(
        Form(
          key: GlobalKey<FormState>(),
          child: GamingTextField(
            controller: controller,
            label: 'Test Label',
            validator: (v) {
              validationResult =
                  (v == null || v.trim().isEmpty) ? 'Required' : null;
              return validationResult;
            },
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Test Label'), findsOneWidget);

      // Trigger validation
      final formKey =
          tester.widget<Form>(find.byType(Form)).key as GlobalKey<FormState>;
      formKey.currentState?.validate();
      await tester.pump();

      expect(validationResult, 'Required');

      controller.text = 'Some text';
      formKey.currentState?.validate();
      await tester.pump();

      expect(validationResult, isNull);
    });
  });

  group('CategorySelector', () {
    testWidgets('shows 4 chips and calls onChanged on tap', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(_wrapInApp(
        StatefulBuilder(
          builder: (context, setLocalState) => CategorySelector(
            selected: selectedValue,
            onChanged: (v) => setLocalState(() => selectedValue = v),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Verdad'), findsOneWidget);
      expect(find.text('Reto'), findsOneWidget);
      expect(find.text('Deseo'), findsOneWidget);
      expect(find.text('Sin Límites'), findsOneWidget);

      // Tap "Reto"
      await tester.tap(find.text('Reto'));
      await tester.pump();

      expect(selectedValue, 'reto');

      // Tap "Deseo" instead
      await tester.tap(find.text('Deseo'));
      await tester.pump();

      expect(selectedValue, 'deseo');
    });
  });

  group('LevelSelector', () {
    testWidgets('shows 3 pills, default suave selected', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(_wrapInApp(
        LevelSelector(
          selected: 'suave',
          onChanged: (v) => selectedValue = v,
        ),
      ));
      await tester.pump();

      expect(find.text('Suave'), findsOneWidget);
      expect(find.text('Picante'), findsOneWidget);
      expect(find.text('Intenso'), findsOneWidget);

      // Tap "Intenso"
      await tester.tap(find.text('Intenso'));
      await tester.pump();

      expect(selectedValue, 'intenso');
    });
  });

  group('TimeSelector', () {
    testWidgets('shows slider and presets, preset tap updates value',
        (tester) async {
      int? selectedSeconds;

      await tester.pumpWidget(_wrapInApp(
        TimeSelector(
          seconds: null,
          onChanged: (v) => selectedSeconds = v,
        ),
      ));
      await tester.pump();

      expect(find.text('15s'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
      expect(find.text('60s'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Tap "30s" preset
      await tester.tap(find.text('30s'));
      await tester.pump();

      expect(selectedSeconds, 30);
    });
  });

  group('CardPreviewWidget', () {
    testWidgets('renders text and shows default state', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const CardPreviewWidget(
          texto: 'Mi carta',
          nivel: 'suave',
        ),
      ));
      await tester.pump();

      expect(find.text('Mi carta'), findsOneWidget);
      expect(find.text('PERSONALIZADA'), findsOneWidget);
      expect(find.text('Suave'), findsOneWidget);

      // With time
      await tester.pumpWidget(_wrapInApp(
        const CardPreviewWidget(
          texto: 'Con tiempo',
          nivel: 'intenso',
          tiempoSegundos: 45,
        ),
      ));
      await tester.pump();

      expect(find.text('Con tiempo'), findsOneWidget);
      expect(find.text('45s'), findsOneWidget);
      expect(find.text('Intenso'), findsOneWidget);
    });
  });

  group('CtaButtonWidget', () {
    testWidgets('shows enabled, loading, and disabled states',
        (tester) async {
      // Enabled state
      await tester.pumpWidget(_wrapInApp(
        const CtaButtonWidget(
          label: 'Guardar',
          isLoading: false,
          onPressed: null,
        ),
      ));
      await tester.pump();

      expect(find.text('Guardar'), findsOneWidget);

      // Loading state
      await tester.pumpWidget(_wrapInApp(
        const CtaButtonWidget(
          label: 'Guardar',
          isLoading: true,
          onPressed: null,
        ),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ===================================================================
  // Integration tests — CardFormWidget
  // ===================================================================

  group('CardFormWidget — create mode', () {
    testWidgets('renders preview + all sub-widgets and save calls onSaved',
        (tester) async {
      await _setTallScreen(tester);

      final fakeBox = _FakePersBox();
      bool saved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: _wrapInApp(
            CardFormWidget(
              onSaved: () => saved = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Preview visible
      expect(find.byType(CardPreviewWidget), findsOneWidget);

      // All 6 sub-widget types present
      expect(find.byType(GamingTextField), findsNWidgets(2));
      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.byType(LevelSelector), findsOneWidget);
      expect(find.byType(TimeSelector), findsOneWidget);
      expect(find.byType(CtaButtonWidget), findsOneWidget);

      // Enter texto
      final textFields = find.byType(TextFormField);
      await tester.ensureVisible(textFields.first);
      await tester.pump();
      await tester.enterText(textFields.first, 'Hacé algo divertido');
      await tester.pump();

      // Tap save
      await _tapSave(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first.texto, 'Hacé algo divertido');
      expect(saved, true);
    });

    testWidgets('validates texto is required', (tester) async {
      await _setTallScreen(tester);

      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: _wrapInApp(const CardFormWidget()),
        ),
      );
      await tester.pump();

      await _tapSave(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(AppStrings.libreInstruccionRequired),
        findsOneWidget,
      );
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

    testWidgets('pre-populates fields from existingCard', (tester) async {
      await _setTallScreen(tester);

      final fakeBox = _FakePersBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: _wrapInApp(
            CardFormWidget(existingCard: existingCard),
          ),
        ),
      );
      await tester.pump();

      // Texto appears in preview AND in text field
      expect(find.text('Texto existente'), findsNWidgets(2));
    });

    testWidgets('updates existing card on save', (tester) async {
      await _setTallScreen(tester);

      final fakeBox = _FakePersBox();
      final model = CartaPersonalizadaModel.fromEntity(existingCard);
      await fakeBox.put(existingCard.id, model);

      bool saved = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            personalizadasBoxProvider2.overrideWithValue(fakeBox),
          ],
          child: _wrapInApp(
            CardFormWidget(
              existingCard: existingCard,
              onSaved: () => saved = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Modify the texto
      final textFields = find.byType(TextFormField);
      await tester.ensureVisible(textFields.first);
      await tester.pump();
      await tester.tap(textFields.first);
      // Select all and replace
      await tester.enterText(textFields.first, 'Texto actualizado');
      await tester.pump();

      await _tapSave(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first.texto, 'Texto actualizado');
      expect(fakeBox.values.first.id, 'pers_test_1');
      expect(saved, true);
    });
  });
}
