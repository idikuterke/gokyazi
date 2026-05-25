import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kullanici_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_screen_scaffold.dart';

final _supabase = Supabase.instance.client;

class FallarGecmisiEkrani extends StatefulWidget {
  const FallarGecmisiEkrani({super.key});

  @override
  State<FallarGecmisiEkrani> createState() => _FallarGecmisiEkraniState();
}

class _FallarGecmisiEkraniState extends State<FallarGecmisiEkrani> {
  List<Map<String, dynamic>> _kehanetler = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kehanetleriYukle();
  }

  Future<void> _kehanetleriYukle() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final List<Map<String, dynamic>> combined = [];

      // 1. Get from Supabase if logged in
      if (userId != null) {
        try {
          final response = await _supabase
              .from('kehanet_history')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          combined.addAll(List<Map<String, dynamic>>.from(response));
        } catch (e) {
          debugPrint('Supabase history fetch failed: $e');
        }
      }

      // 2. Get from SharedPreferences (Generic fallback)
      try {
        final prefs = await SharedPreferences.getInstance();
        final localHistoryStr = prefs.getStringList('generic_history') ?? [];
        for (var str in localHistoryStr) {
          combined.add(Map<String, dynamic>.from(json.decode(str)));
        }
      } catch (e) {
        debugPrint('SharedPreferences history fetch failed: $e');
      }

      // 3. Get from Hive (Local Tarot & Irk Bitig)
      if (mounted) {
        final kullanici = context.read<KullaniciModel>();
        
        for (var fal in kullanici.kayitliIrkBitigFallari) {
          combined.add({
            'tip': 'irk_bitig',
            'soru': fal.soru,
            'sonuc': 'Göktürkçe: ${fal.fal.gokturkce}\nTürkçe: ${fal.fal.turkce}\nYorum: ${fal.fal.yorumModern}',
            'ai_yorum': fal.geminiYorumu,
            'created_at': fal.tarih.toIso8601String(),
            'synced_to_gokyuzu': false,
            'is_local': true,
          });
        }
        
        for (var tarot in kullanici.kayitliTarotFallari) {
          final icerik = tarot.kartDetaylari.map((k) {
            final ad = k['ad'] ?? 'Kart';
            final tersMi = k['tersMi'] ?? false;
            return '$ad (${tersMi ? "Ters" : "Düz"})';
          }).join(', ');
          
          combined.add({
            'tip': 'tarot',
            'soru': tarot.niyet,
            'sonuc': icerik,
            'ai_yorum': tarot.yorum,
            'created_at': tarot.tarih.toIso8601String(),
            'synced_to_gokyuzu': false,
            'is_local': true,
          });
        }
      }

      // 4. De-duplicate by created_at prefix and type
      final Map<String, Map<String, dynamic>> uniqueMap = {};
      for (var item in combined) {
        final dateStr = item['created_at'].toString();
        // Use up to minute for deduplication (16 chars: 2026-05-25T13:39)
        final prefix = dateStr.length >= 16 ? dateStr.substring(0, 16) : dateStr;
        final key = '${item['tip']}_$prefix';
        uniqueMap[key] = item;
      }

      final uniqueList = uniqueMap.values.toList();
      uniqueList.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'].toString()) ?? DateTime.now();
        final dateB = DateTime.tryParse(b['created_at'].toString()) ?? DateTime.now();
        return dateB.compareTo(dateA); // descending
      });

      if (mounted) {
        setState(() {
          _kehanetler = uniqueList;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _yukleniyor = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kehanetler yüklenirken bir hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GokScreenScaffold(
      titleGokturk: '𐰚𐰇𐰼𐰤',
      titleLatin: 'KEHANETLER',
      subtitle: 'Bulut ve Yerel günlüğünüz',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
      scrollable: false,
      body: _yukleniyor
          ? Center(child: CircularProgressIndicator(color: AppColors.amber500))
          : _kehanetler.isEmpty
              ? Center(
                  child: GokCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories, size: 64, color: AppColors.fgDisabled),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          'Henüz kehanet bulunmuyor',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.fgSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _kehanetleriYukle,
                  color: AppColors.amber500,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                    itemCount: _kehanetler.length,
                    itemBuilder: (context, index) {
                      return _buildKehanetCard(_kehanetler[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildKehanetCard(Map<String, dynamic> kehanet) {
    final tip = kehanet['tip'] ?? 'tarot';
    final soru = kehanet['soru'] ?? '';
    final sonuc = kehanet['sonuc'] ?? '';
    final aiYorum = kehanet['ai_yorum'];
    final createdAt = DateTime.parse(kehanet['created_at']);
    final isSynced = kehanet['synced_to_gokyuzu'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.widgetGap),
      child: GokCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
        tilePadding: const EdgeInsets.all(AppSpacing.space4),
        childrenPadding: const EdgeInsets.all(AppSpacing.space4),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Row(
          children: [
            // İkon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tip.contains('tarot') 
                    ? AppColors.deepPurpleSeed.withValues(alpha: 0.3)
                    : AppColors.amber700.withValues(alpha: 0.3),
              ),
              child: Icon(
                tip.contains('tarot') ? Icons.style : Icons.casino,
                color: tip.contains('tarot') 
                    ? AppColors.deepPurpleSeed 
                    : AppColors.amber500,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            
            // Başlık
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTipAdi(tip),
                    style: AppTypography.displaySm.copyWith(
                      color: AppColors.amber500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTarih(createdAt),
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Sync Badge
            if (isSynced)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                  vertical: AppSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyanSpecial.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 14,
                      color: AppColors.cyanSpecial,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GöKyüzü',
                      style: AppTypography.bodyXs.copyWith(
                        color: AppColors.cyanSpecial,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        children: [
          // Soru
          if (soru.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Soru / Niyet:',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.amber200,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              soru,
              style: AppTypography.bodyMd.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
          ],

          // Sonuç
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sonuç:',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.amber200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sonuc,
            style: AppTypography.bodySm,
          ),

          // AI Yorumu
          if (aiYorum != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Divider(color: AppColors.borderHairline),
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.cyanSpecial, size: 18),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  'Kam\'ın Yorumu:',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.cyanSpecial,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              aiYorum,
              style: AppTypography.bodySm,
            ),
          ],
        ],
        ),
      ),
    );
  }

  String _getTipAdi(String tip) {
    if (tip.contains('tarot')) {
      final parts = tip.split('_');
      if (parts.length > 1) {
        final spreadId = parts.sublist(1).join('_');
        switch (spreadId) {
          case 'tek_yildiz': return 'Tek Yıldız';
          case 'otag_uc_diregi': return 'Otağın Üç Direği';
          case 'tort_bulung': return 'Tört Bulung';
          case 'kopuz_telleri': return 'Kopuz Telleri';
          case 'ergenekon_cikis': return 'Ergenekon\'dan Çıkış';
          default: return 'Türk Tarotu';
        }
      }
      return 'Türk Tarotu';
    }
    return 'Irk Bitig';
  }

  String _formatTarih(DateTime tarih) {
    final now = DateTime.now();
    final diff = now.difference(tarih);
    
    if (diff.inDays == 0) {
      return 'Bugün ${tarih.hour}:${tarih.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${tarih.day}/${tarih.month}/${tarih.year}';
    }
  }
}
