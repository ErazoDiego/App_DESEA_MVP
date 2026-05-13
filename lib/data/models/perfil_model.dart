import 'package:hive_ce/hive.dart';
import '../../domain/entities/perfil.dart';

part 'perfil_model.g.dart';

@HiveType(typeId: 3)
class PerfilModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int edad;
  @HiveField(2)
  final bool onboardingCompletado;
  @HiveField(3)
  final Map<String, dynamic> settings;
  @HiveField(4)
  final DateTime creadoEn;

  const PerfilModel({
    required this.id,
    required this.edad,
    this.onboardingCompletado = false,
    this.settings = const {},
    required this.creadoEn,
  });

  factory PerfilModel.fromEntity(Perfil entity) {
    return PerfilModel(
      id: entity.id,
      edad: entity.edad,
      onboardingCompletado: entity.onboardingCompletado,
      settings: Map.from(entity.settings),
      creadoEn: entity.creadoEn,
    );
  }

  Perfil toEntity() {
    return Perfil(
      id: id,
      edad: edad,
      onboardingCompletado: onboardingCompletado,
      settings: Map.from(settings),
      creadoEn: creadoEn,
    );
  }

  @override
  String toString() {
    return 'PerfilModel(id: $id, edad: $edad, '
        'onboardingCompletado: $onboardingCompletado, '
        'settings: $settings, creadoEn: $creadoEn)';
  }
}
