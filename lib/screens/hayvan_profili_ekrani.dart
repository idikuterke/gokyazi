import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hayvan_model.dart';
import '../models/kullanici_model.dart';
import '../services/ai_services_holder.dart';
import '../services/erentuz_service.dart';
import '../services/kehanet_service.dart';
import '../services/reading_auto_save.dart';
import '../services/takvim_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_screen_scaffold.dart';
import 'kozmik_uyum_ekrani.dart';

class HayvanProfiliEkrani extends StatefulWidget {
  final Hayvan hayvan;
  final DateTime dogumTarihi;

  const HayvanProfiliEkrani({
    super.key,
    required this.hayvan,
    required this.dogumTarihi,
  });

  @override
  State<HayvanProfiliEkrani> createState() => _HayvanProfiliEkraniState();
}

class _HayvanProfiliEkraniState extends State<HayvanProfiliEkrani> {
  String? _yillikYorum;
  bool _yorumYukleniyor = false;
  YearAstrology? _astrology;
  bool _astrologyYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _astrologyYukle();
  }

  Future<void> _astrologyYukle() async {
    final astro = await TakvimService.getYearAstrologyForDate(widget.dogumTarihi);
    if (!mounted) return;
    setState(() {
      _astrology = astro;
      _astrologyYukleniyor = false;
    });
  }

  void _tarihSec() => Navigator.pop(context);

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

  Future<void> _aiYorumAl() async {
    if (_yorumYukleniyor) return;
    setState(() => _yorumYukleniyor = true);

    try {
      final kullanici = context.read<KullaniciModel>();
      final ks = KehanetService();
      final ai = context.read<AiServicesHolder>();
      final quotaInfo = await ks.getQuotaInfo();
      
      final jupiterData = ErentuzService.getJupiterCycle(widget.dogumTarihi);
      final sonZiyaret = jupiterData['son_ziyaret']!;
      final sonrakiZiyaret = jupiterData['sonraki_ziyaret']!;

      final prompt = '''
Sen usta bir Türk Şamanısın (Kam). Kadim 12 Hayvanlı Türk Takvimi'ne göre kullanıcının profilini yorumlayacaksın.

Kullanıcının doğum tarihi: ${widget.dogumTarihi.day}/${widget.dogumTarihi.month}/${widget.dogumTarihi.year}
Kullanıcının hayvan yılı: ${widget.hayvan.adlar.turkce} (${widget.hayvan.adlar.eskiTurkce})

Kozmik Bağlam:
- Erentüz (Jüpiter) son ziyaret: $sonZiyaret
- Sonraki ziyaret: $sonrakiZiyaret
- Jüpiter 12 yılda bir bu hayvana döner.

${sonrakiZiyaret == DateTime.now().year 
  ? 'NOT: Bu yıl Jüpiter dönemi aktif! 12 yıllık döngü yeniden başlıyor.' 
  : ''}

Bu kişinin kişilik özelliklerini, güçlü ve zayıf yönlerini, şamanik elementini ve Erentüz döngüsünü göz önüne alarak ona mistik ve ilham verici bir yorum yap. En fazla 150 kelime olsun.
''';

      if (!quotaInfo['premium'] && (quotaInfo['kalan'] as int) <= 0) {
        if (mounted) {
          _showKotaDoluDialog();
          setState(() => _yorumYukleniyor = false);
        }
        return;
      }

      final yorum = await ai.generateTextWithFallback(prompt: prompt);

      await ks.azaltQuota();
      await ReadingAutoSave.saveFortune(
        kullanici: kullanici,
        kehanet: ks,
        type: 'hayvan_takvim',
        soru: 'Doğum tarihi: ${widget.dogumTarihi.year}',
        sonuc: '${widget.hayvan.adlar.turkce} (${widget.dogumTarihi.year})',
        interpretation: yorum,
        isPremium: quotaInfo['premium'] == true,
        useLocalDailyQuota: false,
      );

      if (!mounted) return;
      setState(() => _yillikYorum = yorum);
    } catch (e) {
      debugPrint('AI Yorum hatası: $e');
    } finally {
      if (mounted) setState(() => _yorumYukleniyor = false);
    }
  }

  void _paylasProfili() {
    final text = '''
🐺 ${widget.hayvan.adlar.turkce} (${widget.dogumTarihi.year})
Gök Türkçe: ${widget.hayvan.adlar.gokturkceYazim ?? ''}
Kozmik Element: ${_astrology?.element ?? ''}
Enerji Polaritesi: ${_astrology?.yinYang ?? ''}

"${widget.hayvan.kisilik.ozet}"

${widget.hayvan.kisilik.detay}

#GökYazı #TürkTakvimi
''';
    Share.share(text, subject: 'Kozmik Hayvan Profilim');
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.amber;
    }
  }

  void _showDeepAnalysisSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCosmos,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Kişisel Kozmik Derin Analiz',
                      style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.fgSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Göklerin bilgeliğiyle hayat yolculuğunuzu aydınlatın. Bu özel rapor şunları içerir:',
                style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
              ),
              const SizedBox(height: 16),
              _buildBulletItem('Detaylı Element Dengesi & Ruh Ongunu Rehberi'),
              _buildBulletItem('Aşk, Evlilik ve Ortaklık Uyum Matrisi'),
              _buildBulletItem('10 Yıllık Büyük Hayat Döngüsü & Kritik Yıllar'),
              _buildBulletItem('Kariyer, Finans ve Uğurlu Günler Rehberi'),
              const SizedBox(height: 24),
              GokButton(
                text: 'Analizi Başlat (99 TL)',
                icon: Icons.workspace_premium,
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.bgIndigoLift,
                      title: Text('Talebiniz Alındı', style: TextStyle(color: AppColors.amber500)),
                      content: Text(
                        'Kozmik derin analiz talebiniz başarıyla oluşturulmuştur. Raporunuz en kısa sürede göklerin bilgeliğiyle hazırlanarak hesabınıza iletilecektir.',
                        style: TextStyle(color: AppColors.fgSecondary),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Kapat', style: TextStyle(color: AppColors.amber500)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.star, color: AppColors.amber500, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTypography.bodyMd.copyWith(color: AppColors.fgPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_astrologyYukleniyor) {
      return Scaffold(
        backgroundColor: AppColors.bgCosmos,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.amber500),
          ),
        ),
      );
    }

    return GokScreenScaffold(
      appBarTitle: '${widget.hayvan.adlar.turkce} Yılı',
      backgroundAsset: 'assets/images/genel_arkaplan.webp',
      backgroundOpacity: 0.45,
      showHeader: false,
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: AppColors.fgPrimary),
          onPressed: _paylasProfili,
        ),
      ],
      body: _buildProfilSonuc(),
    );
  }

  Widget _buildProfilSonuc() {
    final mucelDurumu = TakvimService.getMucelDurumu(widget.dogumTarihi.year);
    final imagePath = TakvimService.getImagePathForId(widget.hayvan.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GokButton(
                text: 'Tarih Değiştir',
                icon: Icons.edit_calendar,
                style: GokButtonStyle.secondary,
                onPressed: _tarihSec,
              ),
            ),
            const SizedBox(width: AppSpacing.widgetGap),
            Expanded(
              child: GokButton(
                text: 'Uyum Analizi',
                icon: Icons.favorite,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KozmikUyumEkrani(
                        kullaniciTarih: widget.dogumTarihi,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        GokCard(
          child: Column(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.pets,
                      size: 80,
                      color: AppColors.amber500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(
                widget.hayvan.adlar.turkce.toUpperCase(),
                style: AppTypography.displayXl.copyWith(color: AppColors.amber500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.dogumTarihi.year} Yılı',
                style: AppTypography.displaySm.copyWith(color: AppColors.fgSecondary),
              ),
              if (widget.hayvan.adlar.gokturkceYazim != null) ...[
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  widget.hayvan.adlar.gokturkceYazim!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontRunic,
                    fontSize: 22,
                    color: AppColors.cyanSpecial,
                  ),
                ),
              ],
              if (_astrology != null) ...[
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  '${_astrology!.element} Elementi · ${_astrology!.yinYang}',
                  style: AppTypography.bodyXs.copyWith(
                    color: AppColors.fgTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        if (_astrology != null) ...[
          _buildCosmicRow(),
          const SizedBox(height: AppSpacing.sectionGap),
        ],

        GokCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: AppColors.amber500, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Karakter Özeti',
                      style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.widgetGap),
              Text(
                '"${widget.hayvan.kisilik.ozet}"',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.fgSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.inlineGap),
              Text(
                widget.hayvan.kisilik.detay,
                style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary, height: 1.6),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GokCard(
                customColor: AppColors.success.withValues(alpha: 0.08),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 28),
                    const SizedBox(height: AppSpacing.inlineGap),
                    Text(
                      'Güçlü Yönler',
                      style: AppTypography.displayXs.copyWith(color: AppColors.success),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.widgetGap),
                    ...widget.hayvan.kisilik.gucluYonler.take(4).map((item) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✓ ', style: TextStyle(color: AppColors.success, fontSize: 12)),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.widgetGap),
            Expanded(
              child: GokCard(
                customColor: AppColors.danger.withValues(alpha: 0.08),
                child: Column(
                  children: [
                    Icon(Icons.warning_rounded, color: AppColors.danger, size: 28),
                    const SizedBox(height: AppSpacing.inlineGap),
                    Text(
                      'Dikkat Et',
                      style: AppTypography.displayXs.copyWith(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.widgetGap),
                    ...widget.hayvan.kisilik.zayifYonler.take(4).map((item) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('! ', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        _buildCompatibilityCard(),

        const SizedBox(height: AppSpacing.sectionGap),

        if (widget.hayvan.mitolojiVeFolklor.isNotEmpty)
          GokCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories, color: AppColors.cyanSpecial, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mitoloji & Halk İnanışı',
                        style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.widgetGap),
                Text(
                  widget.hayvan.mitolojiVeFolklor,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.fgSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

        if (widget.hayvan.mitolojiVeFolklor.isNotEmpty)
          const SizedBox(height: AppSpacing.sectionGap),

        _buildOngunCard(),

        const SizedBox(height: AppSpacing.sectionGap),

        _buildJupiterDongusu(),

        const SizedBox(height: AppSpacing.sectionGap),

        GokCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_top, color: AppColors.amber500, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Müçel Yaşı (${mucelDurumu['ad']})',
                      style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.widgetGap),
              Text(
                mucelDurumu['aciklama'] ?? '',
                style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary, height: 1.6),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        GokButton(
          text: 'Bu Yılın Göksel Yorumunu Al',
          icon: Icons.auto_awesome,
          isLoading: _yorumYukleniyor,
          onPressed: _yorumYukleniyor ? null : _aiYorumAl,
        ),

        if (_yillikYorum != null) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          GokCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.amber500, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bu Yılın Göksel Yorumu',
                        style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.widgetGap),
                Text(
                  _yillikYorum!,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.sectionGap),

        GokCard(
          customColor: Colors.black.withValues(alpha: 0.3),
          child: Column(
            children: [
              Icon(Icons.workspace_premium, color: AppColors.amber500, size: 40),
              const SizedBox(height: AppSpacing.widgetGap),
              Text(
                'Kişisel Kozmik Derin Analiz',
                style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Doğum yılın, elementinin ve Yin/Yang dengesini içeren 15 sayfalık kişisel kozmik rapor.',
                style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.widgetGap),
              GokButton(
                text: 'DERİN ANALİZİ BAŞLAT',
                icon: Icons.auto_awesome,
                onPressed: _showDeepAnalysisSheet,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),
      ],
    );
  }

  Widget _buildSembolSatir(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              baslik,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.amber500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              deger,
              style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicRow() {
    final elementColor = _parseHexColor(_astrology!.elementMeta.renkHex);
    final yinYangColor = _parseHexColor(_astrology!.yinYangMeta.renkHex);

    return Row(
      children: [
        Expanded(
          child: GokCard(
            customColor: elementColor.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_astrology!.element} Elementi',
                  style: AppTypography.displayXs.copyWith(color: elementColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _astrology!.elementMeta.adEski,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
                ),
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  _astrology!.elementMeta.aciklama,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  'Yön: ${_astrology!.elementMeta.yon} · Mevsim: ${_astrology!.elementMeta.mevsim}',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.widgetGap),
        Expanded(
          child: GokCard(
            customColor: yinYangColor.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${_astrology!.yinYang} Polaritesi',
                        style: AppTypography.displayXs.copyWith(color: yinYangColor),
                      ),
                    ),
                    Text(_astrology!.yinYangMeta.sembol, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  _astrology!.yinYangMeta.aciklama,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.inlineGap),
                Text(
                  'Mevsim Enerjisi: ${widget.hayvan.mevsim}',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJupiterDongusu() {
    final jupiterData = ErentuzService.getJupiterCycle(widget.dogumTarihi);
    final sonZiyaret = jupiterData['son_ziyaret']!;
    final sonrakiZiyaret = jupiterData['sonraki_ziyaret']!;
    final suAnkiYil = DateTime.now().year;
    
    final aktifDonem = suAnkiYil == sonrakiZiyaret;
    
    return GokCard(
      customColor: aktifDonem 
        ? AppColors.deepPurpleSeed.withValues(alpha: 0.2) 
        : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.deepPurpleSeed.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.blur_circular,
                  color: AppColors.deepPurpleSeed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Erentüz Döngüsü',
                      style: AppTypography.displaySm.copyWith(
                        color: AppColors.fgPrimary,
                      ),
                    ),
                    Text(
                      '𐰀𐰼𐰤𐱅𐰇𐰕 (Jüpiter)',
                      style: TextStyle(
                        fontFamily: 'Orkun',
                        fontSize: 14,
                        color: AppColors.cyanSpecial,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.widgetGap),
          
          Text(
            'Jüpiter 12 yılda bir senin hayvanını ziyaret eder. Her ziyaret, yeni bir döngünün başlangıcıdır.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.fgSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sectionGap),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: AppColors.bgCardSoft,
              borderRadius: BorderRadius.circular(AppSpacing.rThumb),
            ),
            child: Column(
              children: [
                _buildJupiterRow(
                  'Son Ziyaret',
                  '$sonZiyaret',
                  Icons.history,
                ),
                
                Divider(color: AppColors.borderCard, height: 24),
                
                _buildJupiterRow(
                  'Sonraki Ziyaret',
                  '$sonrakiZiyaret',
                  Icons.event,
                  isHighlight: aktifDonem,
                ),
              ],
            ),
          ),
          
          if (aktifDonem) ...[
            const SizedBox(height: AppSpacing.widgetGap),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepPurpleSeed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                border: Border.all(color: AppColors.deepPurpleSeed),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: AppColors.deepPurpleSeed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 Erentüz bu yıl senin hayvanında! 12 yıllık döngü yeniden başlıyor.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.fgPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppSpacing.widgetGap),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCardSoft,
              borderRadius: BorderRadius.circular(AppSpacing.rThumb),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💭', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$sonZiyaret yılında hayatında ne değişti? O dönemi hatırla - aynı enerji şimdi tekrar ediyor.',
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.fgTertiary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJupiterRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isHighlight ? AppColors.deepPurpleSeed : AppColors.fgTertiary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.fgSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.displaySm.copyWith(
            color: isHighlight ? AppColors.deepPurpleSeed : AppColors.amber500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOngunCard() {
    return GokCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.amber500, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kozmik Ongunlar & Semboller',
                  style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          if (widget.hayvan.kozmoloji.ongunHayvan != null)
            _buildSembolSatir('Koruyucu Hayvan (Ongun):', widget.hayvan.kozmoloji.ongunHayvan!),
          if (widget.hayvan.ongunBitki != null)
            _buildSembolSatir('Kutlu Bitki:', widget.hayvan.ongunBitki!),
          if (widget.hayvan.tarihiKisiler.isNotEmpty)
            _buildSembolSatir(
              'Bu Yılda Doğan Tarihi Kişiler:',
              widget.hayvan.tarihiKisiler.join(', '),
            ),
          _buildSembolSatir('Kutlu Yönü:', _astrology?.elementMeta.yon ?? 'Doğu'),
        ],
      ),
    );
  }

  Widget _buildCompatibilityCard() {
    return GokCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub, color: AppColors.amber500, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kozmik Uyum Haritası',
                  style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kozmolojik ilişki döngülerinde tam uyum ve kaçınılması gereken zıtlık döngüleri.',
            style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: AppColors.danger, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Uyumlu Yıldızlar',
                          style: AppTypography.bodyXs.copyWith(
                            color: AppColors.fgPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.hayvan.uyumluHayvanlar
                          .map((id) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${TakvimService.getAnimalEmoji(id)} ${TakvimService.getAnimalNameTr(id)}',
                                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgPrimary),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.amber500, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Kozmik Sınavlar',
                          style: AppTypography.bodyXs.copyWith(
                            color: AppColors.fgPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.hayvan.catismaliHayvanlar
                          .map((id) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.rThumb),
                                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${TakvimService.getAnimalEmoji(id)} ${TakvimService.getAnimalNameTr(id)}',
                                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgPrimary),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
