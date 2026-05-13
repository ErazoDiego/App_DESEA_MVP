import 'package:hive_ce/hive.dart';
import '../../domain/entities/carta.dart';

part 'carta_model.g.dart';

@HiveType(typeId: 0)
class CartaModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String tipo;
  @HiveField(2)
  final String texto;
  @HiveField(3)
  final String dirigida;
  @HiveField(4)
  final int? tiempoSegundos;
  @HiveField(5)
  final String? imagenUrl;

  const CartaModel({
    required this.id,
    required this.tipo,
    required this.texto,
    required this.dirigida,
    this.tiempoSegundos,
    this.imagenUrl,
  });

  factory CartaModel.fromEntity(Carta entity) {
    return CartaModel(
      id: entity.id,
      tipo: entity.tipo.name,
      texto: entity.texto,
      dirigida: entity.dirigida.name,
      tiempoSegundos: entity.tiempoSegundos?.inSeconds,
      imagenUrl: entity.imagenUrl,
    );
  }

  Carta toEntity() {
    return Carta(
      id: id,
      tipo: TipoCarta.values.firstWhere((e) => e.name == tipo),
      texto: texto,
      dirigida: Dirigida.values.firstWhere((e) => e.name == dirigida),
      tiempoSegundos:
          tiempoSegundos != null ? Duration(seconds: tiempoSegundos!) : null,
      imagenUrl: imagenUrl,
    );
  }

  @override
  String toString() {
    return 'CartaModel(id: $id, tipo: $tipo, texto: $texto, '
        'dirigida: $dirigida, tiempoSegundos: $tiempoSegundos, '
        'imagenUrl: $imagenUrl)';
  }
}
