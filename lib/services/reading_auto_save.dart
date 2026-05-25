import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kayitli_irk_bitig.dart';
import '../models/kayitli_tarot.dart';
import '../models/kullanici_model.dart';
import 'kehanet_service.dart';

class ReadingSaveException implements Exception {
  ReadingSaveException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Fal sonrası otomatik kayıt: Hive geçmişi + Supabase kehanet + sayaçlar.
class ReadingAutoSave {
  static const int ucretsizKayitLimiti = 10;

  static int getReadingCount(KullaniciModel kullanici) {
    return kullanici.kayitliIrkBitigFallari.length +
        kullanici.kayitliTarotFallari.length;
  }

  static Future<void> saveFortune({
    required KullaniciModel kullanici,
    required KehanetService kehanet,
    required String type,
    required String sonuc,
    required String interpretation,
    String? soru,
    required bool isPremium,
    KayitliTarot? localTarot,
    KayitliIrkBitig? localIrkBitig,
    bool useLocalDailyQuota = true,
  }) async {
    final limitAsildi = !isPremium && getReadingCount(kullanici) >= ucretsizKayitLimiti;

    if (!limitAsildi) {
      if (localTarot != null) {
        await kullanici.kayitliTarotFaliEkle(localTarot);
      }
      if (localIrkBitig != null) {
        await kullanici.kayitliIrkBitigFaliEkle(localIrkBitig);
      }
    } else {
      debugPrint('ReadingAutoSave: Ücretsiz plan limitine ulaşıldı, sadece buluta kaydedilecek.');
    }

    // Generic fallback local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final localHistoryStr = prefs.getStringList('generic_history') ?? [];
      final newItem = json.encode({
        'tip': type,
        'soru': soru,
        'sonuc': sonuc,
        'ai_yorum': interpretation.isEmpty ? null : interpretation,
        'created_at': DateTime.now().toIso8601String(),
        'synced_to_gokyuzu': false,
        'is_local': true,
      });
      localHistoryStr.add(newItem);
      await prefs.setStringList('generic_history', localHistoryStr);
    } catch (e) {
      debugPrint('ReadingAutoSave: Generic local save error: $e');
    }

    final ok = await kehanet.kaydet(
      tip: type,
      soru: soru,
      sonuc: sonuc,
      aiYorum: interpretation.isEmpty ? null : interpretation,
    );
    if (!ok) {
      debugPrint('ReadingAutoSave: Supabase kaydı atlandı (oturum yok veya hata)');
    }

    await kullanici.falSayisiArttir();

    if (!isPremium && useLocalDailyQuota && kullanici.falHakki > 0) {
      await kullanici.falHakkiniKullan();
    }

    debugPrint('ReadingAutoSave: $type kaydedildi');
  }
}
