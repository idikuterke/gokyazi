import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/kam_transition.dart';
import '../services/auth_service.dart';
import '../models/kullanici_model.dart';
import 'irk_bitig_giris_ekrani.dart';
import 'tarot_giris_ekrani.dart';
import 'takvim_giris_ekrani.dart';
import 'mitoloji_sozlugu_ekrani.dart';
import 'profil_ekrani.dart';
import 'ayarlar_ekrani.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../providers/reading_stats_provider.dart';
import '../widgets/daily_quota_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<MenuCard> _menuCards = const [
    MenuCard(
      title: 'IRK BİTİG',
      subtitle: '65 Kehanet · Göktürk Falı',
      icon: 'assets/images/ikon_irk_bitig.webp',
      background: 'assets/images/bg_fal_ekrani.webp',
      gradient: [Color(0xFF5B21B6), Color(0xFF2D1B69), Color(0xFF0C0A18)],
      accent: Color(0xFFA78BFA),
      route: IrkBitigGirisEkrani(),
    ),
    MenuCard(
      title: 'TÜRK TAROTU',
      subtitle: '22 Kart · Kadim Açılım',
      icon: 'assets/images/ikon_tarot.webp',
      background: 'assets/images/tarot_arkayuz.webp',
      gradient: [Color(0xFF9D174D), Color(0xFF4C1D6E), Color(0xFF0C0A18)],
      accent: Color(0xFFF472B6),
      route: TarotGirisEkrani(),
    ),
    MenuCard(
      title: 'TAKVİM',
      subtitle: '12 Hayvanlı Türk Takvimi',
      icon: 'assets/images/ikon_takvim.webp',
      background: 'assets/images/bg_takvim.webp',
      gradient: [Color(0xFF1E3A8A), Color(0xFF1E1B4B), Color(0xFF0C0A18)],
      accent: Color(0xFF60A5FA),
      route: TakvimGirisEkrani(),
    ),
    MenuCard(
      title: 'MİTOLOJİ',
      subtitle: 'Tanrılar, Ruhlar, Atalar',
      icon: 'assets/images/ikon_mitoloji.webp',
      background: 'assets/images/yolculuk.webp',
      gradient: [Color(0xFF14532D), Color(0xFF6B1D2B), Color(0xFF0C0A18)],
      accent: Color(0xFF86EFAC),
      route: MitolojiSozluguEkrani(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() => _currentPage = next);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to theme changes to trigger rebuild when isDarkTheme changes
    context.watch<KullaniciModel>();
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: _buildAppBar(context),
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: Container(
              key: ValueKey(_currentPage),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_menuCards[_currentPage].background),
                  fit: BoxFit.cover,
                  opacity: 0.45,
                ),
              ),
            ),
          ),

          // Layered gradient overlay matching HTML design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.75, 1.0],
                colors: [
                  AppColors.bgCosmos.withValues(alpha: 0.85),
                  AppColors.bgCosmos.withValues(alpha: 0.55),
                  AppColors.bgCosmos.withValues(alpha: 0.85),
                  AppColors.bgCosmos,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                const Text(
                  '𐰏𐰇𐰚⸱𐰖𐰔𐰃',
                  style: TextStyle(
                    fontFamily: AppTypography.fontRunic,
                    fontSize: 36,
                    color: Color(0xFFFFD700),
                    shadows: [
                      Shadow(
                        color: Color(0x8CFFD700),
                        blurRadius: 22,
                      ),
                      Shadow(
                        color: Color(0xE5000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kadim Bilgeliğin Yolu',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3.5,
                    color: AppColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ReadingStatsNotifier>(
                  builder: (context, stats, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DailyQuotaWidget(compact: true),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgCardSoft,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.rCard,
                            ),
                            border: Border.all(color: AppColors.borderHairline),
                          ),
                          child: Text(
                            'Fal sayısı: ${stats.readingCount}',
                            style: TextStyle(
                              color: AppColors.fgSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                SizedBox(
                  height: 450,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _menuCards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.space7),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _menuCards.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.amber500
                            : AppColors.fgTertiary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == index
                            ? const [
                                BoxShadow(
                                  color: Color(0x99FFD700),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0;
        if (_pageController.hasClients && _pageController.position.haveDimensions) {
          value = index - (_pageController.page ?? 0);
          value = (value * 0.038).clamp(-1.0, 1.0);
        }

        return Center(
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * math.pi / 6),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  KamTransition(page: _menuCards[index].route),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _menuCards[index].gradient,
                  ),
                  border: Border.all(
                    color: index == _currentPage
                        ? const Color(0x99FFD700)
                        : const Color(0x1FFFFFFF),
                    width: index == _currentPage ? 1.5 : 1,
                  ),
                  boxShadow: index == _currentPage
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 60,
                            offset: const Offset(0, 30),
                          ),
                          const BoxShadow(
                            color: Color(0x47FFD700),
                            blurRadius: 36,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Background image
                      Opacity(
                        opacity: 0.28,
                        child: Image.asset(
                          _menuCards[index].background,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Shine overlay
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 0.35, 0.7, 1.0],
                              colors: [
                                Color(0x2EFFFFFF),
                                Colors.transparent,
                                Colors.transparent,
                                Color(0x4D000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top filigree
                      const Positioned(
                        top: 14, left: 14, right: 14, height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x8CFFD700),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom filigree
                      const Positioned(
                        bottom: 14, left: 14, right: 14, height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x8CFFD700),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 22),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // "Kadim Yol" accent label
                              Text(
                                'Kadim Yol',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w600,
                                  color: _menuCards[index].accent,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 12),
                                  ],
                                ),
                              ),
                              // Icon
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(colors: [
                                          _menuCards[index].accent.withValues(alpha: 0.2),
                                          Colors.transparent,
                                        ]),
                                      ),
                                    ),
                                    Container(
                                      width: 118,
                                      height: 118,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withValues(alpha: 0.3),
                                        border: Border.all(
                                          color: AppColors.amber500
                                              .withValues(alpha: 0.4),
                                          width: 3,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            AppSpacing.space5),
                                        child: Image.asset(
                                          _menuCards[index].icon,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Title + subtitle
                              Column(
                                children: [
                                  Text(
                                    _menuCards[index].title,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontDisplay,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.amber200,
                                      letterSpacing: 2,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _menuCards[index].subtitle,
                                    style: AppTypography.bodySm.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      letterSpacing: 0.5,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final email = context.watch<AuthService>().currentUser?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Profile pill button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  KamTransition(page: const ProfilEkrani()),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: const Color(0x26FFD700), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFC99411),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Color(0xFF0C0A18),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PROFİL',
                            style: TextStyle(
                              fontFamily: AppTypography.fontDisplay,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.96,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Settings circular button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  KamTransition(page: const AyarlarEkrani()),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0x26FFD700), width: 1),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xEBFFFFFF),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuCard {
  final String title;
  final String subtitle;
  final String icon;
  final String background;
  final List<Color> gradient;
  final Color accent;
  final Widget route;

  const MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.gradient,
    required this.accent,
    required this.route,
  });
}
