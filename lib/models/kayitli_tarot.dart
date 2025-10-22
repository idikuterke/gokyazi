import 'package:hive/hive.dart';

part 'kayitli_tarot.g.dart';

@HiveType(typeId: 6)
class KayitliTarot extends HiveObject {
  @HiveField(0)
  final DateTime tarih;

  @HiveField(1)
  final String niyet;

  @HiveField(2)
  final List<Map<String, dynamic>> kartDetaylari;

  @HiveField(3)
  final String yorum;

  KayitliTarot({
    required this.tarih,
    required this.niyet,
    required this.kartDetaylari,
    required this.yorum,
  });
}
