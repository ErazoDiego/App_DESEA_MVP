import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';

/// In-memory fake [Box] of [CartaGuardadaModel] for widget tests.
///
/// Avoids Hive CE initialization and disk I/O. Supports the subset of [Box]
/// operations used by [SavedCardsScreen] and badge counters:
///   - [length], [values], [keys], [isEmpty], [isNotEmpty], [toMap]
///   - [get], [getAt], [keyAt], [containsKey], [valuesBetween]
///   - [put], [putAt], [putAll], [add], [addAll]
///   - [delete], [deleteAt], [deleteAll], [clear]
///   - [close], [compact], [flush], [deleteFromDisk], [watch]
class FakeGuardadasBox extends Box<CartaGuardadaModel> {
  final Map<dynamic, CartaGuardadaModel> _store;
  final String _name;
  int _nextAutoKey;

  FakeGuardadasBox({
    Map<dynamic, CartaGuardadaModel>? initial,
    String name = 'test_guardadas',
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
  Future<void> put(dynamic key, CartaGuardadaModel value) async {
    _store[key] = value;
  }

  @override
  Future<void> putAt(int index, CartaGuardadaModel value) async {
    if (index >= 0 && index < _store.length) {
      _store[_store.keys.elementAt(index)] = value;
    }
  }

  @override
  Future<void> putAll(Map<dynamic, CartaGuardadaModel> entries) async {
    _store.addAll(entries);
  }

  @override
  Future<int> add(CartaGuardadaModel value) async {
    final key = _nextAutoKey++;
    _store[key] = value;
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<CartaGuardadaModel> values) async {
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
  Iterable<CartaGuardadaModel> get values => _store.values;

  @override
  Iterable<CartaGuardadaModel> valuesBetween({
    dynamic startKey,
    dynamic endKey,
  }) =>
      _store.values;

  @override
  CartaGuardadaModel? get(dynamic key, {CartaGuardadaModel? defaultValue}) {
    return _store[key] ?? defaultValue;
  }

  @override
  CartaGuardadaModel? getAt(int index) {
    if (index < 0 || index >= _store.length) return null;
    return _store.values.elementAt(index);
  }

  @override
  Map<dynamic, CartaGuardadaModel> toMap() => Map.from(_store);
}
