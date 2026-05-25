import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ErentuzService {
  /// Jüpiter döngüsünde sonraki ziyaret yılını hesaplar
  static int sonrakiDonguYili(int startYear) {
    final currentYear = DateTime.now().year;
    int nextYear = startYear;
    while (nextYear <= currentYear) {
      nextYear += 12;
    }
    return nextYear;
  }

  /// Hayvan indeksine göre Jüpiter'in son ziyaret yılını bulur.
  static int sonZiyaretYili(int hayvanIndex) {
    final currentYear = DateTime.now().year;
    // Gökyüzü Günlüğü'nden gelen formül
    int baseYear = hayvanIndex + 3;
    while (baseYear <= currentYear) {
      baseYear += 12;
    }
    return baseYear - 12;
  }

  /// Verilen yıla karşılık gelen hayvanın sıra numarasını (0-11) döndürür.
  /// GÖK YAZI formatına uyarlandı (0-11 indeks)
  static int hayvanIndex(int year) {
    int index = (year - 4) % 12;
    if (index < 0) index += 12;
    return index; // 0-11 arası
  }
  
  /// Kullanıcının doğum yılına göre son ve sonraki Jüpiter ziyaretini hesaplar
  static Map<String, int> getJupiterCycle(DateTime dogumTarihi) {
    final dogumYili = dogumTarihi.year;
    final hayvanIdx = hayvanIndex(dogumYili);
    
    final sonZiyaret = sonZiyaretYili(hayvanIdx);
    final sonrakiZiyaret = sonrakiDonguYili(dogumYili);
    
    return {
      'son_ziyaret': sonZiyaret,
      'sonraki_ziyaret': sonrakiZiyaret,
      'hayvan_index': hayvanIdx,
    };
  }

  /// JSON asset'ini yükler (opsiyonel - kullanılmayabilir)
  static Future<Map<String, dynamic>> loadData() async {
    try {
      final raw = await rootBundle.loadString('assets/data/erentuz.json');
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return {}; // JSON yoksa boş map döndür
    }
  }
}
