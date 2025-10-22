import 'package:hive/hive.dart';

part 'fal_model.g.dart';

@HiveType(typeId: 8) // Benzersiz yeni bir ID atandı.
class Fal {
  @HiveField(0)
  final String gokturkce;
  @HiveField(1)
  final String transliterasyon;
  @HiveField(2)
  final String turkce;
  @HiveField(3)
  final String yorumModern;

  Fal({
    required this.gokturkce,
    required this.transliterasyon,
    required this.turkce,
    required this.yorumModern,
  });

  factory Fal.fromJson(Map<String, dynamic> json) {
    return Fal(
      gokturkce: json['gokturkce'] ?? '...',
      transliterasyon: json['transliterasyon'] ?? 'Bulunamadı',
      turkce: json['turkce'] ?? 'Bulunamadı',
      yorumModern:
          json['modern-yorum'] ??
          json['yorumModern'] ??
          'Modern yorum bulunamadı.',
    );
  }
  Map<String, dynamic> toJson() => {
    'gokturkce': gokturkce,
    'transliterasyon': transliterasyon,
    'turkce': turkce,
    'modern-yorum': yorumModern,
  };
}
