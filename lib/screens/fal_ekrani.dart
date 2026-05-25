// fal_ekrani.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'rituel_ekrani.dart';
import '../models/fal_model.dart';
import '../models/kayitli_irk_bitig.dart';
import '../services/ai_services_holder.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_input.dart';
import '../widgets/core/gok_screen_scaffold.dart';
import '../widgets/fal_detay_widget.dart';
import '../widgets/zar_widget.dart';
import '../services/ai_services_holder.dart';
import '../providers/kozmik_provider.dart';
import '../models/kullanici_model.dart';
import '../services/kehanet_service.dart';
import '../services/reading_auto_save.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum GosterimTuru { gokturkce, transliterasyon, turkce, modernYorum, aiYorumu }

const _zarRuneleri = ['𐰋', '𐰃', '𐱅', '𐰬'];

class FalEkrani extends StatefulWidget {
  const FalEkrani({super.key});
  @override
  State<FalEkrani> createState() => _FalEkraniState();
}

class _FalEkraniState extends State<FalEkrani> with TickerProviderStateMixin {
  Fal? gosterilenFal;
  String? aiYorumu;
  bool isProcessRunning = false;
  List<int> zarSonuclari = [];
  final TextEditingController _soruController = TextEditingController();
  bool _aiYorumYukleniyor = false;
  Timer? _debounceTimer;

  // Result aura burst
  late AnimationController _auraController;
  late Animation<double> _auraScale;
  late Animation<double> _auraGlow;

  // Prompt stage: hero die float (ib-float 2.8s)
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Prompt stage: shimmer aura (ib-shimmer 3.4s)
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerScale;
  late Animation<double> _shimmerOpacity;

  // Rolling stage: 3D dice tumble (ib-tumble 0.9s)
  late AnimationController _tumbleCtrl;

  // Rolling stage: drum wave bars (ib-wave 1.2s)
  late AnimationController _waveCtrl;

  // Result stage: dice pop-in (ib-popin 500ms + stagger)
  late AnimationController _popInCtrl;

  // Result stage: row reveal (ib-reveal 700ms)
  late AnimationController _revealCtrl;

  final AudioPlayer _drumPlayer = AudioPlayer();

  final List<String> _ritual = [
    "🕯 Niyetine odaklan...",
    "🌬 Derin nefes al...",
    "✨ Ataların nefesi seninle...",
    "📜 Kader yazıtın açılıyor...",
  ];
  String? _ritualText;

  @override
  void initState() {
    super.initState();

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _auraScale = Tween<double>(begin: 0.8, end: 1.1)
        .chain(CurveTween(curve: Curves.easeOutCirc))
        .animate(_auraController);
    _auraGlow = Tween<double>(begin: 0.2, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_auraController);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0.0, end: -9.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_floatCtrl);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
    _shimmerScale = Tween<double>(begin: 1.0, end: 1.06)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shimmerCtrl);
    _shimmerOpacity = Tween<double>(begin: 0.55, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shimmerCtrl);

    _tumbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _popInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _drumPlayer.dispose();
    _auraController.dispose();
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _tumbleCtrl.dispose();
    _waveCtrl.dispose();
    _popInCtrl.dispose();
    _revealCtrl.dispose();
    _soruController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      gosterilenFal = null;
      aiYorumu = null;
      _aiYorumYukleniyor = false;
      zarSonuclari = [];
      _ritualText = null;
      _soruController.clear();
    });
    _popInCtrl.reset();
    _revealCtrl.reset();
  }

  void _showKotaDoluDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgIndigoLift,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Haftalık Limit Doldu', style: TextStyle(color: AppColors.amber500)),
        content: Text(
          'Bu haftaki AI yorum hakkınız doldu.\n\nPremium üyelik ile sınırsız yorum alabilirsiniz!',
          style: TextStyle(color: AppColors.fgSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tamam', style: TextStyle(color: AppColors.fgSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber700),
            child: const Text('Premium Ol', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _yorumuAl(Fal fal, String key) async {
    if (!mounted) return;
    final ai = context.read<AiServicesHolder>();
    
    // Ay fazı bağlamını hazırla
    String? kozmikBaglam;
    try {
      final kozmikProvider = Provider.of<KozmikProvider>(context, listen: false);
      final bugun = DateTime.now();
      final ayFazi = kozmikProvider.ayFaziYorum(bugun);
      final illumination = kozmikProvider.getMoonIllumination(bugun);
      kozmikBaglam = "Bugün Ay: ${ayFazi['ad']} (Aydınlanma: %${(illumination * 100).toInt()}). ${ayFazi['yorum']} ${ayFazi['mitoloji'] ?? ''}";
    } catch (_) {}

    final ks = KehanetService();
    final quotaInfo = await ks.getQuotaInfo();
    if (!quotaInfo['premium'] && (quotaInfo['kalan'] as int) <= 0) {
      if (!mounted) return;
      _showKotaDoluDialog();
      return;
    }

    String y;
    Exception? geminiError;
    try {
      final gemini = ai.geminiOrNull;
      if (gemini != null) {
        y = await gemini.getGeminiInterpretation(
          fal: fal,
          soru: _soruController.text,
          kozmikBaglam: kozmikBaglam,
        );
      } else {
        throw Exception('Gemini ayarlanmamış.');
      }
    } catch (e) {
      geminiError = Exception(e.toString());
      final groq = ai.groqOrNull;
      if (groq != null) {
        try {
          y = await groq.getIrkBitigYorum(
            falMetni: fal.turkce,
            soru: _soruController.text,
            kozmikBaglam: kozmikBaglam,
          );
        } catch (groqError) {
          y = 'Yorum alınamadı: $groqError. (Gemini: ${geminiError.toString()})';
        }
      } else {
        y = 'Yorum alınamadı: $geminiError';
      }
    }

    if (!mounted) return;
    setState(() => aiYorumu = y);

    if (y.startsWith('Gök kapalı') || y.startsWith('Yorum alınamadı')) return;

    await ks.azaltQuota();
  }

  Future<void> _otomatikKaydetIrkBitig(Fal fal, String key) async {
    if (!mounted) return;
    final kullanici = context.read<KullaniciModel>();
    final ks = KehanetService();
    final quota = await ks.getQuotaInfo();
    final yorum = aiYorumu ?? '';
    final isRealYorum = yorum.isNotEmpty &&
        !yorum.startsWith('Yorum alınamadı') &&
        !yorum.startsWith('Gök kapalı');

    try {
      await ReadingAutoSave.saveFortune(
        kullanici: kullanici,
        kehanet: ks,
        type: 'irk_bitig',
        soru: _soruController.text,
        sonuc:
            'Göktürkçe: ${fal.gokturkce}\nTürkçe: ${fal.turkce}\nYorum: ${fal.yorumModern}',
        interpretation: isRealYorum ? yorum : '',
        isPremium: quota['premium'] == true,
        localIrkBitig: KayitliIrkBitig(
          kombinasyon: key,
          tarih: DateTime.now(),
          fal: fal,
          soru: _soruController.text,
          geminiYorumu: isRealYorum ? yorum : '',
        ),
      );
    } catch (e) {
      debugPrint('Irk Bitig otomatik kayıt: $e');
    }
  }

  Future<void> falCek() async {
    if (_soruController.text.trim().isEmpty || isProcessRunning) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isProcessRunning = true;
      gosterilenFal = null;
      aiYorumu = null;
      zarSonuclari.clear();
      _ritualText = null;
    });
    _popInCtrl.reset();
    _revealCtrl.reset();

    for (var i = 0; i < 3; i++) {
      setState(() => _ritualText = _ritual[i]);
      await Future.delayed(const Duration(milliseconds: 1700));

      try {
        await _drumPlayer.play(AssetSource('sounds/drum.wav'));
      } catch (e, st) {
        debugPrint('Irk Bitig ses çalma hatası: $e\n$st');
      }
      HapticFeedback.mediumImpact();

      zarSonuclari.add(Random().nextInt(4) + 1);
      setState(() => _ritualText = null);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final key = zarSonuclari.join("-");
    Map<String, dynamic> data;
    try {
      final jsonString = await rootBundle.loadString("assets/fallar.json");
      data = Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e, st) {
      debugPrint('Irk Bitig JSON yükleme/parsing hatası: $e\n$st');
      if (!mounted) return;
      setState(() {
        isProcessRunning = false;
      });
      return;
    }
    final d = data[key];

    if (d != null) {
      late final Fal fal;
      try {
        fal = Fal.fromJson(d);
      } catch (e, st) {
        debugPrint('Fal parse hatası: $e\n$st');
        if (!mounted) return;
        setState(() {
          isProcessRunning = false;
        });
        return;
      }
      setState(() {
        gosterilenFal = fal;
      });

      _popInCtrl.forward(from: 0);
      _revealCtrl.forward(from: 0);
      _auraController.forward(from: 0);

      await _otomatikKaydetIrkBitig(fal, key);
    } else {
      setState(() {
        // Fallback or handle missing data error if necessary
      });
    }

    setState(() => isProcessRunning = false);
  }

  // ---------- animation helpers ----------

  Widget _buildHeroDie() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _shimmerCtrl]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Transform.scale(
            scale: _shimmerScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700)
                            .withValues(alpha: _shimmerOpacity.value * 0.35),
                        blurRadius: 50,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D1B69), Color(0xFF1E1B4B), Color(0xFF0C0A18)],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFD700)
                          .withValues(alpha: _shimmerOpacity.value * 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700)
                            .withValues(alpha: _shimmerOpacity.value * 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '𐰋',
                      style: TextStyle(fontSize: 38, color: Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTumblingDie(int index) {
    return AnimatedBuilder(
      animation: _tumbleCtrl,
      builder: (context, _) {
        final t = (_tumbleCtrl.value + index / 6.0) % 1.0;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(t * 2 * pi)
          ..rotateY(t * pi);

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D2B79), Color(0xFF1E1B4B), Color(0xFF0C0A18)],
              ),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4DFFD700),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _zarRuneleri[index % _zarRuneleri.length],
                style: const TextStyle(fontSize: 28, color: Color(0xFFFFD700)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveBars() {
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(9, (k) {
            final barT = (_waveCtrl.value + k / 15.0) % 1.0;
            final sinVal = sin(barT * pi).clamp(0.0, 1.0);
            final scaleY = 1.0 + 4.0 * sinVal;
            final opacity = 0.4 + 0.6 * sinVal;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scaleY: scaleY,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 4,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildResultDice() {
    return AnimatedBuilder(
      animation: _popInCtrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            const startFraction = 100.0 / 700.0;
            const durFraction = 500.0 / 700.0;
            final rawT = ((_popInCtrl.value - i * startFraction) / durFraction)
                .clamp(0.0, 1.0);
            final t = Curves.easeOutBack.transform(rawT);

            return Opacity(
              opacity: rawT.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.5 + 0.5 * t,
                child: Transform.rotate(
                  angle: -(1.0 - rawT) * pi / 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ZarWidget(sayi: zarSonuclari[i]),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRevealContent(Widget child) {
    return AnimatedBuilder(
      animation: _revealCtrl,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_revealCtrl.value);
        return Opacity(
          opacity: _revealCtrl.value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    context.watch<KullaniciModel>();
    final showPrompt = gosterilenFal == null && !isProcessRunning;
    final showRolling = isProcessRunning;
    final showResult = gosterilenFal != null && !isProcessRunning;

    return GokScreenScaffold(
      backgroundAsset: 'assets/images/bg_fal_ekrani.webp',
      backgroundOpacity: 0.4,
      appBarTitle: showPrompt ? null : 'Irk Bitig',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
      showHeader: showPrompt,
      titleGokturk: '𐰃𐰺𐰚⸱𐰋𐰃𐱅𐰃𐰏',
      titleLatin: 'IRK BİTİG',
      subtitle: 'Kadim Kehanet Kitabı',
      padding: EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        top: showPrompt ? AppSpacing.pagePadding : AppSpacing.space8,
        bottom: AppSpacing.pagePadding,
      ),
      body: Column(
        children: [
          // --- Prompt Stage ---
          if (showPrompt) ...[
            _buildHeroDie(),
            const SizedBox(height: AppSpacing.sectionGap),
            GokCard(
              child: GokInput(
                controller: _soruController,
                labelText: 'Niyetini yaz...',
                onChanged: (_) {
                  if (_debounceTimer?.isActive ?? false) {
                    _debounceTimer!.cancel();
                  }
                  _debounceTimer = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.widgetGap),
            GokButton(
              text: 'Zarları At',
              icon: Icons.casino,
              onPressed: _soruController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RituelEkrani(
                            onFinish: () {
                              Navigator.pop(context);
                              falCek();
                            },
                          ),
                        ),
                      );
                    },
            ),
          ],

          // --- Rolling Stage ---
          if (showRolling) ...[
            const SizedBox(height: AppSpacing.sectionGap),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: _ritualText != null
                          ? Text(
                              _ritualText!,
                              key: ValueKey(_ritualText),
                              textAlign: TextAlign.center,
                              style: AppTypography.displayMd.copyWith(
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFFFD700),
                              ),
                            )
                          : const SizedBox(key: ValueKey('empty'), height: 32),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, _buildTumblingDie),
                    ),
                    const SizedBox(height: 28),
                    _buildWaveBars(),
                  ],

                  // --- Result Stage ---
                  if (showResult) ...[
                    _buildResultDice(),
                    const SizedBox(height: 20),

                    _buildRevealContent(
                      AnimatedBuilder(
                        animation: _auraController,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: _auraScale.value,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(
                                      alpha: _auraGlow.value * 0.3,
                                    ),
                                    blurRadius: 30 * _auraGlow.value,
                                    spreadRadius: 4 * _auraGlow.value,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: FalDetayWidget(
                          fal: gosterilenFal!,
                          aiYorumu: aiYorumu,
                          aiYorumYukleniyor: _aiYorumYukleniyor,
                          onAiYorumIste: () async {
                            setState(() => _aiYorumYukleniyor = true);
                            await _yorumuAl(gosterilenFal!, zarSonuclari.join("-"));
                            setState(() => _aiYorumYukleniyor = false);
                            await _otomatikKaydetIrkBitig(gosterilenFal!, zarSonuclari.join("-"));
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

            _buildRevealContent(
              GokButton(
                text: 'Yeni Soru',
                style: GokButtonStyle.secondary,
                onPressed: _reset,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
