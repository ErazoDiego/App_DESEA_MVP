// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carta_personalizada_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartaPersonalizadaModelAdapter
    extends TypeAdapter<CartaPersonalizadaModel> {
  @override
  final typeId = 5;

  @override
  CartaPersonalizadaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartaPersonalizadaModel(
      id: fields[0] as String,
      texto: fields[1] as String,
      categoria: fields[2] as String?,
      nivel: fields[3] as String,
      tiempoSegundos: (fields[4] as num?)?.toInt(),
      dirigida: fields[5] as String?,
      creadaEn: fields[6] as DateTime,
      imagenUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartaPersonalizadaModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.texto)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.nivel)
      ..writeByte(4)
      ..write(obj.tiempoSegundos)
      ..writeByte(5)
      ..write(obj.dirigida)
      ..writeByte(6)
      ..write(obj.creadaEn)
      ..writeByte(7)
      ..write(obj.imagenUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartaPersonalizadaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
