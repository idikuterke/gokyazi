// lib/services/takvim_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/hayvan_model.dart';

class TakvimService {
  static List<Hayvan>? _hayvanlarList;
  static Map<String, ElementMeta>? _elementsMeta;
  static Map<String, YinYangMeta>? _yinYangMeta;

  // Veritabanını yeni JSON dosyasından yükler
  static Future<void> _loadNewDatabase() async {
    if (_hayvanlarList != null) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/animals_12_v2.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse elements_meta
      final Map<String, dynamic> elementsJson = jsonData['elements_meta'] ?? {};
      _elementsMeta = elementsJson.map((key, val) => MapEntry(key, ElementMeta.fromJson(val)));

      // Parse yin_yang_meta
      final Map<String, dynamic> yinYangJson = jsonData['yin_yang_meta'] ?? {};
      _yinYangMeta = yinYangJson.map((key, val) => MapEntry(key, YinYangMeta.fromJson(val)));

      // Parse hayvanlar
      final List<dynamic> hayvanlarList = jsonData['hayvanlar'] ?? [];
      _hayvanlarList = hayvanlarList.map((item) => Hayvan.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Takvim veritabanı yüklenemedi: $e');
    }
  }

  // Tüm hayvanları döndürür
  static Future<List<Hayvan>> getHayvanlar() async {
    await _loadNewDatabase();
    return _hayvanlarList ?? [];
  }

  // Belirli bir yıl için hayvan index'ini hesaplar
  static int getAnimalIndexForYear(int year) {
    final index = (year - 1984) % 12;
    return index < 0 ? 12 + index : index;
  }

  // Belirli bir yıl için hayvan nesnesini döndürür
  static Future<Hayvan?> getHayvanForYear(int year) async {
    final list = await getHayvanlar();
    final index = getAnimalIndexForYear(year);
    if (index >= 0 && index < list.length) {
      return list[index];
    }
    return null;
  }

  // ID'ye göre hayvan nesnesini döndürür
  static Future<Hayvan?> getHayvanById(String id) async {
    final list = await getHayvanlar();
    try {
      return list.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  // Element ismi hesaplama (dogumYili % 10)
  static String getElementNameForYear(int year) {
    final digit = year % 10;
    if (digit == 0 || digit == 1) return 'Metal';
    if (digit == 2 || digit == 3) return 'Su';
    if (digit == 4 || digit == 5) return 'Ağaç';
    if (digit == 6 || digit == 7) return 'Ateş';
    return 'Toprak';
  }

  // Element meta verisini getirir
  static Future<ElementMeta?> getElementMeta(String name) async {
    await _loadNewDatabase();
    return _elementsMeta?[name];
  }

  // Yin/Yang durumu hesaplama (çiftYıl=Yang · tekYıl=Yin)
  static String getYinYangNameForYear(int year) {
    return year % 2 == 0 ? 'Yang' : 'Yin';
  }

  // Yin/Yang meta verisini getirir
  static Future<YinYangMeta?> getYinYangMeta(String name) async {
    await _loadNewDatabase();
    return _yinYangMeta?[name];
  }

  // Belirli bir yıl için astrologi verilerini derler
  static Future<YearAstrology?> getYearAstrology(int year) async {
    final hayvan = await getHayvanForYear(year);
    if (hayvan == null) return null;

    final elementName = getElementNameForYear(year);
    final elementMeta = await getElementMeta(elementName);

    final yinYangName = getYinYangNameForYear(year);
    final yinYangMeta = await getYinYangMeta(yinYangName);

    if (elementMeta == null || yinYangMeta == null) return null;

    return YearAstrology(
      hayvan: hayvan,
      dogumYili: year,
      element: elementName,
      elementMeta: elementMeta,
      yinYang: yinYangName,
      yinYangMeta: yinYangMeta,
    );
  }

  // Astrolojik Yıl Hesaplama (Yılbaşı 21 Mart / Nevruz kabul edilir)
  static int getEffectiveAstrologyYear(DateTime date) {
    if (date.month < 3 || (date.month == 3 && date.day < 21)) {
      return date.year - 1;
    }
    return date.year;
  }

  // Belirli bir tarih için hayvan nesnesini döndürür
  static Future<Hayvan?> getHayvanForDate(DateTime date) async {
    final effectiveYear = getEffectiveAstrologyYear(date);
    return getHayvanForYear(effectiveYear);
  }

  // Belirli bir tarih için astrologi verilerini derler
  static Future<YearAstrology?> getYearAstrologyForDate(DateTime date) async {
    final effectiveYear = getEffectiveAstrologyYear(date);
    return getYearAstrology(effectiveYear);
  }

  // Yeni ID'leri eski görsel isimlerine eşleştirir
  static String getImagePathForId(String id) {
    switch (id) {
      case 'sicgan': return 'assets/images/sican.webp';
      case 'okuz': return 'assets/images/ud.webp';
      case 'bars': return 'assets/images/bars.webp';
      case 'tavsan': return 'assets/images/tavsan.webp';
      case 'ejderha': return 'assets/images/luu.webp';
      case 'yilan': return 'assets/images/yilan.webp';
      case 'at': return 'assets/images/at.webp';
      case 'koyun': return 'assets/images/koyun.webp';
      case 'maymun': return 'assets/images/bicin.webp';
      case 'horoz': return 'assets/images/takagu.webp';
      case 'kopek': return 'assets/images/it.webp';
      case 'domuz': return 'assets/images/tonguz.webp';
      default: return 'assets/images/bars.webp';
    }
  }

  static String getAnimalEmoji(String id) {
    switch (id) {
      case 'sicgan': return '🐭';
      case 'okuz': return '🐂';
      case 'bars': return '🐅';
      case 'tavsan': return '🐰';
      case 'ejderha': return '🐉';
      case 'yilan': return '🐍';
      case 'at': return '🐴';
      case 'koyun': return '🐑';
      case 'maymun': return '🐵';
      case 'horoz': return '🐔';
      case 'kopek': return '🐕';
      case 'domuz': return '🐷';
      default: return '🐾';
    }
  }

  static String getAnimalNameTr(String id) {
    switch (id) {
      case 'sicgan': return 'Sıçan';
      case 'okuz': return 'Sığır';
      case 'bars': return 'Pars';
      case 'tavsan': return 'Tavşan';
      case 'ejderha': return 'Ejderha';
      case 'yilan': return 'Yılan';
      case 'at': return 'At';
      case 'koyun': return 'Koyun';
      case 'maymun': return 'Maymun';
      case 'horoz': return 'Tavuk';
      case 'kopek': return 'Köpek';
      case 'domuz': return 'Domuz';
      default: return id;
    }
  }

  // Müçel Yaşı Hesaplama
  static Map<String, String> getMucelDurumu(int dogumYili) {
    final int anlikYil = DateTime.now().year;
    final int yas = anlikYil - dogumYili;

    if (yas < 13) {
      return {
        "ad": "Çocukluk Müçesi Öncesi",
        "aciklama": "Hayatın başlangıcında, keşif ve öğrenme evresindesiniz."
      };
    }

    int mucelYasi = ((yas - 1) ~/ 12) * 12 + 13;

    switch (mucelYasi) {
      case 13:
        return {
          "ad": "Gençlik Müçesi (13 Yaş)",
          "aciklama":
              "Bu, ilk kritik eşiktir. Birey olarak kendinizi bulma ve ergenlik dönemi sınavlarıyla yüzleşme evresindesiniz."
        };
      case 25:
        return {
          "ad": "Yiğitlik Müçesi (25 Yaş)",
          "aciklama":
              "Hayatınızın ikinci kritik eşiği. Toplumdaki yerinizi sağlamlaştırma, kariyer ve aile kurma gibi konularda önemli kararlar arifesindesiniz."
        };
      case 37:
        return {
          "ad": "Bilgelik Müçesi (37 Yaş)",
          "aciklama":
              "Hayatınızın üçüncü kritik eşiği. Cesaret ve bilgeliğinizin sınandığı bir evredesiniz. Altay inançlarına göre bu yaş, önemli bir dönüm noktasıdır."
        };
      case 49:
        return {
          "ad": "Aksakallı Müçesi (49 Yaş)",
          "aciklama":
              "Dördüncü kritik eşik. Toplumsal liderlik, tecrübelerinizi aktarma ve manevi derinleşme dönemindesiniz."
        };
      case 61:
        return {
          "ad": "Ulu Bilgelik Müçesi (61 Yaş)",
          "aciklama":
              "Beşinci kritik eşik. Hayatın muhasebesinin yapıldığı, bilgelik ve dinginliğin arandığı bir evre."
        };
      default:
        return {
          "ad": "İleri Yaş Müçesi",
          "aciklama":
              "Hayat tecrübelerinizle çevrenize ışık tuttuğunuz, bilgelik dolu bir dönemdesiniz."
        };
    }
  }
}
