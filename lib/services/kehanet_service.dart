import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KehanetService {
  final _supabase = Supabase.instance.client;

  Future<bool> kaydet({
    required String tip,
    String? soru,
    required String sonuc,
    String? aiYorum,
  }) async {
    debugPrint('📝 Kaydetme başladı: $tip');

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ User ID null!');
        return false;
      }

      debugPrint('👤 User ID: $userId');

      await _supabase.from('kehanet_history').insert({
        'user_id': userId,
        'tip': tip,
        'soru': soru,
        'sonuc': sonuc,
        'ai_yorum': aiYorum,
        'synced_to_gokyuzu': false,
      });

      debugPrint('✅ Kayıt başarılı: $tip');
      return true;
    } catch (e) {
      debugPrint('❌ Kayıt hatası: $e');
      return false;
    }
  }

  // Returns {'kalan': int, 'premium': bool}
  // Fail-open: returns {'kalan': 5, 'premium': false} on error so users aren't blocked.
  Future<Map<String, dynamic>> getQuotaInfo() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {'kalan': 0, 'premium': false};

      final response = await _supabase
          .from('ai_quota')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // First time — create default row
        await _supabase.from('ai_quota').insert({
          'user_id': userId,
          'haftalik_kalan': 10,
          'paket_tipi': 'free',
        });
        return {'kalan': 10, 'premium': false};
      }

      return {
        'kalan': (response['haftalik_kalan'] as int?) ?? 0,
        'premium': response['paket_tipi'] == 'premium',
      };
    } catch (e) {
      debugPrint('❌ Quota kontrol hatası: $e');
      return {'kalan': 5, 'premium': false};
    }
  }

  Future<bool> azaltQuota() async {
    debugPrint('📉 Quota azaltma başladı');

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ User ID null!');
        return false;
      }

      final info = await getQuotaInfo();
      debugPrint('📊 Mevcut quota: ${info['kalan']}, Premium: ${info['premium']}');

      if (info['premium'] == true) {
        debugPrint('💎 Premium kullanıcı — quota azaltılmadı');
        return true;
      }

      if ((info['kalan'] as int) <= 0) {
        debugPrint('❌ Quota bitti!');
        return false;
      }

      await _supabase.rpc(
        'decrement_quota',
        params: {'user_id_param': userId},
      );

      debugPrint('✅ Quota azaltıldı: ${info['kalan']} → ${(info['kalan'] as int) - 1}');
      return true;
    } catch (e) {
      debugPrint('❌ Quota azaltma hatası: $e');
      return false;
    }
  }
}
