import 'package:hive_ce/hive.dart';
import '../../domain/entities/sesion.dart';

part 'sesion_model.g.dart';

@HiveType(typeId: 2)
class SesionModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String modo;
  @HiveField(2)
  final String fase;
  @HiveField(3)
  final int currentCardIndex;
  @HiveField(4)
  final List<String> cartasUsadasIds;
  @HiveField(5)
  final DateTime? iniciadaEn;
  @HiveField(6)
  final DateTime? completadaEn;
  @HiveField(7)
  final List<String>? cartasIds;

  const SesionModel({
    required this.id,
    required this.modo,
    required this.fase,
    this.currentCardIndex = 0,
    this.cartasUsadasIds = const [],
    this.cartasIds,
    this.iniciadaEn,
    this.completadaEn,
  });

  factory SesionModel.fromEntity(Sesion entity) {
    return SesionModel(
      id: entity.id,
      modo: entity.modo.name,
      fase: entity.fase.name,
      currentCardIndex: entity.currentCardIndex,
      cartasUsadasIds: List.from(entity.cartasUsadasIds),
      cartasIds: List.from(entity.cartasIds),
      iniciadaEn: entity.iniciadaEn,
      completadaEn: entity.completadaEn,
    );
  }

  Sesion toEntity() {
    return Sesion(
      id: id,
      modo: Modo.values.firstWhere((e) => e.name == modo),
      fase: Fase.values.firstWhere((e) => e.name == fase),
      currentCardIndex: currentCardIndex,
      cartasUsadasIds: List.from(cartasUsadasIds),
      cartasIds: cartasIds ?? [],
      iniciadaEn: iniciadaEn,
      completadaEn: completadaEn,
    );
  }

  @override
  String toString() {
    return 'SesionModel(id: $id, modo: $modo, fase: $fase, '
        'currentCardIndex: $currentCardIndex, '
        'cartasUsadasIds: $cartasUsadasIds, '
        'cartasIds: $cartasIds, '
        'iniciadaEn: $iniciadaEn, completadaEn: $completadaEn)';
  }
}
