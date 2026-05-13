// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerfilModelAdapter extends TypeAdapter<PerfilModel> {
  @override
  final typeId = 3;

  @override
  PerfilModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerfilModel(
      id: fields[0] as String,
      edad: (fields[1] as num).toInt(),
      onboardingCompletado: fields[2] == null ? false : fields[2] as bool,
      settings: fields[3] == null
          ? const {}
          : (fields[3] as Map).cast<String, dynamic>(),
      creadoEn: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PerfilModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.edad)
      ..writeByte(2)
      ..write(obj.onboardingCompletado)
      ..writeByte(3)
      ..write(obj.settings)
      ..writeByte(4)
      ..write(obj.creadoEn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerfilModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
