import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'tarot_ekrani.dart';

class TarotGirisEkrani extends StatefulWidget {
  const TarotGirisEkrani({super.key});

  @override
  State<TarotGirisEkrani> createState() => _TarotGirisEkraniState();
}

class _TarotGirisEkraniState extends State<TarotGirisEkrani>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _timer = Timer(const Duration(seconds: 8), _goToTarot);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToTarot() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TarotEkrani(),
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
        onTap: _goToTarot,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ARKA PLAN
            Image.asset(
              'assets/images/turk_tarot_bg.webp',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.bgCosmos,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgCosmos.withValues(alpha: 0.3),
                    AppColors.bgCosmos.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),

            // İÇERİK
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TAROT KARTI GÖRSELİ
                      Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.rCard),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber500.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.rCard),
                          child: Image.asset(
                            'assets/images/tarot_arkayuz.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sectionGap * 2),

                      // GÖKTÜRKÇE
                      Text(
                        '𐱅𐰇𐰼𐰚⸱𐱃𐰺𐰆𐱃𐰆',
                        style: TextStyle(
                          fontFamily: AppTypography.fontRunic,
                          fontSize: 48,
                          color: AppColors.amber500,
                          shadows: [
                            Shadow(
                              color: AppColors.amber500.withValues(alpha: 0.8),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // LATİN
                      Text(
                        'TÜRK TAROTU',
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: 24,
                          color: AppColors.fgPrimary,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.widgetGap),

                      // AÇIKLAMA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          '22 Ulu Arkana kartı, kadim Türk bilgeliğiyle yeniden yorumlandı.',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.fgSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // DOKUNMA HİNTİ
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Devam etmek için ekrana dokun',
                  style: AppTypography.bodyXs.copyWith(
                    color: AppColors.fgTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
