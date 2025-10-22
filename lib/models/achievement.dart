import 'package:hive/hive.dart';

part 'achievement.g.dart';

// ID'si '2' olarak kalıyor.
@HiveType(typeId: 2)
class Achievement extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String iconPath;

  @HiveField(3)
  late bool isUnlocked;

  @HiveField(4)
  late DateTime unlockedDate;
}
