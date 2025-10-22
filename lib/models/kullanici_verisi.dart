import 'package:hive/hive.dart';
import '../models/kazanilan_rozet.dart';

part 'kullanici_verisi.g.dart';

// ID'si '0' olarak kalıyor. Bu bizim başlangıç noktamız.
@HiveType(typeId: 0)
class KullaniciVerisi {
  @HiveField(0)
  int kaderPuani;

  @HiveField(1)
  int seviye;

  @HiveField(2)
  int experience;

  @HiveField(3)
  List<KazanilanRozet> rozetler;

  @HiveField(4)
  int loginStreak;

  @HiveField(5)
  DateTime tarih;

  KullaniciVerisi({
    required this.kaderPuani,
    required this.seviye,
    required this.experience,
    required this.rozetler,
    required this.loginStreak,
    required this.tarih,
  });
}

Future<void> deleteKullaniciVerisiBox() async {
  await Hive.deleteBoxFromDisk('kullaniciVerisi');
}
