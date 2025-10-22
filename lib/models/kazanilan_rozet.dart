import 'package:hive/hive.dart';

part 'kazanilan_rozet.g.dart';

// ID'si '3' olarak kalıyor.
@HiveType(typeId: 3)
class KazanilanRozet extends HiveObject {
  @HiveField(0)
  String rozetId;

  @HiveField(1)
  DateTime kazanmaTarihi;

  KazanilanRozet({required this.rozetId, required this.kazanmaTarihi});
}
