// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FalAdapter extends TypeAdapter<Fal> {
  @override
  final int typeId = 8;

  @override
  Fal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fal(
      gokturkce: fields[0] as String,
      transliterasyon: fields[1] as String,
      turkce: fields[2] as String,
      yorumModern: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Fal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gokturkce)
      ..writeByte(1)
      ..write(obj.transliterasyon)
      ..writeByte(2)
      ..write(obj.turkce)
      ..writeByte(3)
      ..write(obj.yorumModern);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
