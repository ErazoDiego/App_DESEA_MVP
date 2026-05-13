import 'package:hive_ce/hive.dart';
import '../../domain/entities/carta_personalizada.dart';

part 'carta_personalizada_model.g.dart';

@HiveType(typeId: 5)
class CartaPersonalizadaModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String texto;
  @HiveField(2)
  final String? categoria;
  @HiveField(3)
  final String nivel;
  @HiveField(4)
  final int? tiempoSegundos;
  @HiveField(5)
  final String? dirigida;
  @HiveField(6)
  final DateTime creadaEn;
  @HiveField(7)
  final String? imagenUrl;

  const CartaPersonalizadaModel({
    required this.id,
    required this.texto,
    this.categoria,
    required this.nivel,
    this.tiempoSegundos,
    this.dirigida,
    required this.creadaEn,
    this.imagenUrl,
  });

  factory CartaPersonalizadaModel.fromEntity(CartaPersonalizada entity) {
    return CartaPersonalizadaModel(
      id: entity.id,
      texto: entity.texto,
      categoria: entity.categoria,
      nivel: entity.nivel,
      tiempoSegundos: entity.tiempoSegundos?.inSeconds,
      dirigida: entity.dirigida,
      creadaEn: entity.creadaEn,
      imagenUrl: entity.imagenUrl,
    );
  }

  CartaPersonalizada toEntity() {
    return CartaPersonalizada(
      id: id,
      texto: texto,
      categoria: categoria,
      nivel: nivel,
      tiempoSegundos:
          tiempoSegundos != null ? Duration(seconds: tiempoSegundos!) : null,
      dirigida: dirigida,
      creadaEn: creadaEn,
      imagenUrl: imagenUrl,
    );
  }

  @override
  String toString() {
    return 'CartaPersonalizadaModel(id: $id, texto: $texto, '
        'categoria: $categoria, nivel: $nivel, '
        'tiempoSegundos: $tiempoSegundos, dirigida: $dirigida, '
        'creadaEn: $creadaEn, imagenUrl: $imagenUrl)';
  }
}
