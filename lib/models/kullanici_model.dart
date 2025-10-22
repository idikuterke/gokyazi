import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'kazanilan_rozet.dart';
import 'hayvan_model.dart';
import 'favori_fal.dart';
import 'kayitli_tarot.dart';
import 'kayitli_irk_bitig.dart';

class KullaniciModel with ChangeNotifier {
  // --- Kullanıcı Verileri ---
  int _kaderPuani = 0;
  int _baktigiFalSayisi = 0;
  int _experience = 0;
  int _seviye = 1;
  int _falHakki = 2;
  String _sonUcretsizFalTarihi = DateTime.now().toIso8601String().substring(
    0,
    10,
  );
  List<KazanilanRozet> _kazanilanRozetler = [];
  List<KayitliTarot> _kayitliTarotFallari = [];
  List<KayitliIrkBitig> _kayitliIrkBitigFallari = [];
  Hayvan? _kullaniciHayvan;
  int? _dogumYili;
  int _loginStreak = 0;
  bool _seviyeAtladi = false;

  // --- Seviye ve Unvan Sistemi ---
  static const List<String> _unvanListesi = [
    'Yeni Kaşif',
    'Acemi Kam',
    'Göklerin Gözcüsü',
    'Bilge Börü',
    'Ulu Ata',
  ];

  late Box _kullaniciBox;

  // --- Getter'lar ---
  int get kaderPuani => _kaderPuani;
  int get baktigiFalSayisi => _baktigiFalSayisi;
  int get experience => _experience;
  int get seviye => _seviye;
  int get falHakki => _falHakki;
  List<KazanilanRozet> get kazanilanRozetler => _kazanilanRozetler;
  List<KayitliTarot> get kayitliTarotFallari => _kayitliTarotFallari;
  List<KayitliIrkBitig> get kayitliIrkBitigFallari => _kayitliIrkBitigFallari;
  Hayvan? get kullaniciHayvan => _kullaniciHayvan;
  int? get dogumYili => _dogumYili;
  int get loginStreak => _loginStreak;
  String get unvan =>
      _unvanListesi[(_seviye - 1).clamp(0, _unvanListesi.length - 1)];
  int get sonrakiSeviyeExperience => seviye * 100;
  bool get seviyeAtladi => _seviyeAtladi;

  Future<String?> getApiKey() async {
    return dotenv.env['GEMINI_API_KEY'];
  }

  Future<void> loadData() async {
    // HATA DÜZELTME: Uyumsuz veri formatı sorununu çözmek için
    // Hive kutusunun adı değiştirilerek yeni ve temiz bir kutu oluşturulması sağlandı.
    _kullaniciBox = await Hive.openBox('kullanici_kutusu_v3');

    _kaderPuani = _kullaniciBox.get('kaderPuani', defaultValue: 0);
    _baktigiFalSayisi = _kullaniciBox.get('baktigiFalSayisi', defaultValue: 0);
    _experience = _kullaniciBox.get('experience', defaultValue: 0);
    _seviye = _kullaniciBox.get('seviye', defaultValue: 1);
    _sonUcretsizFalTarihi = _kullaniciBox.get(
      'sonUcretsizFalTarihi',
      defaultValue: DateTime.now().toIso8601String().substring(0, 10),
    );
    _falHakki = _kullaniciBox.get('falHakki', defaultValue: 2);
    _kullaniciHayvan = _kullaniciBox.get('kullaniciHayvan');
    _dogumYili = _kullaniciBox.get('dogumYili');
    _loginStreak = _kullaniciBox.get('loginStreak', defaultValue: 0);

    _kazanilanRozetler = List<KazanilanRozet>.from(
      _kullaniciBox.get('kazanilanRozetler', defaultValue: []),
    );
    _kayitliTarotFallari = List<KayitliTarot>.from(
      _kullaniciBox.get('kayitliTarotFallari', defaultValue: []),
    );
    _kayitliIrkBitigFallari = List<KayitliIrkBitig>.from(
      _kullaniciBox.get('kayitliIrkBitigFallari', defaultValue: []),
    );

    _gunlukHaklariYenile();
    notifyListeners();
  }

  void _gunlukHaklariYenile() {
    final bugun = DateTime.now().toIso8601String().substring(0, 10);
    if (bugun != _sonUcretsizFalTarihi) {
      _falHakki = 2;
      _sonUcretsizFalTarihi = bugun;
      _kullaniciBox.put('falHakki', _falHakki);
      _kullaniciBox.put('sonUcretsizFalTarihi', _sonUcretsizFalTarihi);
      notifyListeners();
    }
  }

  Future<void> falHakkiniKullan() async {
    if (_falHakki > 0) {
      _falHakki--;
      await _kullaniciBox.put('falHakki', _falHakki);
      notifyListeners();
    }
  }

  Future<void> addFalHakki() async {
    _falHakki++;
    await _kullaniciBox.put('falHakki', _falHakki);
    notifyListeners();
  }

  Future<void> falSayisiArttir() async {
    _baktigiFalSayisi++;
    await _kullaniciBox.put('baktigiFalSayisi', _baktigiFalSayisi);
    notifyListeners();
  }

  Future<void> addExperience(int puan) async {
    _experience += puan;
    bool seviyeAtladiBuIslemde = false;
    while (_experience >= sonrakiSeviyeExperience) {
      _seviye++;
      seviyeAtladiBuIslemde = true;
    }
    if (seviyeAtladiBuIslemde) {
      _seviyeAtladi = true;
    }
    await _kullaniciBox.put('experience', _experience);
    await _kullaniciBox.put('seviye', _seviye);
    notifyListeners();
  }

  void seviyeAtladiGosterildi() {
    _seviyeAtladi = false;
  }

  Future<void> kayitliTarotFaliEkle(KayitliTarot tarotFali) async {
    _kayitliTarotFallari.add(tarotFali);
    await _kullaniciBox.put('kayitliTarotFallari', _kayitliTarotFallari);
    notifyListeners();
  }

  Future<void> kayitliIrkBitigFaliEkle(KayitliIrkBitig irkBitigFali) async {
    _kayitliIrkBitigFallari.add(irkBitigFali);
    await _kullaniciBox.put('kayitliIrkBitigFallari', _kayitliIrkBitigFallari);
    notifyListeners();
  }
}
