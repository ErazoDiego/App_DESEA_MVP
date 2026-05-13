// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carta_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartaModelAdapter extends TypeAdapter<CartaModel> {
  @override
  final typeId = 0;

  @override
  CartaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartaModel(
      id: fields[0] as String,
      tipo: fields[1] as String,
      texto: fields[2] as String,
      dirigida: fields[3] as String,
      tiempoSegundos: (fields[4] as num?)?.toInt(),
      imagenUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartaModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipo)
      ..writeByte(2)
      ..write(obj.texto)
      ..writeByte(3)
      ..write(obj.dirigida)
      ..writeByte(4)
      ..write(obj.tiempoSegundos)
      ..writeByte(5)
      ..write(obj.imagenUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
