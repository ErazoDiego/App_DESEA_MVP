// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SesionModelAdapter extends TypeAdapter<SesionModel> {
  @override
  final typeId = 2;

  @override
  SesionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SesionModel(
      id: fields[0] as String,
      modo: fields[1] as String,
      fase: fields[2] as String,
      currentCardIndex: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      cartasUsadasIds: fields[4] == null
          ? const []
          : (fields[4] as List).cast<String>(),
      cartasIds: (fields[7] as List?)?.cast<String>(),
      iniciadaEn: fields[5] as DateTime?,
      completadaEn: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SesionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.modo)
      ..writeByte(2)
      ..write(obj.fase)
      ..writeByte(3)
      ..write(obj.currentCardIndex)
      ..writeByte(4)
      ..write(obj.cartasUsadasIds)
      ..writeByte(5)
      ..write(obj.iniciadaEn)
      ..writeByte(6)
      ..write(obj.completadaEn)
      ..writeByte(7)
      ..write(obj.cartasIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
