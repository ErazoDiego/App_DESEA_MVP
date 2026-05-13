import 'package:hive_ce/hive.dart';
import '../../domain/entities/mazo.dart';

part 'mazo_model.g.dart';

@HiveType(typeId: 1)
class MazoModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nombre;
  @HiveField(2)
  final String nivel;
  @HiveField(3)
  final List<String> cartaIds;

  const MazoModel({
    required this.id,
    required this.nombre,
    required this.nivel,
    this.cartaIds = const [],
  });

  factory MazoModel.fromEntity(Mazo entity) {
    return MazoModel(
      id: entity.id,
      nombre: entity.nombre,
      nivel: entity.nivel.name,
      cartaIds: List.from(entity.cartaIds),
    );
  }

  Mazo toEntity() {
    return Mazo(
      id: id,
      nombre: nombre,
      nivel: Nivel.values.firstWhere((e) => e.name == nivel),
      cartaIds: List.from(cartaIds),
    );
  }

  @override
  String toString() {
    return 'MazoModel(id: $id, nombre: $nombre, nivel: $nivel, '
        'cartaIds: $cartaIds)';
  }
}
