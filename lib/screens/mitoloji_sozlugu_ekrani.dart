import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mitoloji_karakteri.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_input.dart';
import '../widgets/core/gok_screen_scaffold.dart';

class MitolojiSozluguEkrani extends StatefulWidget {
  const MitolojiSozluguEkrani({super.key});

  @override
  State<MitolojiSozluguEkrani> createState() => _MitolojiSozluguEkraniState();
}

class _MitolojiSozluguEkraniState extends State<MitolojiSozluguEkrani> {
  List<MitolojiKarakteri> _tumKarakterler = [];
  List<MitolojiKarakteri> _filtrelenmis = [];
  final TextEditingController _aramaController = TextEditingController();
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/mitoloji.json');
      final List<dynamic> liste = json.decode(jsonString);
      final karakterler =
          liste.map((e) => MitolojiKarakteri.fromJson(e)).toList();
      setState(() {
        _tumKarakterler = karakterler;
        _filtrelenmis = karakterler;
        _yukleniyor = false;
      });
    } catch (e) {
      debugPrint('Mitoloji yükleme hatası: $e');
      setState(() => _yukleniyor = false);
    }
  }

  void _ara(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtrelenmis = _tumKarakterler;
      } else {
        final q = query.toLowerCase();
        _filtrelenmis = _tumKarakterler.where((k) {
          return k.ad.toLowerCase().contains(q) ||
              k.unvan.toLowerCase().contains(q) ||
              k.aciklama.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GokScreenScaffold(
      titleGokturk: '𐰢𐰃𐱅𐰆𐰞𐰆𐰖𐰀',
      titleLatin: 'MİTOLOJİ KÜTÜPHANESİ',
      subtitle: 'Türk mitolojisinin kadim varlıkları',
      scrollable: false,
      body: Column(
        children: [
          GokInput(
            controller: _aramaController,
            hintText: 'Karakter ara...',
            onChanged: _ara,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (_yukleniyor)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.amber500),
              ),
            )
          else if (_filtrelenmis.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: AppSpacing.widgetGap,
                  mainAxisSpacing: AppSpacing.widgetGap,
                ),
                itemCount: _filtrelenmis.length,
                itemBuilder: (context, index) =>
                    _buildKart(_filtrelenmis[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKart(MitolojiKarakteri karakter) {
    return GokCard(
      onTap: () => _detayGoster(karakter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.rCard),
              ),
              child: Image.asset(
                karakter.resimYolu,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bgCardSoft,
                  child: Icon(Icons.image, size: 48, color: AppColors.fgDisabled),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    karakter.ad,
                    style: AppTypography.displaySm.copyWith(
                      color: AppColors.amber500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    karakter.unvan,
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.fgSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.fgTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.fgDisabled),
          const SizedBox(height: AppSpacing.widgetGap),
          Text(
            'Karakter bulunamadı',
            style: AppTypography.displaySm.copyWith(
              color: AppColors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _detayGoster(MitolojiKarakteri karakter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KarakterDetayModal(karakter: karakter),
    );
  }
}

class _KarakterDetayModal extends StatelessWidget {
  final MitolojiKarakteri karakter;

  const _KarakterDetayModal({required this.karakter});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCosmos,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.rCard * 2),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.fgDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.rCard),
                        child: Image.asset(
                          karakter.resimYolu,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: AppColors.bgCardSoft,
                            child: Icon(Icons.image,
                                size: 64, color: AppColors.fgDisabled),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Text(
                        karakter.ad,
                        style: AppTypography.displayLg.copyWith(
                          color: AppColors.amber500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        karakter.unvan,
                        style: AppTypography.displaySm.copyWith(
                          color: AppColors.fgSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Divider(color: AppColors.borderCard),
                      const SizedBox(height: AppSpacing.widgetGap),
                      Row(
                        children: [
                          Icon(Icons.auto_stories,
                              color: AppColors.amber500, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Hikaye',
                            style: AppTypography.displaySm.copyWith(
                              color: AppColors.fgPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.inlineGap),
                      Text(
                        karakter.aciklama,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.fgSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgCard,
                          foregroundColor: AppColors.fgPrimary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.rCard),
                            side:
                                BorderSide(color: AppColors.borderCard),
                          ),
                        ),
                        child: const Text('Kapat'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
