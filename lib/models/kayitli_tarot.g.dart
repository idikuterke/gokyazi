// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kayitli_tarot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KayitliTarotAdapter extends TypeAdapter<KayitliTarot> {
  @override
  final int typeId = 6;

  @override
  KayitliTarot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KayitliTarot(
      tarih: fields[0] as DateTime,
      niyet: fields[1] as String,
      kartDetaylari: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      yorum: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KayitliTarot obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tarih)
      ..writeByte(1)
      ..write(obj.niyet)
      ..writeByte(2)
      ..write(obj.kartDetaylari)
      ..writeByte(3)
      ..write(obj.yorum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KayitliTarotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
