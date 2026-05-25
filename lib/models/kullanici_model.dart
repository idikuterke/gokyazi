import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import 'kayitli_fal_model.dart';
import 'kayitli_irk_bitig.dart';
import 'kayitli_tarot.dart';
import 'kazanilan_rozet.dart';
import 'hayvan_model.dart';

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
  bool _isDarkTheme = true;

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
  bool get isDarkTheme => _isDarkTheme;

  String? getApiKey() {
    return dotenv.env['GEMINI_API_KEY'];
  }

  /// Optional helper to retrieve a Groq API key from environment.
  String? getGroqApiKey() {
    return dotenv.env['GROQ_API_KEY'];
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
    _isDarkTheme = _kullaniciBox.get('isDarkTheme', defaultValue: true);
    AppColors.isDarkMode = _isDarkTheme;

    _kazanilanRozetler = List<KazanilanRozet>.from(
      _kullaniciBox.get('kazanilanRozetler', defaultValue: []),
    );
    _kayitliTarotFallari = List<KayitliTarot>.from(
      _kullaniciBox.get('kayitliTarotFallari', defaultValue: []),
    );
    _kayitliIrkBitigFallari = List<KayitliIrkBitig>.from(
      _kullaniciBox.get('kayitliIrkBitigFallari', defaultValue: []),
    );

    await _migrateGecmisFallarFromSharedPreferences();

    _gunlukHaklariYenile();
    notifyListeners();
  }

  /// Eski SharedPreferences `gecmisFallar` kayıtlarını Hive listesine aktarır (tek sefer).
  Future<void> _migrateGecmisFallarFromSharedPreferences() async {
    if (_kayitliIrkBitigFallari.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('gecmisFallar');
    if (raw == null || raw.isEmpty) return;

    for (final s in raw) {
      try {
        final map = json.decode(s) as Map<String, dynamic>;
        final kf = KayitliFal.fromJson(map);
        _kayitliIrkBitigFallari.add(
          KayitliIrkBitig(
            kombinasyon: kf.kombinasyon,
            tarih: DateTime.tryParse(kf.tarih) ?? DateTime.now(),
            fal: kf.fal,
            soru: kf.soru,
            geminiYorumu: kf.geminiYorumu,
          ),
        );
      } catch (e) {
        debugPrint('Hata: $e');
      }
    }

    await prefs.remove('gecmisFallar');
    if (_kayitliIrkBitigFallari.isNotEmpty) {
      await _kullaniciBox.put(
        'kayitliIrkBitigFallari',
        _kayitliIrkBitigFallari,
      );
    }
  }

  /// Irk Bitig geçmişi — en yeni kayıt başta. Tek kaynak: Hive `kayitliIrkBitigFallari`.
  List<KayitliIrkBitig> getFalGecmisi() {
    return List<KayitliIrkBitig>.from(_kayitliIrkBitigFallari.reversed);
  }

  /// [getFalGecmisi] sırasına göre indeks (0 = en yeni).
  Future<void> irkBitigKaydiniSilByDisplayIndex(int displayIndex) async {
    final n = _kayitliIrkBitigFallari.length;
    if (displayIndex < 0 || displayIndex >= n) return;
    final storageIndex = n - 1 - displayIndex;
    _kayitliIrkBitigFallari.removeAt(storageIndex);
    await _kullaniciBox.put('kayitliIrkBitigFallari', _kayitliIrkBitigFallari);
    notifyListeners();
  }

  Future<void> irkBitigGecmisiniTemizle() async {
    _kayitliIrkBitigFallari = [];
    await _kullaniciBox.put('kayitliIrkBitigFallari', _kayitliIrkBitigFallari);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gecmisFallar');
    notifyListeners();
  }

  /// Ayarlar: Irk Bitig + Tarot Hive geçmişi ve kalan prefs anahtarı.
  Future<void> tumKayitliFallariTemizle() async {
    _kayitliIrkBitigFallari = [];
    _kayitliTarotFallari = [];
    await _kullaniciBox.put('kayitliIrkBitigFallari', _kayitliIrkBitigFallari);
    await _kullaniciBox.put('kayitliTarotFallari', _kayitliTarotFallari);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gecmisFallar');
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

  Future<void> addKaderPuani(int puan) async {
    _kaderPuani += puan;
    await _kullaniciBox.put('kaderPuani', _kaderPuani);
    notifyListeners();
  }

  void seviyeAtladiGosterildi() {
    _seviyeAtladi = false;
  }

  Future<void> setDarkTheme(bool value) async {
    _isDarkTheme = value;
    AppColors.isDarkMode = value;
    await _kullaniciBox.put('isDarkTheme', value);
    notifyListeners();
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
