// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionCardAdapter extends TypeAdapter<CollectionCard> {
  @override
  final int typeId = 4;

  @override
  CollectionCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionCard()
      ..title = fields[0] as String
      ..description = fields[1] as String
      ..imagePath = fields[2] as String
      ..level = fields[3] as int
      ..isCollected = fields[4] as bool
      ..collectedDate = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CollectionCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.isCollected)
      ..writeByte(5)
      ..write(obj.collectedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
