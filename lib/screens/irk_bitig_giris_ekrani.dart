import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'fal_ekrani.dart';

class IrkBitigGirisEkrani extends StatefulWidget {
  const IrkBitigGirisEkrani({super.key});

  @override
  State<IrkBitigGirisEkrani> createState() => _IrkBitigGirisEkraniState();
}

class _IrkBitigGirisEkraniState extends State<IrkBitigGirisEkrani>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _autoProgressTimer;
  bool _showHistoricalText = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showHistoricalText = true);
      _slideController.forward();
    });

    _autoProgressTimer = Timer(const Duration(seconds: 10), _goToFalEkrani);
  }

  @override
  void dispose() {
    _autoProgressTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _goToFalEkrani() {
    _autoProgressTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FalEkrani(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: GestureDetector(
        onTap: _goToFalEkrani,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ARKA PLAN
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/acilis_ekrani_bg.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bgCosmos.withValues(alpha: 0.2),
                        AppColors.bgCosmos.withValues(alpha: 0.7),
                        AppColors.bgCosmos.withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // İÇERİK
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ANA BAŞLIK
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          '𐰃𐰺𐰴⸱𐰋𐰃𐱅𐰃𐰏',
                          style: TextStyle(
                            fontFamily: AppTypography.fontRunic,
                            fontSize: 56,
                            color: AppColors.amber500,
                            shadows: [
                              Shadow(
                                color: AppColors.amber500.withValues(alpha: 0.8),
                                blurRadius: 40,
                              ),
                              Shadow(
                                color: AppColors.amber500.withValues(alpha: 0.4),
                                blurRadius: 80,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'IRK BİTİG',
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 28,
                            color: AppColors.fgPrimary,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kadim Kehanet Kitabı',
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.fgSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // TARİHİ METİN KARTI
                  if (_showHistoricalText)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _slideController,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pagePadding,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.space5),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard.withValues(alpha: 0.6),
                            border: Border.all(
                              color: AppColors.amber500.withValues(alpha: 0.3),
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.rCard),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.amber500.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GÖKTÜRKÇE ORİJİNAL
                              Text(
                                '𐰉𐰺𐰽: 𐰖𐰃𐰞: 𐰚𐰃𐰤𐱅𐰃: 𐰖: 𐰋𐰃𐰾: 𐰘𐰃𐰏𐰼𐰢𐰃𐰚𐰀: 𐱃𐰖𐰏𐰇𐰤𐱃𐰣: 𐰢𐰣𐰃𐰽𐱃𐰣𐱃𐰴𐰃: 𐰚𐰃𐰲𐰏: 𐰓𐰃𐱃𐰺: 𐰉𐰆𐰺𐰆𐰀: 𐰍𐰆𐰺𐰆: 𐰾𐰓𐰯: 𐰲𐰢𐰔: 𐰃𐰾𐰃𐰏: 𐰽𐰭𐰆𐰣: 𐰃𐱅𐰀𐰲𐰸: 𐰇𐰲𐰇𐰤: 𐰋𐰃𐱅𐰃𐰓𐰢',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontRunic,
                                  fontSize: 16,
                                  color: AppColors.amber500,
                                  height: 1.8,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.widgetGap),
                              Divider(color: AppColors.borderCard),
                              const SizedBox(height: AppSpacing.widgetGap),
                              // TRANSKRİPSİYON
                              Text(
                                'Bars yıl ekinti ay bes yegirmike taygüntan manıstantakı kiçig dentar burua guru esidip eçimiz isig saŋun itaçuk üçün bitidim',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.fgSecondary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.inlineGap),
                              // TÜRKÇE ÇEVİRİ
                              Text(
                                'Pars yılının, ikinci ayın on beşinde (17 Mart 930) Taygün-tan manastırındaki küçük keşiş, Burua guruyu işitip ağabeyimiz sevgili Sangun İtaçuk için yazdım.',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.fgPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // BUTONLAR
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _goToFalEkrani,
                          icon: const Icon(Icons.skip_next, size: 20),
                          label: Text(
                            'Geç',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.fgTertiary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.fgTertiary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _goToFalEkrani,
                          icon: Text(
                            'İlerle',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.amber500,
                            ),
                          ),
                          label: Icon(
                            Icons.arrow_forward,
                            color: AppColors.amber500,
                            size: 20,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.amber500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.pagePadding),
                ],
              ),
            ),

            // DOKUNMA HİNTİ
            Positioned(
              top: 40,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: AppColors.fgTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Devam etmek için dokun',
                        style: AppTypography.bodyXs.copyWith(
                          color: AppColors.fgTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
