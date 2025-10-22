// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 1;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      totalPoints: fields[0] as int,
      categoryPoints: (fields[1] as Map?)?.cast<String, int>(),
      unlockedCards: (fields[2] as List?)?.cast<String>(),
      lastDailyReward: fields[3] as DateTime?,
      loginStreak: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalPoints)
      ..writeByte(1)
      ..write(obj.categoryPoints)
      ..writeByte(2)
      ..write(obj.unlockedCards)
      ..writeByte(3)
      ..write(obj.lastDailyReward)
      ..writeByte(4)
      ..write(obj.loginStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
