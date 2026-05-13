// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mazo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MazoModelAdapter extends TypeAdapter<MazoModel> {
  @override
  final typeId = 1;

  @override
  MazoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MazoModel(
      id: fields[0] as String,
      nombre: fields[1] as String,
      nivel: fields[2] as String,
      cartaIds: fields[3] == null
          ? const []
          : (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MazoModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.nivel)
      ..writeByte(3)
      ..write(obj.cartaIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MazoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
