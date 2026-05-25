import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'yil_hayvani_ekrani.dart';

class TakvimGirisEkrani extends StatefulWidget {
  const TakvimGirisEkrani({super.key});

  @override
  State<TakvimGirisEkrani> createState() => _TakvimGirisEkraniState();
}

class _TakvimGirisEkraniState extends State<TakvimGirisEkrani>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;

  static const List<String> _hayvanlar = [
    'sican', 'ud', 'bars', 'tavsan', 'luu',
    'yilan', 'at', 'koyun', 'bicin', 'takagu', 'it', 'tonguz',
  ];

  int _currentIndex = 0;
  Timer? _carouselTimer;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _hayvanlar.length);
      }
    });

    _autoTimer = Timer(const Duration(seconds: 10), _devamEt);
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _autoTimer?.cancel();
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _devamEt() {
    _carouselTimer?.cancel();
    _autoTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const YilHayvaniEkrani(),
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
        onTap: _devamEt,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ARKA PLAN
            Image.asset('assets/images/bg_takvim.webp', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgCosmos.withValues(alpha: 0.3),
                    AppColors.bgCosmos.withValues(alpha: 0.85),
                    AppColors.bgCosmos.withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // İÇERİK
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    // DÖNEN 12 HAYVAN ÇEMBERİ
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, _) {
                        return SizedBox(
                          width: 280,
                          height: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Çember çizgisi
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.amber500
                                        .withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // 12 hayvan simgesi
                              ...List.generate(12, (i) {
                                final baseAngle =
                                    (i * 2 * pi / 12) - pi / 2;
                                final rotatedAngle = baseAngle +
                                    _rotateController.value * 2 * pi;
                                const r = 110.0;
                                final dx = r * cos(rotatedAngle);
                                final dy = r * sin(rotatedAngle);
                                final isActive = i == _currentIndex;

                                return Transform.translate(
                                  offset: Offset(dx, dy),
                                  child: Transform.rotate(
                                    angle:
                                        -_rotateController.value * 2 * pi,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                          milliseconds: 400),
                                      opacity: isActive ? 1.0 : 0.3,
                                      child: Image.asset(
                                        'assets/images/animal_${_hayvanlar[i]}.webp',
                                        width: isActive ? 44 : 36,
                                        height: isActive ? 44 : 36,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.pets,
                                          color: AppColors.amber500,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // MERKEZ HAYVAN (büyük)
                              AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 400),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                        opacity: anim, child: child),
                                child: Image.asset(
                                  'assets/images/${_hayvanlar[_currentIndex]}.webp',
                                  key: ValueKey(_currentIndex),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: AppColors.amber500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sectionGap),

                    // GÖKTÜRKÇE BAŞLIK
                    Text(
                      '𐰆𐰣⸱𐰃𐰚𐰃⸱𐰴𐰖𐰀𐰣⸱𐱃𐰴𐰉𐰢',
                      style: TextStyle(
                        fontFamily: AppTypography.fontRunic,
                        fontSize: 40,
                        color: AppColors.amber500,
                        shadows: [
                          Shadow(
                            color: AppColors.amber500.withValues(alpha: 0.7),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'ON İKİ HAYVAN TAKVİMİ',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 20,
                        color: AppColors.fgPrimary,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.widgetGap),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: Text(
                        'Doğum yılın, kader yolculuğunda senin rehberin...',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.fgSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                      ],
                    ),
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
