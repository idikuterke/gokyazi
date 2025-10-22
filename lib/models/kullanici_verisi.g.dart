// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kullanici_verisi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KullaniciVerisiAdapter extends TypeAdapter<KullaniciVerisi> {
  @override
  final int typeId = 0;

  @override
  KullaniciVerisi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KullaniciVerisi(
      kaderPuani: fields[0] as int,
      seviye: fields[1] as int,
      experience: fields[2] as int,
      rozetler: (fields[3] as List).cast<KazanilanRozet>(),
      loginStreak: fields[4] as int,
      tarih: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KullaniciVerisi obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.kaderPuani)
      ..writeByte(1)
      ..write(obj.seviye)
      ..writeByte(2)
      ..write(obj.experience)
      ..writeByte(3)
      ..write(obj.rozetler)
      ..writeByte(4)
      ..write(obj.loginStreak)
      ..writeByte(5)
      ..write(obj.tarih);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KullaniciVerisiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
