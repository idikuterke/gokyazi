import 'package:hive/hive.dart';

part 'collection_card.g.dart';

// DÜZELTME: typeId '3' -> '4' olarak değiştirildi.
@HiveType(typeId: 4)
class CollectionCard extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String imagePath;

  @HiveField(3)
  late int level;

  @HiveField(4)
  late bool isCollected;

  @HiveField(5)
  late DateTime collectedDate;
}
