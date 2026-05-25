import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'main_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _entered = false;

  static const _slides = [
    _Slide(
      runic: '𐰋𐰃𐰓𐰢',
      subtitle: 'Kadim Bilgeliğe Hoş Geldin',
      body:
          'Türk mitolojisinin derinliklerinde kehanet, bilgelik ve ruhsal yolculuk seni bekliyor.',
      kind: 'ak_ana',
    ),
    _Slide(
      runic: '𐰃𐰼𐰴',
      subtitle: 'Irk Bitig — Kadim Kehanet Kitabı',
      body:
          'Göktürk runik yazısıyla yazılan 65 kehanetten birini çek. Niyetini belirt, zarları at, kadim bilgeliğin sesini dinle.',
      kind: 'dice',
    ),
    _Slide(
      runic: '𐱃𐰺𐰆𐱃',
      subtitle: 'Türk Tarotu — 22 Kart, 22 Yol',
      body:
          'Kam, Ak Ana, Yer Ana… Türk mitolojisinin kadim varlıkları rehberin olsun. Niyetini belirt, kartlarını çek, yolunu aydınlat.',
      kind: 'tarot',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/tengri.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.35),
                  radius: 1.1,
                  colors: [
                    AppColors.primaryBgGradient[0].withValues(alpha: 0.55),
                    AppColors.primaryBgGradient[1].withValues(alpha: 0.95),
                    AppColors.bgCosmos,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Slides
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              Future.delayed(const Duration(milliseconds: 60), () {
                if (mounted) setState(() => _entered = true);
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              final isActive = index == _currentPage;
              return Padding(
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
                child: Column(
                  children: [
                    // Illustration
                    Expanded(
                      flex: 5,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: isActive && _entered ? 1.0 : 0.0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          scale: isActive && _entered ? 1.0 : 0.92,
                          child: _buildIllustration(slide.kind),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Text block
                    Expanded(
                      flex: 4,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 700),
                        opacity: isActive && _entered ? 1.0 : 0.0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          offset: isActive && _entered
                              ? Offset.zero
                              : const Offset(0, 0.14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slide.runic,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontRunic,
                                  fontSize: index == 0 ? 40 : 34,
                                  color: AppColors.amber500,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.amber500
                                          .withValues(alpha: 0.6),
                                      blurRadius: 22,
                                    ),
                                    const Shadow(
                                        color: Colors.black, blurRadius: 6),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                slide.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontDisplay,
                                  fontWeight: FontWeight.w700,
                                  fontSize: index == 0 ? 21 : 19,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  height: 1.25,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.9),
                                        blurRadius: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                slide.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.65,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shadows: [
                                    Shadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.9),
                                        blurRadius: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip button
          if (!isLast)
            Positioned(
              top: 18,
              right: 18,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _entered ? 1.0 : 0.0,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Atla',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.3,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 36,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: _entered ? 1.0 : 0.0,
              child: Column(
                children: [
                  // Dot indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (k) {
                      final active = k == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.amber500
                              : Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.amber500.withValues(alpha: 0.6),
                                    blurRadius: 14,
                                  )
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  // CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: isLast ? _buildStartButton() : _buildNextButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(String kind) {
    if (kind == 'ak_ana') {
      return Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.amber500.withValues(alpha: 0.22),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/ak_ana.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (kind == 'dice') {
      const pipLabels = ['o', 'oo', 'ooo', 'oooo'];
      const values = [2, 4, 3];
      const rotations = [-6.0, 0.0, 6.0];
      const offsets = [6.0, 0.0, 8.0];
      return Center(
        child: SizedBox(
          width: 240,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Transform.translate(
                    offset: Offset(0, offsets[i]),
                    child: Transform.rotate(
                      angle: rotations[i] * 3.14159 / 180,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xD928201E), Color(0xF20C0A18)],
                          ),
                          border: Border.all(
                            color: AppColors.amber500.withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: AppColors.amber500.withValues(alpha: 0.22),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pipLabels[values[i] - 1],
                            style: const TextStyle(
                              color: Color(0xFFFFD56B),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Runic spark accents
              ...['𐰋', '𐰃', '𐱅'].asMap().entries.map((e) {
                final offX = [16.0, 200.0, 24.0][e.key] - 120;
                final offY = [10.0, 30.0, 150.0][e.key] - 90;
                return Positioned(
                  left: 120 + offX,
                  top: 90 + offY,
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontFamily: AppTypography.fontRunic,
                      fontSize: 22,
                      color: AppColors.amber500.withValues(alpha: 0.55),
                      shadows: [
                        Shadow(
                          color: AppColors.amber500.withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    // tarot
    return Center(
      child: Container(
        width: 160,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.amber500.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            const BoxShadow(
              color: Color(0x8C000000),
              blurRadius: 60,
              offset: Offset(0, 30),
            ),
            BoxShadow(
              color: AppColors.amber500.withValues(alpha: 0.25),
              blurRadius: 28,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-0.21)
              ..rotateX(0.035),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/tarot_arkayuz.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _finish,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor:
              WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE5B225), Color(0xFFC99411)],
            ),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x59D4A017),
                  blurRadius: 24,
                  offset: Offset(0, 8)),
            ],
          ),
          child: const SizedBox.expand(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BAŞLA',
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 3.96,
                    color: Color(0xFF0C0A18),
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: Color(0xFF0C0A18), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _next,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: AppColors.amber500.withValues(alpha: 0.4), width: 1),
          backgroundColor: AppColors.amber500.withValues(alpha: 0.08),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Devam Et',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 1.95,
                color: Color(0xFFFFD56B),
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward,
                color: Color(0xFFFFD56B), size: 16),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String runic;
  final String subtitle;
  final String body;
  final String kind;

  const _Slide({
    required this.runic,
    required this.subtitle,
    required this.body,
    required this.kind,
  });
}
