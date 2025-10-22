import 'package:hive/hive.dart';

part 'favori_fal.g.dart';

@HiveType(typeId: 5)
class FavoriFal {
  @HiveField(0)
  final String falId;
  @HiveField(1)
  final DateTime tarih;
  @HiveField(2)
  final String falBasligi;
  @HiveField(3)
  final String icerik;

  FavoriFal({
    required this.falId,
    required this.tarih,
    required this.falBasligi,
    required this.icerik,
  });
}
