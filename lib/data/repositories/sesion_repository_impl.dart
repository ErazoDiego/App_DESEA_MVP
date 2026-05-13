import 'package:hive_ce/hive.dart';

import '../../domain/entities/sesion.dart';
import '../../domain/repositories/sesion_repository.dart';
import '../models/sesion_model.dart';

/// Implementación concreta de [SesionRepository] respaldada por un [Box] de Hive.
class SesionRepositoryImpl implements SesionRepository {
  final Box<SesionModel> _box;

  /// Crea una instancia del repositorio con el [box] de Hive proporcionado.
  SesionRepositoryImpl(this._box);

  @override
  Future<Sesion> crearSesion(Sesion sesion) async {
    final model = SesionModel.fromEntity(sesion);
    await _box.put(sesion.id, model);
    return sesion;
  }

  @override
  Future<void> actualizarSesion(Sesion sesion) async {
    final model = SesionModel.fromEntity(sesion);
    await _box.put(sesion.id, model);
  }

  @override
  Future<Sesion?> getSesionActiva() async {
    final models = _box.values.toList();
    if (models.isEmpty) return null;
    // Return the most recently created session
    return models.last.toEntity();
  }
}
