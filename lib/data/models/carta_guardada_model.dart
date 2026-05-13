import 'package:hive_ce/hive.dart';
import '../../domain/entities/carta.dart';

part 'carta_guardada_model.g.dart';

@HiveType(typeId: 4)
class CartaGuardadaModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cartaId; // ID of the original Carta

  @HiveField(2)
  final String tipo;

  @HiveField(3)
  final String texto;

  @HiveField(4)
  final String nivel; // suave/picante/intenso (context when saved)

  @HiveField(5)
  final DateTime guardadaEn;

  const CartaGuardadaModel({
    required this.id,
    required this.cartaId,
    required this.tipo,
    required this.texto,
    required this.nivel,
    required this.guardadaEn,
  });

  factory CartaGuardadaModel.fromCarta(Carta carta, {String nivel = 'suave'}) {
    return CartaGuardadaModel(
      id: 'guardada_${carta.id}_${DateTime.now().millisecondsSinceEpoch}',
      cartaId: carta.id,
      tipo: carta.tipo.name,
      texto: carta.texto,
      nivel: nivel,
      guardadaEn: DateTime.now(),
    );
  }

  Carta toCarta() {
    return Carta(
      id: cartaId,
      tipo: TipoCarta.values.firstWhere((e) => e.name == tipo),
      texto: texto,
      dirigida: Dirigida.mixta, // default for saved cards
    );
  }

  @override
  String toString() {
    return 'CartaGuardadaModel(id: $id, cartaId: $cartaId, '
        'tipo: $tipo, texto: $texto, nivel: $nivel, '
        'guardadaEn: $guardadaEn)';
  }
}
