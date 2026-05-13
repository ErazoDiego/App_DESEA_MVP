// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carta_guardada_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartaGuardadaModelAdapter extends TypeAdapter<CartaGuardadaModel> {
  @override
  final typeId = 4;

  @override
  CartaGuardadaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartaGuardadaModel(
      id: fields[0] as String,
      cartaId: fields[1] as String,
      tipo: fields[2] as String,
      texto: fields[3] as String,
      nivel: fields[4] as String,
      guardadaEn: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CartaGuardadaModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cartaId)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.texto)
      ..writeByte(4)
      ..write(obj.nivel)
      ..writeByte(5)
      ..write(obj.guardadaEn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartaGuardadaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
