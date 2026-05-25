import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hayvan_model.dart';
import '../models/kullanici_model.dart';
import '../services/kehanet_service.dart';
import '../services/reading_auto_save.dart';
import '../services/takvim_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_screen_scaffold.dart';

class KozmikUyumEkrani extends StatefulWidget {
  final String? kullaniciHayvan;
  final DateTime? kullaniciTarih;

  const KozmikUyumEkrani({
    super.key,
    this.kullaniciHayvan,
    this.kullaniciTarih,
  });

  @override
  State<KozmikUyumEkrani> createState() => _KozmikUyumEkraniState();
}

class _KozmikUyumEkraniState extends State<KozmikUyumEkrani> {
  DateTime? _tarihA;
  DateTime? _tarihB;

  YearAstrology? _astrologyA;
  YearAstrology? _astrologyB;

  bool _hesaplandi = false;
  bool _yukleniyor = false;

  int _toplamSkor = 0;
  int _hayvanSkor = 0;
  int _elementSkor = 0;
  int _polariteSkor = 0;

  String _hayvanYorum = '';
  String _elementYorum = '';
  String _polariteYorum = '';

  @override
  void initState() {
    super.initState();
    if (widget.kullaniciTarih != null) {
      _tarihA = widget.kullaniciTarih;
      _profilYukleA();
    }
  }

  Future<void> _tarihSecA(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _tarihA ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Sizin Doğum Tarihiniz',
      builder: _datePickerThemeBuilder,
    );
    if (secilen != null) {
      setState(() {
        _tarihA = secilen;
        _hesaplandi = false;
      });
      _profilYukleA();
    }
  }

  Future<void> _tarihSecB(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _tarihB ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Partnerin Doğum Tarihi',
      builder: _datePickerThemeBuilder,
    );
    if (secilen != null) {
      setState(() {
        _tarihB = secilen;
        _hesaplandi = false;
      });
      _profilYukleB();
    }
  }

  Widget _datePickerThemeBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1A2E)),
        colorScheme: ColorScheme.dark(
          primary: AppColors.amber500,
          onPrimary: AppColors.fgOnAmber,
          surface: AppColors.bgCosmos,
          onSurface: AppColors.fgPrimary,
        ),
      ),
      child: child!,
    );
  }

  Future<void> _profilYukleA() async {
    if (_tarihA == null) return;
    final astro = await TakvimService.getYearAstrologyForDate(_tarihA!);
    if (mounted) setState(() => _astrologyA = astro);
  }

  Future<void> _profilYukleB() async {
    if (_tarihB == null) return;
    final astro = await TakvimService.getYearAstrologyForDate(_tarihB!);
    if (mounted) setState(() => _astrologyB = astro);
  }

  void _uyumHesapla() {
    if (_astrologyA == null || _astrologyB == null) return;

    setState(() => _yukleniyor = true);

    // Hayvan Uyumu
    final idB = _astrologyB!.hayvan.id;
    final nameA = _astrologyA!.hayvan.adlar.turkce;
    final nameB = _astrologyB!.hayvan.adlar.turkce;

    int hayvanUyum = 60;
    if (_astrologyA!.hayvan.uyumluHayvanlar.contains(idB)) {
      hayvanUyum = 95;
      _hayvanYorum =
          "Gök yazgısında $nameA ve $nameB yıldızları tam uyum içindedir. Birbirinizin adımlarını kolaylaştırır, zor zamanlarda güçlü birer sığınak olursunuz.";
    } else if (_astrologyA!.hayvan.catismaliHayvanlar.contains(idB)) {
      hayvanUyum = 30;
      _hayvanYorum =
          "$nameA ve $nameB kozmik döngüde karşıt açılardadır. Bu durum ilişkide yoğun çekim yaratabileceği gibi, ego çatışmalarına ve iletişim sınavlarına da yol açabilir. Karşılıklı esneklik gerekir.";
    } else {
      _hayvanYorum =
          "$nameA ve $nameB enerjileri dengeli ve bağımsızdır. Birbirinize alan tanıdığınız sürece uyumlu ve saygılı bir ilişki kurabilirsiniz.";
    }

    // Element Uyumu
    final elemA = _astrologyA!.element;
    final elemB = _astrologyB!.element;

    final Map<String, String> feeds = {
      'Ağaç': 'Ateş', 'Ateş': 'Toprak', 'Toprak': 'Metal', 'Metal': 'Su', 'Su': 'Ağaç',
    };
    final Map<String, String> destroys = {
      'Ağaç': 'Toprak', 'Toprak': 'Su', 'Su': 'Ateş', 'Ateş': 'Metal', 'Metal': 'Ağaç',
    };

    int elementUyum = 55;
    if (elemA == elemB) {
      elementUyum = 80;
      _elementYorum =
          "İkiniz de $elemA elementinin gücünü taşıyorsunuz. Aynı dili konuşur, benzer motivasyonlara sahip olursunuz. Ancak aşırı ortak özellikler bazen durağanlık yaratabilir.";
    } else if (feeds[elemA] == elemB || feeds[elemB] == elemA) {
      elementUyum = 95;
      _elementYorum =
          "$elemA ve $elemB elementleri besleyici bir döngüdedir. Biri diğerini ilhamla, güçle ve sevgiyle besler. Birlikte büyümek ve üretmek sizin için çok doğaldır.";
    } else if (destroys[elemA] == elemB || destroys[elemB] == elemA) {
      elementUyum = 25;
      _elementYorum =
          "$elemA ve $elemB elementleri arasında zıtlık mevcuttur. Bu durum ilişkide söndürücü veya yıpratıcı etkilere yol açabilir. Dengede kalmak için sınırları korumak önemlidir.";
    } else {
      _elementYorum =
          "$elemA ve $elemB elementleri birbirine müdahale etmeyen, kendi akışında olan enerjilerdir. Birbirinizin farklılıklarına saygı duyarak harmoni sağlayabilirsiniz.";
    }

    // Polarite Uyumu
    final polA = _astrologyA!.yinYang;
    final polB = _astrologyB!.yinYang;

    int polariteUyum = 50;
    if (polA != polB) {
      polariteUyum = 90;
      _polariteYorum =
          "Biriniz Yin (🌙 Alıcı/İçsel), diğeriniz Yang (☀️ Etkin/Dışsal) enerjisine sahipsiniz. Bu durum dişil-eril kozmik dengenin en güzel örneğidir; eksik yönlerinizi mükemmel şekilde tamamlarsınız.";
    } else {
      _polariteYorum =
          "İkiniz de $polA enerjisi taşıyorsunuz. Enerjileriniz aynı frekansta titreşir. Ancak dengeyi sağlamak için arada bir sakinleşmeye veya harekete geçmeye ihtiyaç duyabilirsiniz.";
    }

    final double ortalama = (hayvanUyum + elementUyum + polariteUyum) / 3;

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() {
        _toplamSkor = ortalama.round();
        _hayvanSkor = hayvanUyum;
        _elementSkor = elementUyum;
        _polariteSkor = polariteUyum;
        _hesaplandi = true;
        _yukleniyor = false;
      });

      if (_astrologyA != null && _astrologyB != null) {
        try {
          final kullanici = context.read<KullaniciModel>();
          final ks = KehanetService();
          final quota = await ks.getQuotaInfo();
          final interpretation = [_hayvanYorum, _elementYorum, _polariteYorum].join('\n\n');
          await ReadingAutoSave.saveFortune(
            kullanici: kullanici,
            kehanet: ks,
            type: 'compatibility',
            soru:
                '${_astrologyA!.hayvan.adlar.turkce} (${_tarihA!.year}) + '
                '${_astrologyB!.hayvan.adlar.turkce} (${_tarihB!.year})',
            sonuc:
                'Uyum: %${ortalama.round()}\n'
                'Yıldız: %$hayvanUyum · Element: %$elementUyum · Polarite: %$polariteUyum',
            interpretation: interpretation,
            isPremium: quota['premium'] == true,
            useLocalDailyQuota: false,
          );
        } catch (e) {
          debugPrint('Kozmik uyum otomatik kayıt: $e');
        }
      }
    });
  }

  void _showDeepUyumSheet() {
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
                      'İlişki & Uyum Derin Raporu',
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
                'Kozmik haritalarınızın detaylı kesişim analizi. Bu 12 sayfalık kapsamlı aşk ve ortaklık raporu şunları içerir:',
                style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
              ),
              const SizedBox(height: 16),
              _buildBulletItem('Detaylı İletişim & Fikir Uyumu Analizi'),
              _buildBulletItem('Kozmik Engeller & Karşılıklı Sınav Döngüleri'),
              _buildBulletItem('Ortak Ongun ve Koruyucu Enerji Oluşturma Rehberi'),
              _buildBulletItem('Aşk, Evlilik ve Ortaklık İçin En Uğurlu Yıllar'),
              const SizedBox(height: 24),
              GokButton(
                text: 'Uyum Raporunu Al (99 TL)',
                icon: Icons.workspace_premium,
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.bgIndigoLift,
                      title: Text('Rapor Talebiniz Alındı',
                          style: TextStyle(color: AppColors.amber500)),
                      content: Text(
                        'Kozmik ilişki uyum analizi talebiniz başarıyla oluşturulmuştur. Detaylı raporunuz en kısa sürede göklerin rehberliğinde hazırlanarak hesabınıza iletilecektir.',
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

  Color _uyumRengi(int puan) {
    if (puan >= 70) return AppColors.success;
    if (puan >= 45) return AppColors.amber500;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return GokScreenScaffold(
      titleGokturk: '𐰚𐰆𐰔𐰢𐰃𐰚⸱𐰆𐰖𐰆𐰢',
      titleLatin: 'KOZMİK UYUM',
      subtitle: 'İki doğum tarihi seçerek göksel uyumu keşfet',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSelectorsCard(),
          const SizedBox(height: AppSpacing.sectionGap),

          if (_tarihA != null && _tarihB != null && !_hesaplandi)
            GokButton(
              text: 'Kozmik Uyumu Hesapla',
              icon: Icons.favorite,
              isLoading: _yukleniyor,
              onPressed: _yukleniyor ? null : _uyumHesapla,
            ),

          if (_hesaplandi) ...[
            _buildResultsCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildYorumCard('Kozmik Yıldız İlişkisi', Icons.stars, _hayvanYorum),
            const SizedBox(height: AppSpacing.widgetGap),
            _buildYorumCard('Elementlerin Dansı', Icons.wb_sunny, _elementYorum),
            const SizedBox(height: AppSpacing.widgetGap),
            _buildYorumCard('Yin/Yang Dengesi', Icons.balance, _polariteYorum),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPremiumCard(),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorsCard() {
    return GokCard(
      child: Column(
        children: [
          Text(
            'İki doğum tarihi seçerek aranızdaki kadim göksel uyumu hesaplayın.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Row(
            children: [
              Expanded(
                child: _buildTarihSecici(
                  'Siz',
                  _tarihA,
                  _astrologyA,
                  () => _tarihSecA(context),
                ),
              ),
              const SizedBox(width: AppSpacing.widgetGap),
              Icon(Icons.sync_alt, color: AppColors.amber500, size: 22),
              const SizedBox(width: AppSpacing.widgetGap),
              Expanded(
                child: _buildTarihSecici(
                  'Partneriniz',
                  _tarihB,
                  _astrologyB,
                  () => _tarihSecB(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarihSecici(
    String label,
    DateTime? tarih,
    YearAstrology? astro,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.displayXs.copyWith(color: AppColors.amber500),
        ),
        const SizedBox(height: AppSpacing.inlineGap),
        GokButton(
          text: tarih == null
              ? 'Tarih Seç'
              : '${tarih.day}/${tarih.month}/${tarih.year}',
          icon: Icons.calendar_today,
          style: GokButtonStyle.secondary,
          onPressed: onTap,
        ),
        if (astro != null) ...[
          const SizedBox(height: AppSpacing.inlineGap),
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.amber500.withValues(alpha: 0.1),
            backgroundImage: AssetImage(TakvimService.getImagePathForId(astro.hayvan.id)),
          ),
          const SizedBox(height: 6),
          Text(
            astro.hayvan.adlar.turkce,
            style: AppTypography.bodyXs.copyWith(
              color: AppColors.fgPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${astro.element} · ${astro.yinYang}',
            style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildResultsCard() {
    return GokCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _toplamSkor / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.bgCardSoft,
                  valueColor: AlwaysStoppedAnimation(_uyumRengi(_toplamSkor)),
                ),
              ),
              Column(
                children: [
                  Text(
                    '%$_toplamSkor',
                    style: AppTypography.displayXl.copyWith(
                      color: _uyumRengi(_toplamSkor),
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    'Uyum',
                    style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            'Kozmik Portre Karşılaştırması',
            style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          _buildSubScoreBar('Yıldız Uyumu (Hayvan)', _hayvanSkor),
          const SizedBox(height: AppSpacing.inlineGap),
          _buildSubScoreBar('Element Uyumu', _elementSkor),
          const SizedBox(height: AppSpacing.inlineGap),
          _buildSubScoreBar('Polarite Uyumu', _polariteSkor),
        ],
      ),
    );
  }

  Widget _buildSubScoreBar(String label, int score) {
    final barColor = _uyumRengi(score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary)),
            Text(
              '%$score',
              style: AppTypography.bodyXs.copyWith(color: barColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rThumb),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: AppColors.bgCardSoft,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildYorumCard(String baslik, IconData ikon, String yorum) {
    return GokCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: AppColors.amber500, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  baslik,
                  style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          Text(
            yorum,
            style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return GokCard(
      customColor: Colors.black.withValues(alpha: 0.3),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, color: AppColors.amber500, size: 40),
          const SizedBox(height: AppSpacing.widgetGap),
          Text(
            'İlişki & Uyum Derin Raporu',
            style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Gök yazgınızın derinliklerinde saklı ilişki sınavlarınızı, ortak güçlü yönlerinizi ve aşk döngülerinizi içeren 12 sayfalık kişisel kozmik ilişki raporu.',
            style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          GokButton(
            text: 'UYUM RAPORUNU AL',
            icon: Icons.auto_awesome,
            onPressed: _showDeepUyumSheet,
          ),
        ],
      ),
    );
  }
}
