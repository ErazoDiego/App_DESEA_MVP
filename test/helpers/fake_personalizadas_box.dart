import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';

/// In-memory fake [Box] of [CartaPersonalizadaModel] for widget tests.
///
/// Avoids Hive CE initialization and disk I/O. Supports the subset of [Box]
/// operations used by [MisCartasScreen] and badge counters:
///   - [length], [values], [keys], [isEmpty], [isNotEmpty], [toMap]
///   - [get], [getAt], [keyAt], [containsKey], [valuesBetween]
///   - [put], [putAt], [putAll], [add], [addAll]
///   - [delete], [deleteAt], [deleteAll], [clear]
///   - [close], [compact], [flush], [deleteFromDisk], [watch]
class FakePersonalizadasBox extends Box<CartaPersonalizadaModel> {
  final Map<dynamic, CartaPersonalizadaModel> _store;
  final String _name;
  int _nextAutoKey;

  FakePersonalizadasBox({
    Map<dynamic, CartaPersonalizadaModel>? initial,
    String name = 'test_personalizadas',
  })  : _store = Map.from(initial ?? {}),
        _name = name,
        _nextAutoKey = (initial?.length ?? 0) + 1;

  // ── BoxBase ────────────────────────────────────────────────────────

  @override
  String get name => _name;

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
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  Future<void> put(dynamic key, CartaPersonalizadaModel value) async {
    _store[key] = value;
  }

  @override
  Future<void> putAt(int index, CartaPersonalizadaModel value) async {
    if (index >= 0 && index < _store.length) {
      _store[_store.keys.elementAt(index)] = value;
    }
  }

  @override
  Future<void> putAll(Map<dynamic, CartaPersonalizadaModel> entries) async {
    _store.addAll(entries);
  }

  @override
  Future<int> add(CartaPersonalizadaModel value) async {
    final key = _nextAutoKey++;
    _store[key] = value;
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<CartaPersonalizadaModel> values) async {
    return Future.wait(values.map((v) => add(v)));
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAt(int index) async {
    if (index >= 0 && index < _store.length) {
      _store.remove(_store.keys.elementAt(index));
    }
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
    final n = _store.length;
    _store.clear();
    return n;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  Future<void> flush() async {}

  // ── Box ────────────────────────────────────────────────────────────

  @override
  Iterable<CartaPersonalizadaModel> get values => _store.values;

  @override
  Iterable<CartaPersonalizadaModel> valuesBetween({
    dynamic startKey,
    dynamic endKey,
  }) =>
      _store.values;

  @override
  CartaPersonalizadaModel? get(dynamic key,
          {CartaPersonalizadaModel? defaultValue}) =>
      _store[key] ?? defaultValue;

  @override
  CartaPersonalizadaModel? getAt(int index) {
    if (index < 0 || index >= _store.length) return null;
    return _store.values.elementAt(index);
  }

  @override
  Map<dynamic, CartaPersonalizadaModel> toMap() => Map.from(_store);
}
