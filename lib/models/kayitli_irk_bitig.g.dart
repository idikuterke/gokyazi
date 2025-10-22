// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kayitli_irk_bitig.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KayitliIrkBitigAdapter extends TypeAdapter<KayitliIrkBitig> {
  @override
  final int typeId = 7;

  @override
  KayitliIrkBitig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KayitliIrkBitig(
      kombinasyon: fields[0] as String,
      tarih: fields[1] as DateTime,
      fal: fields[2] as Fal,
      soru: fields[3] as String,
      geminiYorumu: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KayitliIrkBitig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.kombinasyon)
      ..writeByte(1)
      ..write(obj.tarih)
      ..writeByte(2)
      ..write(obj.fal)
      ..writeByte(3)
      ..write(obj.soru)
      ..writeByte(4)
      ..write(obj.geminiYorumu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KayitliIrkBitigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
