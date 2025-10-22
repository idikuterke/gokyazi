// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 2;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement()
      ..title = fields[0] as String
      ..description = fields[1] as String
      ..iconPath = fields[2] as String
      ..isUnlocked = fields[3] as bool
      ..unlockedDate = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.iconPath)
      ..writeByte(3)
      ..write(obj.isUnlocked)
      ..writeByte(4)
      ..write(obj.unlockedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
