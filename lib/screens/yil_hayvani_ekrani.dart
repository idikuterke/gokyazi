import 'package:flutter/material.dart';
import '../services/takvim_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_screen_scaffold.dart';
import 'hayvan_profili_ekrani.dart';
import 'kozmik_uyum_ekrani.dart';

class YilHayvaniEkrani extends StatefulWidget {
  const YilHayvaniEkrani({super.key});

  @override
  State<YilHayvaniEkrani> createState() => _YilHayvaniEkraniState();
}

class _YilHayvaniEkraniState extends State<YilHayvaniEkrani> {
  DateTime? _secilenTarih;
  bool _isLoading = false;

  static const List<Map<String, String>> _hayvanlar = [
    {'ad': 'Sıçan', 'simge': 'sican', 'yillar': '1996, 2008, 2020'},
    {'ad': 'Öküz', 'simge': 'ud', 'yillar': '1997, 2009, 2021'},
    {'ad': 'Kaplan', 'simge': 'bars', 'yillar': '1998, 2010, 2022'},
    {'ad': 'Tavşan', 'simge': 'tavsan', 'yillar': '1999, 2011, 2023'},
    {'ad': 'Ejderha', 'simge': 'luu', 'yillar': '2000, 2012, 2024'},
    {'ad': 'Yılan', 'simge': 'yilan', 'yillar': '2001, 2013, 2025'},
    {'ad': 'At', 'simge': 'at', 'yillar': '2002, 2014, 2026'},
    {'ad': 'Koyun', 'simge': 'koyun', 'yillar': '2003, 2015, 2027'},
    {'ad': 'Maymun', 'simge': 'bicin', 'yillar': '2004, 2016, 2028'},
    {'ad': 'Horoz', 'simge': 'takagu', 'yillar': '2005, 2017, 2029'},
    {'ad': 'Köpek', 'simge': 'it', 'yillar': '2006, 2018, 2030'},
    {'ad': 'Domuz', 'simge': 'tonguz', 'yillar': '2007, 2019, 2031'},
  ];

  Future<void> _tarihSec() async {
    final secilen = await showDatePicker(
      context: context,
      initialDate: _secilenTarih ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçin',
      builder: (context, child) {
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
      },
    );
    if (secilen != null) {
      setState(() => _secilenTarih = secilen);
    }
  }

  Future<void> _hayvanBul() async {
    if (_secilenTarih == null || !mounted) return;
    setState(() => _isLoading = true);

    final hayvan = await TakvimService.getHayvanForDate(_secilenTarih!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (hayvan != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HayvanProfiliEkrani(
            hayvan: hayvan,
            dogumTarihi: _secilenTarih!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_secilenTarih!.year} yılı için hayvan bilgisi bulunamadı.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _navigateToHayvanProfil(Map<String, String> hayvan) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final firstYear = int.parse(hayvan['yillar']!.split(',').first.trim());
    final tarih = DateTime(firstYear, 6, 1);
    final hayvanModel = await TakvimService.getHayvanForDate(tarih);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (hayvanModel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HayvanProfiliEkrani(
            hayvan: hayvanModel,
            dogumTarihi: tarih,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GokScreenScaffold(
      titleGokturk: '𐰆𐰣⸱𐰃𐰚𐰃⸱𐰴𐰖𐰀𐰣',
      titleLatin: 'YIL HAYVANINIZI KEŞFEDİN',
      subtitle: 'Doğum tarihinizi seçin veya hayvan listesine göz atın',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TARİH SEÇİCİ KART
          GokCard(
            child: Column(
              children: [
                Icon(Icons.calendar_today, color: AppColors.amber500, size: 44),
                const SizedBox(height: AppSpacing.widgetGap),
                Text(
                  'Doğum Tarihi',
                  style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  _secilenTarih == null
                      ? 'İlk adım: Tarihinizi seçin'
                      : '${_secilenTarih!.day}/${_secilenTarih!.month}/${_secilenTarih!.year}',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary),
                ),
                const SizedBox(height: AppSpacing.widgetGap),
                GokButton(
                  text: 'Tarih Seç',
                  icon: Icons.edit_calendar,
                  style: GokButtonStyle.secondary,
                  onPressed: _tarihSec,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.widgetGap),

          // HIZLI ERİŞİM BUTONLARI (tarih seçilince görünür)
          if (_secilenTarih != null) ...[
            Row(
              children: [
                Expanded(
                  child: GokButton(
                    text: 'Hayvanımı Bul',
                    icon: Icons.pets,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _hayvanBul,
                  ),
                ),
                const SizedBox(width: AppSpacing.widgetGap),
                Expanded(
                  child: GokButton(
                    text: 'Uyum Analizi',
                    icon: Icons.favorite,
                    style: GokButtonStyle.secondary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KozmikUyumEkrani(
                            kullaniciTarih: _secilenTarih,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.widgetGap),
          ],

          // HAYVAN LİSTESİ BAŞLIK
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.inlineGap),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.amber500, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '12 Kutlu Hayvan',
                    style: AppTypography.displaySm.copyWith(color: AppColors.fgPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tıklayarak keşfedin',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
                ),
              ],
            ),
          ),

          // HAYVAN GRİDİ (2 SÜTUN)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: AppSpacing.widgetGap,
              mainAxisSpacing: AppSpacing.widgetGap,
            ),
            itemCount: _hayvanlar.length,
            itemBuilder: (context, index) => _buildHayvanKarti(_hayvanlar[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildHayvanKarti(Map<String, String> hayvan) {
    return GokCard(
      onTap: () => _hayvanDetayGoster(hayvan),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCardSoft,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/animal_${hayvan['simge']}.webp',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.pets,
                  color: AppColors.amber500,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hayvan['ad']!,
            style: AppTypography.displayXs.copyWith(color: AppColors.amber500),
          ),
          const SizedBox(height: 4),
          Text(
            hayvan['yillar']!,
            style: AppTypography.bodyXs.copyWith(color: AppColors.fgTertiary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _hayvanDetayGoster(Map<String, String> hayvan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: AppColors.bgCosmos,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.rCard * 2),
          ),
          border: Border.all(color: AppColors.borderCard),
        ),
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.fgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Büyük hayvan görseli
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber500.withValues(alpha: 0.3),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/animal_${hayvan['simge']}.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.pets,
                    size: 60,
                    color: AppColors.amber500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            Text(
              hayvan['ad']!,
              style: AppTypography.displayLg.copyWith(color: AppColors.amber500),
            ),

            const SizedBox(height: 8),

            Text(
              'Doğum Yılları: ${hayvan['yillar']}',
              style: AppTypography.bodyMd.copyWith(color: AppColors.fgSecondary),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: GokButton(
                    text: 'Profili İncele',
                    icon: Icons.auto_stories,
                    isLoading: _isLoading,
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _navigateToHayvanProfil(hayvan);
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.widgetGap),
                Expanded(
                  child: GokButton(
                    text: 'Kapat',
                    style: GokButtonStyle.secondary,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
