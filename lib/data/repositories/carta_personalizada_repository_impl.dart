import 'package:hive_ce/hive.dart';

import '../../domain/entities/carta_personalizada.dart';
import '../../domain/repositories/carta_personalizada_repository.dart';
import '../models/carta_personalizada_model.dart';

/// Implementación concreta de [CartaPersonalizadaRepository] respaldada
/// por un [Box] de Hive.
class CartaPersonalizadaRepositoryImpl
    implements CartaPersonalizadaRepository {
  final Box<CartaPersonalizadaModel> _box;

  /// Crea una instancia del repositorio con el [box] de Hive proporcionado.
  CartaPersonalizadaRepositoryImpl(this._box);

  @override
  Future<List<CartaPersonalizada>> getAll() async {
    final models = _box.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> save(CartaPersonalizada carta) async {
    final model = CartaPersonalizadaModel.fromEntity(carta);
    await _box.put(carta.id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
