// services/hive_service.dart
import 'package:hive/hive.dart';
import '../models/kullanici_verisi.dart';

class HiveService {
  Future<void> initHive() async {
    Hive.registerAdapter(KullaniciVerisiAdapter());
    await Hive.openBox<KullaniciVerisi>('kullanici_verisi');
  }

  Box<KullaniciVerisi> getKullaniciBox() {
    return Hive.box<KullaniciVerisi>('kullanici_verisi');
  }

  KullaniciVerisi? getKullaniciVerisi() {
    final box = getKullaniciBox();
    return box.get('veri');
  }

  Future<void> saveKullaniciVerisi(KullaniciVerisi veri) async {
    final box = getKullaniciBox();
    await box.put('veri', veri);
  }
}
