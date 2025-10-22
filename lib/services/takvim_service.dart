// lib/services/takvim_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/hayvan_model.dart';

class TakvimService {
  // Tüm hayvan verilerini içeren statik bir harita (cache mekanizması)
  static Map<String, Hayvan>? _hayvanVeritabani;

  // Veritabanını yükler veya önbellekten döndürür
  static Future<Map<String, Hayvan>> _loadDatabase() async {
    if (_hayvanVeritabani != null) {
      return _hayvanVeritabani!;
    }

    final String jsonString =
        await rootBundle.loadString('assets/data/takvim_veritabani.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final Map<String, Hayvan> veritabani = {};
    jsonData.forEach((key, value) {
      veritabani[key] = Hayvan.fromJson(key, value);
    });

    _hayvanVeritabani = veritabani;
    return _hayvanVeritabani!;
  }

  // Belirli bir yıl için hayvan ID'sini hesaplar
  static String getAnimalIdForYear(int year) {
    const animals = [
      'sican',
      'ud',
      'bars',
      'tavsan',
      'luu',
      'yilan',
      'at',
      'koyun',
      'bicin',
      'takagu',
      'it',
      'tonguz'
    ];
    const startYear = 4;
    final index = (year - startYear) % 12;
    return animals[index < 0 ? 12 + index : index];
  }

  // Belirli bir yıl için tam Hayvan nesnesini döndürür
  static Future<Hayvan?> getHayvanForYear(int year) async {
    final veritabani = await _loadDatabase();
    final hayvanId = getAnimalIdForYear(year);
    return veritabani[hayvanId];
  }

  // ID'ye göre Hayvan nesnesini döndürür
  static Future<Hayvan?> getHayvanById(String id) async {
    final veritabani = await _loadDatabase();
    return veritabani[id];
  }

  // Yeni fonksiyon: Müçel Yaşı Hesaplama
  static Map<String, String> getMucelDurumu(int dogumYili) {
    final int anlikYil = DateTime.now().year;
    final int yas = anlikYil - dogumYili;

    // Müçel yaşları: 12'ye bölündüğünde 1 kalanını veren yaşlardır.
    // 13 (12*1+1), 25 (12*2+1), 37 (12*3+1), 49 (12*4+1), 61 (12*5+1)...
    if (yas < 13) {
      return {
        "ad": "Çocukluk Müçesi Öncesi",
        "aciklama": "Hayatın başlangıcında, keşif ve öğrenme evresindesiniz."
      };
    }

    // Yaşın hangi müçel döngüsüne en yakın olduğunu bul
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
