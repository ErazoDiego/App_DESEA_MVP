import 'package:hive_ce/hive.dart';

import '../../domain/entities/mazo.dart';
import '../../domain/repositories/mazo_repository.dart';
import '../models/mazo_model.dart';

/// Implementación concreta de [MazoRepository] respaldada por un [Box] de Hive.
class MazoRepositoryImpl implements MazoRepository {
  final Box<MazoModel> _box;

  /// Crea una instancia del repositorio con el [box] de Hive proporcionado.
  MazoRepositoryImpl(this._box);

  @override
  Future<List<Mazo>> getMazos() async {
    final models = _box.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Mazo?> getMazoById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> crearMazo(Mazo mazo) async {
    final model = MazoModel.fromEntity(mazo);
    await _box.put(mazo.id, model);
  }

  @override
  Future<void> actualizarMazo(Mazo mazo) async {
    final model = MazoModel.fromEntity(mazo);
    await _box.put(mazo.id, model);
  }

  @override
  Future<void> eliminarMazo(String id) async {
    await _box.delete(id);
  }
}
