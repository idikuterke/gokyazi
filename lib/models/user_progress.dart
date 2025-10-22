import 'package:hive/hive.dart';

part 'user_progress.g.dart';

// DÜZELTME: typeId '0' -> '1' olarak değiştirildi.
@HiveType(typeId: 1)
class UserProgress {
  @HiveField(0)
  int totalPoints;

  @HiveField(1)
  Map<String, int> categoryPoints;

  @HiveField(2)
  List<String> unlockedCards;

  @HiveField(3)
  DateTime lastDailyReward;

  @HiveField(4)
  int loginStreak;

  UserProgress({
    this.totalPoints = 0,
    Map<String, int>? categoryPoints,
    List<String>? unlockedCards,
    DateTime? lastDailyReward,
    this.loginStreak = 0,
  })  : categoryPoints = categoryPoints ?? {},
        unlockedCards = unlockedCards ?? [],
        lastDailyReward = lastDailyReward ?? DateTime(2000);
}
