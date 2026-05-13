import 'package:hive_ce/hive.dart';

import '../../domain/entities/perfil.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../models/perfil_model.dart';

/// Implementación concreta de [PerfilRepository] respaldada por un [Box] de Hive.
class PerfilRepositoryImpl implements PerfilRepository {
  final Box<PerfilModel> _box;

  /// Crea una instancia del repositorio con el [box] de Hive proporcionado.
  PerfilRepositoryImpl(this._box);

  @override
  Future<Perfil> getPerfil() async {
    final models = _box.values.toList();
    if (models.isEmpty) {
      throw Exception('No profile found');
    }
    return models.first.toEntity();
  }

  @override
  Future<void> guardarPerfil(Perfil perfil) async {
    final model = PerfilModel.fromEntity(perfil);
    await _box.put(perfil.id, model);
  }

  @override
  Future<bool> hasCompletadoOnboarding() async {
    final models = _box.values.toList();
    if (models.isEmpty) return false;
    return models.first.onboardingCompletado;
  }
}
