import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class DeepLinkService {
  // GöKyüzü Günlüğü'ne fal gönder
  static Future<void> sendToGokyuzuGunlugu({
    required BuildContext context,
    required String falTipi, // 'irk_bitig', 'tarot', 'hayvan'
    required String soru,
    required String sonuc,
    String? aiYorum,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        _showError(context, 'Giriş yapmanız gerekiyor');
        return;
      }

      // Deep link URL oluştur
      final uri = Uri(
        scheme: 'gokyuzugunlugu',
        host: 'sync',
        queryParameters: {
          'source': 'yazgi',
          'user_id': userId,
          'fal_tipi': falTipi,
          'soru': soru,
          'sonuc': sonuc,
          if (aiYorum != null) 'ai_yorum': aiYorum,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // GöKyüzü Günlüğü'nü aç
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade300),
                  const SizedBox(width: 12),
                  const Text('GöKyüzü Günlüğü açıldı!'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // GöKyüzü Günlüğü yüklü değil
        if (context.mounted) {
          _showInstallDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Deep link hatası: $e');
      if (context.mounted) {
        _showError(context, 'Bağlantı hatası: $e');
      }
    }
  }

  // Hata mesajı
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // Yükleme dialog'u
  static void _showInstallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1530),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.amber.shade400, size: 28),
            const SizedBox(width: 12),
            Text(
              'GöKyüzü Günlüğü',
              style: TextStyle(color: Colors.amber.shade300, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GöKyüzü Günlüğü yüklü değil.',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              'Kehanetlerinizi günlüğünüze kaydetmek için GöKyüzü Günlüğü uygulamasını indirin.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Play Store linkini aç
              final playStoreUrl = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.goklabs.gokyuzu_gunlugu',
              );
              
              if (await canLaunchUrl(playStoreUrl)) {
                await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
              }
              
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.download, color: Colors.black),
            label: const Text('İndir', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // GöKyüzü Günlüğü yüklü mü kontrol et
  static Future<bool> isGokyuzuInstalled() async {
    final uri = Uri(scheme: 'gokyuzugunlugu', host: 'ping');
    return await canLaunchUrl(uri);
  }

  // Senkronizasyon durumu kontrol et
  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {'synced': false, 'count': 0};

      // Supabase'den senkronize edilen falları çek
      final response = await _supabase
          .from('kehanet_history')
          .select()
          .eq('user_id', userId)
          .eq('synced_to_gokyuzu', true);

      return {
        'synced': response.isNotEmpty,
        'count': response.length,
        'lastSync': response.isNotEmpty 
            ? (response.first['created_at'] as String)
            : null,
      };
    } catch (e) {
      debugPrint('Sync status error: $e');
      return {'synced': false, 'count': 0};
    }
  }
}
