// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazanilan_rozet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KazanilanRozetAdapter extends TypeAdapter<KazanilanRozet> {
  @override
  final int typeId = 3;

  @override
  KazanilanRozet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KazanilanRozet(
      rozetId: fields[0] as String,
      kazanmaTarihi: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KazanilanRozet obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.rozetId)
      ..writeByte(1)
      ..write(obj.kazanmaTarihi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KazanilanRozetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
