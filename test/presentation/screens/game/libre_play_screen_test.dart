import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_model.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/presentation/screens/game/libre_play_screen.dart';
import 'package:desea_mvp/presentation/widgets/session/carta_card.dart';
import 'package:desea_mvp/presentation/widgets/session/pause_modal.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// Generic in-memory FakeBox — no disk I/O, instant operations.
// ---------------------------------------------------------------------------

class _FakeBox<T> extends Box<T> {
  final _store = <String, T>{};

  @override
  String get name => 'test_fake';
  @override
  bool get isOpen => true;
  @override
  String? get path => null;
  @override
  bool get lazy => false;

  @override
  Iterable<dynamic> get keys => _store.keys;
  @override
  int get length => _store.length;
  @override
  bool get isEmpty => _store.isEmpty;
  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  dynamic keyAt(int index) => _store.keys.elementAt(index);
  @override
  bool containsKey(dynamic key) => _store.containsKey(key);
  @override
  Iterable<T> get values => _store.values;

  @override
  Iterable<T> valuesBetween({dynamic startKey, dynamic endKey}) =>
      _store.values;

  @override
  T? get(dynamic key, {T? defaultValue}) =>
      _store[key.toString()] ?? defaultValue;

  @override
  T? getAt(int index) =>
      index < _store.length ? _store.values.elementAt(index) : null;

  @override
  Map<dynamic, T> toMap() => Map.of(_store);

  @override
  Future<void> put(dynamic key, T value) async {
    _store[key.toString()] = value;
  }

  @override
  Future<void> putAt(int index, T value) async {
    final key = _store.keys.elementAt(index);
    _store[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, T> entries) async {
    _store.addAll(entries.cast<String, T>());
  }

  @override
  Future<int> add(T value) async {
    final key = 'fake_${_store.length}';
    _store[key] = value;
    return _store.length - 1;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final indices = <int>[];
    for (final v in values) {
      indices.add(await add(v));
    }
    return indices;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = _store.keys.elementAt(index);
    _store.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final k in keys) {
      _store.remove(k);
    }
  }

  @override
  Future<void> compact() async {}

  @override
  Future<int> clear() async {
    final c = _store.length;
    _store.clear();
    return c;
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

/// A [CartaModel] box that throws on read — simulates a closed/corrupt box.
class _ThrowingCartaBox extends _FakeBox<CartaModel> {
  @override
  CartaModel? get(dynamic key, {CartaModel? defaultValue}) =>
      (throw Exception('Box is closed'));

  @override
  CartaModel? getAt(int index) => (throw Exception('Box is closed'));

  @override
  Iterable<CartaModel> get values => (throw Exception('Box is closed'));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Mazo _testMazo({
  String id = 'test_mazo',
  String nombre = 'Test Mazo',
  List<String> cartaIds = const ['carta_1', 'carta_2'],
}) {
  return Mazo(id: id, nombre: nombre, cartaIds: cartaIds);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Seed data helpers
  _FakeBox<CartaModel> seededCartaBox() {
    final box = _FakeBox<CartaModel>();
    box._store.addAll({
      'carta_1': const CartaModel(
        id: 'carta_1',
        tipo: 'verdad',
        texto: '¿Cuál es tu mayor fantasía?',
        dirigida: 'mixta',
      ),
      'carta_2': const CartaModel(
        id: 'carta_2',
        tipo: 'reto',
        texto: 'Hacé una broma',
        dirigida: 'paraEl',
      ),
      'carta_3': const CartaModel(
        id: 'carta_3',
        tipo: 'deseo',
        texto: 'Deseo con tiempo',
        dirigida: 'mixta',
        tiempoSegundos: 30,
      ),
    });
    return box;
  }

  group('LibrePlayScreen', () {
    testWidgets('shows error state when playDeck fails', (tester) async {
      // A box that throws on read causes playDeck to catch and show error
      final errorCartaBox = _ThrowingCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(errorCartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(mazo: _testMazo()),
          ),
        ),
      );
      // Trigger postFrameCallback → playDeck throws → error state
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text(AppStrings.reintentar), findsOneWidget);
    });

    testWidgets('loads deck and shows first card', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1', 'carta_2']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Flip card to reveal content
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.text('"¿Cuál es tu mayor fantasía?"'),
        findsOneWidget,
      );
    });

    testWidgets('shows CartaCard widget for current card', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Flip card to reveal badges and save button
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('VERDAD'), findsOneWidget);
      expect(find.text(AppStrings.guardar), findsOneWidget);
    });

    testWidgets('shows TimerBar when card has tiempoSegundos',
        (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_3']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Flip card to reveal content and start timer
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to next card', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1', 'carta_2']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Flip first card
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.text('"¿Cuál es tu mayor fantasía?"'),
        findsOneWidget,
      );

      await tester.tap(find.text(AppStrings.siguiente));
      await tester.pumpAndSettle();

      // New card starts face down — flip it
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('"Hacé una broma"'), findsOneWidget);
    });

    testWidgets('can go back to previous card', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1', 'carta_2']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Flip first card and go to next
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text(AppStrings.siguiente));
      await tester.pumpAndSettle();

      // Flip second card
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('"Hacé una broma"'), findsOneWidget);

      await tester.tap(find.text(AppStrings.anterior));
      await tester.pumpAndSettle();

      // Previous card starts face down again — flip it
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.text('"¿Cuál es tu mayor fantasía?"'),
        findsOneWidget,
      );
    });

    testWidgets('pause button toggles pause state', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.pausar));
      await tester.pump();

      expect(find.text(AppStrings.continuar), findsOneWidget);
    });

    testWidgets('shows PauseModal when paused (not inline overlay)',
        (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2
                .overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.pausar));
      await tester.pump();

      // This should find PauseModal — currently fails because
      // LibrePlayScreen uses an inline Container, not PauseModal
      expect(find.byType(PauseModal), findsOneWidget);
    });

    testWidgets('shows completion overlay on last card', (tester) async {
      final cartaBox = seededCartaBox();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(_FakeBox<CartaGuardadaModel>()),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1', 'carta_2']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.siguiente));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.finalizar), findsOneWidget);

      await tester.tap(find.text(AppStrings.finalizar));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.libreMazoCompletado), findsOneWidget);
      expect(find.text(AppStrings.volverInicio), findsOneWidget);
    });

    testWidgets('save button saves current card', (tester) async {
      final cartaBox = seededCartaBox();
      final guardadasBox = _FakeBox<CartaGuardadaModel>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider2.overrideWithValue(cartaBox),
            personalizadasBoxProvider2.overrideWithValue(_FakeBox<CartaPersonalizadaModel>()),
            guardadasBoxProvider2.overrideWithValue(guardadasBox),
          ],
          child: MaterialApp(
            home: LibrePlayScreen(
              mazo: _testMazo(cartaIds: ['carta_1']),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Flip card to reveal save button
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text(AppStrings.guardar));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text(AppStrings.guardada), findsOneWidget);

      expect(guardadasBox.values.length, 1);
      expect(guardadasBox.values.first.cartaId, 'carta_1');
    });
  });
}
