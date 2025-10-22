// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favori_fal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriFalAdapter extends TypeAdapter<FavoriFal> {
  @override
  final int typeId = 5;

  @override
  FavoriFal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriFal(
      falId: fields[0] as String,
      tarih: fields[1] as DateTime,
      falBasligi: fields[2] as String,
      icerik: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriFal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.falId)
      ..writeByte(1)
      ..write(obj.tarih)
      ..writeByte(2)
      ..write(obj.falBasligi)
      ..writeByte(3)
      ..write(obj.icerik);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriFalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
