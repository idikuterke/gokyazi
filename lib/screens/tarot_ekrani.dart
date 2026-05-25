// tarot_ekrani.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/kullanici_model.dart';
import '../models/tarot_karti.dart';
import '../models/tarot_spread.dart';
import '../models/kayitli_tarot.dart';
import '../services/ai_services_holder.dart';
import '../providers/kozmik_provider.dart';
import '../services/kehanet_service.dart';
import '../services/reading_auto_save.dart';
import '../services/tarot_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_header.dart';

enum TarotAsamasi { acilimSec, niyetGir, kartlariCek, yorumGoster }

class TarotEkrani extends StatefulWidget {
  const TarotEkrani({super.key});

  @override
  State<TarotEkrani> createState() => _TarotEkraniState();
}

class _TarotEkraniState extends State<TarotEkrani>
    with TickerProviderStateMixin {
  late Future<List<TarotKarti>> _deste;
  List<TarotKarti> _kartlar = [];
  List<TarotKarti> _secilenKartlar = [];
  Map<TarotKarti, bool> _kartlarTersMi = {};

  TarotAsamasi _asama = TarotAsamasi.acilimSec;
  List<TarotSpread> _spreadler = [];
  TarotSpread? _secilenSpread;
  String? _aiYorum;
  bool _yorumYukleniyor = false;
  late PageController _spreadPageController;
  List<TarotKarti> _gridKartlar = [];
  final Set<int> _acikKartlar = {};

  final TextEditingController _niyetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deste = _loadKartlar().then((value) {
      final shuffled = List<TarotKarti>.from(value)..shuffle();
      // 25 grid pozisyonu için döngüsel liste
      setState(() {
        _kartlar = value;
        _gridKartlar = List.generate(25, (i) => shuffled[i % shuffled.length]);
      });
      return value;
    });
    _spreadPageController = PageController(viewportFraction: 0.85);
    _loadSpreadler();
  }

  @override
  void dispose() {
    _niyetController.dispose();
    _spreadPageController.dispose();
    super.dispose();
  }

  Future<List<TarotKarti>> _loadKartlar() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/turk_tarotu.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TarotKarti.fromJson(json)).toList();
    } catch (e, st) {
      debugPrint('Tarot destesi yüklenemedi: $e\n$st');
      return [];
    }
  }

  Future<void> _loadSpreadler() async {
    try {
      final list = await TarotService.getSpreadler();
      if (!mounted) return;
      setState(() {
        _spreadler = list;
        _secilenSpread = list.isNotEmpty ? list.first : null;
      });
    } catch (e) {
      debugPrint('Açılımlar yüklenemedi: $e');
    }
  }



  void _kartTiklandi(int gridIndex, int gerekliKartSayisi) {
    if (_gridKartlar.isEmpty) return;
    final kart = _gridKartlar[gridIndex];
    
    if (!_secilenKartlar.contains(kart) && _secilenKartlar.length >= gerekliKartSayisi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bu açılım için en fazla $gerekliKartSayisi kart seçebilirsiniz.'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      if (_secilenKartlar.contains(kart)) {
        _secilenKartlar.remove(kart);
        _kartlarTersMi.remove(kart);
        _acikKartlar.remove(gridIndex);
      } else {
        _secilenKartlar.add(kart);
        _kartlarTersMi[kart] = Random().nextBool();
        _acikKartlar.add(gridIndex);
      }
    });
  }

  void _showKotaDoluDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgIndigoLift,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Haftalık Limit Doldu',
          style: TextStyle(color: AppColors.amber500),
        ),
        content: Text(
          'Bu haftaki AI yorum hakkınız doldu.\n\nPremium üyelik ile sınırsız yorum alabilirsiniz!',
          style: TextStyle(color: AppColors.fgSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tamam',
              style: TextStyle(color: AppColors.fgSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber700,
            ),
            child: const Text(
              'Premium Ol',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _yorumuAl() async {
    if (_yorumYukleniyor || _aiYorum != null) return;
    if (_secilenKartlar.isEmpty || _secilenSpread == null) return;

    setState(() => _yorumYukleniyor = true);

    final kullanici = context.read<KullaniciModel>();
    final ai = context.read<AiServicesHolder>();
    final ks = KehanetService();
    final quotaInfo = await ks.getQuotaInfo();

    try {
      if (!quotaInfo['premium'] && (quotaInfo['kalan'] as int) <= 0) {
        if (!mounted) return;
        _showKotaDoluDialog();
        setState(() => _yorumYukleniyor = false);
        return;
      }
      
      // Ay fazı bağlamını hazırla
      String? kozmikBaglam;
      try {
        final kozmikProvider = Provider.of<KozmikProvider>(context, listen: false);
        final bugun = DateTime.now();
        final ayFazi = kozmikProvider.ayFaziYorum(bugun);
        final illumination = kozmikProvider.getMoonIllumination(bugun);
        kozmikBaglam = "Bugün Ay: ${ayFazi['ad']} (Aydınlanma: %${(illumination * 100).toInt()}). ${ayFazi['yorum']} ${ayFazi['mitoloji'] ?? ''}";
      } catch (_) {}

      // Açılım pozisyonlarıyla zengin prompt oluştur
      final spread = _secilenSpread!;
      final positions = spread.positions;

      final kartBilgileri = _secilenKartlar
          .asMap()
          .entries
          .map((e) {
            final i = e.key;
            final kart = e.value;
            final isTers = _kartlarTersMi[kart] ?? false;
            final poz = i < positions.length ? positions[i] : null;
            return [
              if (poz != null)
                'Pozisyon ${i + 1}: ${poz.nameTr} — ${poz.meaning}',
              '  Kart: ${kart.ad} (${isTers ? "Ters" : "Düz"})',
              '  Anlam: ${isTers ? kart.tersAnlam : kart.duzAnlam}',
            ].join('\n');
          })
          .join('\n\n');

      // Özel kural kontrolü
      String? specialDirective;
      for (int i = 0; i < _secilenKartlar.length; i++) {
        final kart = _secilenKartlar[i];
        try {
          final directive = await TarotService.checkSpecialRule(
            spreadId: spread.id,
            cardId: kart.id,
            position: i,
          );
          if (directive != null) {
            specialDirective = directive;
            break;
          }
        } catch (e) {
          debugPrint('Hata: $e');
        }
      }

      // AI prompt'ı
      String? basePrompt;
      String? spreadPrompt;
      try {
        final aiPrompts = await TarotService.getAiPrompts();
        basePrompt = aiPrompts['base_prompt'] as String?;
        final spreadSpecific =
            aiPrompts['spread_specific'] as Map<String, dynamic>?;
        spreadPrompt = spreadSpecific?[spread.id] as String?;
      } catch (e) {
        debugPrint('Hata: $e');
      }

      final fullPrompt =
          '''
${basePrompt ?? 'Sen usta bir Türk Tarotu yorumcususun. Kadim Türk mitolojisi ve simgeleriyle zenginleştirilmiş, derin ve kişisel bir yorum yap.'}

${spreadPrompt ?? ''}

Açılım: ${spread.nameTr} (${spread.nameGokturk})
${spread.description.isNotEmpty ? 'Açıklama: ${spread.description}' : ''}

Kullanıcının Niyeti: ${_niyetController.text}
${kozmikBaglam != null ? '\nKozmik Bağlam:\n$kozmikBaglam' : ''}

Pozisyonlar ve Kartlar:
$kartBilgileri
${specialDirective != null ? '\n⚠️ ÖZEL KURAL:\n$specialDirective' : ''}
${spread.specialNote != null ? '\nNot: ${spread.specialNote}' : ''}

Her pozisyonun anlamını ve kartların birbirleriyle ilişkisini göz önünde bulundurarak,
kullanıcıya özel 200-250 kelimelik Türkçe bir yorum yaz.
''';

      final result = await ai.generateTextWithFallback(prompt: fullPrompt);

      if (!mounted) return;
      setState(() => _aiYorum = result);

      await ks.azaltQuota();
      await kullanici.addExperience(25);
    } catch (e) {
      debugPrint('TAROT AI HATASI: $e');
      if (!mounted) return;
      setState(
        () => _aiYorum =
            'Rüzgar sustu… Bilicinin sözü gelmedi.\nLütfen tekrar dene.',
      );
    }

    if (mounted && _secilenKartlar.isNotEmpty && _secilenSpread != null) {
      await _otomatikKaydet(
        kullanici: kullanici,
        kehanet: ks,
        isPremium: quotaInfo['premium'] == true,
      );
    }

    if (mounted) setState(() => _yorumYukleniyor = false);
  }

  Future<void> _otomatikKaydet({
    required KullaniciModel kullanici,
    required KehanetService kehanet,
    required bool isPremium,
  }) async {
    final spread = _secilenSpread!;
    final positions = spread.positions;
    final kartSatirlar = _secilenKartlar
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final kart = entry.value;
          final pozisyon = index < positions.length ? positions[index] : null;
          final isTers = _kartlarTersMi[kart] ?? false;
          final pozAd = pozisyon != null ? '${pozisyon.nameTr}: ' : '';
          return '$pozAd${kart.ad} (${isTers ? "Ters" : "Düz"})';
        })
        .join('\n');

    try {
      await ReadingAutoSave.saveFortune(
        kullanici: kullanici,
        kehanet: kehanet,
        type: 'tarot_${spread.id}',
        soru: _niyetController.text,
        sonuc: 'Açılım: ${spread.nameTr}\n\n$kartSatirlar',
        interpretation: _aiYorum ?? '',
        isPremium: isPremium,
        localTarot: KayitliTarot(
          tarih: DateTime.now(),
          niyet: _niyetController.text,
          kartDetaylari: List.generate(_secilenKartlar.length, (i) {
            final kart = _secilenKartlar[i];
            return {'ad': kart.ad, 'tersMi': _kartlarTersMi[kart] ?? false};
          }),
          yorum: _aiYorum ?? '',
        ),
      );
    } catch (e) {
      debugPrint('Tarot otomatik kayıt: $e');
    }
  }

  void _reset() {
    final shuffled = List<TarotKarti>.from(_kartlar)..shuffle();
    setState(() {
      _secilenKartlar = [];
      _kartlarTersMi = {};
      _acikKartlar.clear();
      _gridKartlar = List.generate(25, (i) => shuffled[i % shuffled.length]);
      _asama = TarotAsamasi.acilimSec;
      _secilenSpread = _spreadler.isNotEmpty ? _spreadler.first : null;
      _aiYorum = null;
      _niyetController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<KullaniciModel>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "TÜRK TAROTU",
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 2.5,
            color: Colors.white,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFFD700),
              size: 16,
            ),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF14122C),
              side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        backgroundColor: const Color(0xE60C0A18),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCosmos,
          image: DecorationImage(
            image: AssetImage("assets/images/tarot_arkayuz.webp"),
            fit: BoxFit.cover,
            opacity: 0.12,
          ),
        ),
        child: FutureBuilder<List<TarotKarti>>(
          future: _deste,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Hata: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStage(snapshot.data!),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStage(List<TarotKarti> deste) {
    switch (_asama) {
      case TarotAsamasi.acilimSec:
        return _buildAcilimSecimEkrani();
      case TarotAsamasi.niyetGir:
        return _buildNiyetEkrani(deste);
      case TarotAsamasi.kartlariCek:
        return _buildKartSecimi();
      case TarotAsamasi.yorumGoster:
        return _buildSonucEkrani();
    }
  }

  Widget _buildAcilimSecimEkrani() {
    if (_spreadler.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.amber500),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
      child: Column(
        children: [
          const _FannedCardPreview(),
          const SizedBox(height: 20),
          Text(
            'Açılım Seçin',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 2,
              color: AppColors.amber500,
            ),
          ),
          const SizedBox(height: 16),

          // CAROUSEL
          SizedBox(
            height: 380,
            child: PageView.builder(
              controller: _spreadPageController,
              itemCount: _spreadler.length,
              onPageChanged: (index) {
                setState(() => _secilenSpread = _spreadler[index]);
              },
              itemBuilder: (context, index) {
                final spread = _spreadler[index];
                final isSelected = _secilenSpread?.id == spread.id;

                return AnimatedScale(
                  scale: isSelected ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0x26F472B6)
                            : const Color(0xE614122C),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF472B6)
                              : AppColors.borderCard,
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.rCard),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // AÇILIM GÖRSELİ
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppSpacing.rCard - 4),
                                child: Image.asset(
                                  spread.image ?? 'assets/images/tarot_arkayuz.webp',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.style,
                                    size: 64,
                                    color: AppColors.fgDisabled,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // GÖKTÜRKÇE İSİM
                          Text(
                            spread.nameGokturk,
                            style: TextStyle(
                              fontFamily: AppTypography.fontRunic,
                              fontSize: 22,
                              color: isSelected
                                  ? const Color(0xFFF472B6)
                                  : AppColors.fgSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),

                          // TÜRKÇE İSİM
                          Text(
                            spread.nameTr,
                            style: TextStyle(
                              fontFamily: AppTypography.fontDisplay,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1,
                              color: isSelected ? Colors.white : AppColors.fgPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // KART SAYISI + ZORLUK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.style, size: 14, color: AppColors.fgTertiary),
                              const SizedBox(width: 4),
                              Text(
                                '${spread.cardCount} Kart',
                                style: TextStyle(fontSize: 11, color: AppColors.fgTertiary),
                              ),
                              const SizedBox(width: 12),
                              Icon(_getDifficultyIcon(spread.difficulty), size: 14, color: AppColors.fgTertiary),
                              const SizedBox(width: 4),
                              Text(
                                _getDifficultyText(spread.difficulty),
                                style: TextStyle(fontSize: 11, color: AppColors.fgTertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // DOT INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_spreadler.length, (index) {
              final isSelected = _secilenSpread?.id == _spreadler[index].id;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.amber500 : AppColors.fgDivider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // AÇIKLAMA
          if (_secilenSpread != null && _secilenSpread!.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _secilenSpread!.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.fgSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TarotChoiceButton(
              label: 'Devam Et',
              onTap: _secilenSpread != null
                  ? () => setState(() => _asama = TarotAsamasi.niyetGir)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Icons.circle;
      case 'intermediate':
        return Icons.adjust;
      case 'advanced':
        return Icons.album;
      default:
        return Icons.help_outline;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return difficulty;
    }
  }

  Widget _buildSonucEkrani() {
    if (_secilenSpread == null) return const SizedBox.shrink();

    final spread = _secilenSpread!;
    final positions = spread.positions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        children: [
          // Açılım başlığı
          Text(
            spread.nameGokturk,
            style: AppTypography.runicLg,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            spread.nameTr,
            style: AppTypography.displayLg,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),

          // Pozisyon + kart kartları
          ..._secilenKartlar.asMap().entries.map((entry) {
            final i = entry.key;
            final kart = entry.value;
            final isTers = _kartlarTersMi[kart] ?? false;
            final poz = i < positions.length ? positions[i] : null;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.space6),
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.borderAmber),
                borderRadius: BorderRadius.circular(AppSpacing.rCard),
              ),
              child: Column(
                children: [
                  if (poz != null) ...[
                    Text(
                      poz.nameGokturk,
                      style: AppTypography.runicMd.copyWith(
                        color: AppColors.amber500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      poz.nameTr,
                      style: AppTypography.displaySm,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      poz.meaning,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.fgSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Divider(color: AppColors.borderHairline),
                    const SizedBox(height: AppSpacing.space4),
                  ],

                  // Kart görseli
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                    child: Image.asset(
                      kart.resimYolu,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: AppColors.bgCardSoft,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.fgDisabled,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  // Kart adı
                  Text(
                    kart.ad,
                    style: AppTypography.displaySm.copyWith(
                      color: AppColors.amber500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Düz / Ters badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space1,
                    ),
                    decoration: BoxDecoration(
                      color: isTers
                          ? AppColors.danger.withValues(alpha: 0.2)
                          : AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                    ),
                    child: Text(
                      isTers ? 'TERS' : 'DÜZ',
                      style: AppTypography.bodySm.copyWith(
                        color: isTers ? AppColors.danger : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  // Kart anlamı
                  Text(
                    isTers ? kart.tersAnlam : kart.duzAnlam,
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppSpacing.space4),

          // AI yorumu
          if (_yorumYukleniyor)
            Padding(
              padding: EdgeInsets.all(AppSpacing.space6),
              child: CircularProgressIndicator(color: AppColors.cyanSpecial),
            )
          else if (_aiYorum == null)
            ElevatedButton.icon(
              onPressed: _yorumuAl,
              icon: Icon(Icons.auto_awesome, color: AppColors.fgOnAmber),
              label: const Text("Kam'ın Yorumu"),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: AppColors.bgIndigoLift,
                border: Border.all(color: AppColors.cyanSpecial),
                borderRadius: BorderRadius.circular(AppSpacing.rCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.cyanSpecial,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        "Kam'ın Yorumu",
                        style: AppTypography.displaySm.copyWith(
                          color: AppColors.cyanSpecial,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(_aiYorum!, style: AppTypography.bodyMd),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.space6),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden Bak'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  Widget _buildNiyetEkrani(List<TarotKarti> deste) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bir niyet veya soru yaz:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _niyetController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Niyetiniz...',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _asama = TarotAsamasi.kartlariCek);
            },
            child: const Text('Kartları Çek'),
          ),
        ],
      ),
    );
  }

  Widget _buildKartSecimi() {
    final gerekliKartSayisi = _secilenSpread?.cardCount ?? 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.widgetGap),
            GokHeader(
              titleGokturk: '𐰴𐰺𐱃⸱𐰾𐰃𐰲',
              titleLatin: 'KART SEÇİMİ',
              subtitle: '$gerekliKartSayisi kart seçin',
            ),
            const SizedBox(height: AppSpacing.widgetGap),

            // İLERLEME ÇUBUĞU
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.rButton),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.amber500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'KART SEÇİMİ: ${_secilenKartlar.length} / $gerekliKartSayisi',
                    style: AppTypography.displaySm.copyWith(
                      color: AppColors.amber500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.widgetGap),

            // 5x5 KART GRİDİ
            Expanded(
              child: _gridKartlar.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.amber500,
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final kart = _gridKartlar[index];
                        final isSecili = _secilenKartlar.contains(kart);
                        final isAcik = _acikKartlar.contains(index);

                        return GestureDetector(
                          onTap: () =>
                              _kartTiklandi(index, gerekliKartSayisi),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSecili
                                  ? [
                                      BoxShadow(
                                        color: AppColors.amber500
                                            .withValues(alpha: 0.6),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    isAcik
                                        ? kart.resimYolu
                                        : 'assets/images/tarot_arkayuz.webp',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.bgCardSoft,
                                      child: Icon(Icons.image,
                                          color: AppColors.fgDisabled,
                                          size: 20),
                                    ),
                                  ),
                                ),
                                if (isSecili)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: AppColors.amber500,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: AppColors.bgCosmos,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                                if (isAcik)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            AppColors.bgCosmos
                                                .withValues(alpha: 0.9),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        kart.ad,
                                        style: const TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: AppSpacing.widgetGap),

            GokButton(
              text: 'Kehaneti Aç',
              icon: Icons.auto_awesome,
              onPressed: _secilenKartlar.length == gerekliKartSayisi
                  ? () {
                      setState(() => _asama = TarotAsamasi.yorumGoster);
                      _yorumuAl();
                    }
                  : null,
            ),

            const SizedBox(height: AppSpacing.inlineGap),

            GokButton(
              text: 'Geri',
              icon: Icons.arrow_back,
              style: GokButtonStyle.secondary,
              onPressed: () {
                setState(() {
                  _asama = TarotAsamasi.niyetGir;
                  _secilenKartlar.clear();
                  _kartlarTersMi.clear();
                  _acikKartlar.clear();
                });
              },
            ),

            const SizedBox(height: AppSpacing.widgetGap),
          ],
        ),
      ),
    );
  }
}


// 3 fanned cards with pink aura glow (tr-glow 3s)
class _FannedCardPreview extends StatefulWidget {
  const _FannedCardPreview();

  @override
  State<_FannedCardPreview> createState() => _FannedCardPreviewState();
}

class _FannedCardPreviewState extends State<_FannedCardPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_glowCtrl);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        return SizedBox(
          height: 180,
          width: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pink aura glow
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFF472B6,
                      ).withValues(alpha: _glowOpacity.value * 0.4),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              // 3 fanned cards: translateX((k-1)*22) rotate((k-1)*6deg)
              ...List.generate(3, (k) {
                final offsetX = (k - 1) * 22.0;
                final angle = (k - 1) * 6.0 * pi / 180.0;
                return Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 80,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          width: 1,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/tarot_arkayuz.webp'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF000000,
                            ).withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TarotChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _TarotChoiceButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF4C1D6E), Color(0xFF1E1B4B)],
                )
              : null,
          color: enabled ? null : const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? const Color(0x99F472B6) : const Color(0x26FFFFFF),
            width: 1.5,
          ),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0x33F472B6),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.2,
            color: enabled ? Colors.white : AppColors.fgDisabled,
          ),
        ),
      ),
    );
  }
}
