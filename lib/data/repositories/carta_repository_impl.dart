import 'package:hive_ce/hive.dart';

import '../../domain/entities/carta.dart';
import '../../domain/repositories/carta_repository.dart';
import '../models/carta_model.dart';

/// Implementación concreta de [CartaRepository] respaldada por un [Box] de Hive.
class CartaRepositoryImpl implements CartaRepository {
  final Box<CartaModel> _box;

  /// Crea una instancia del repositorio con el [box] de Hive proporcionado.
  CartaRepositoryImpl(this._box);

  @override
  Future<List<Carta>> getCartas() async {
    final models = _box.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Carta?> getCartaById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }
}
