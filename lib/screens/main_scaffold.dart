import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'fallar_gecmisi_ekrani.dart';
import 'kozmik_arinma_ekrani.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/kullanici_model.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      KozmikArinmaEkrani(onHomeRequested: () {
        setState(() {
          _currentIndex = 0;
        });
      }),
      const FallarGecmisiEkrani(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to theme changes to trigger rebuild when isDarkTheme changes
    context.watch<KullaniciModel>();
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GokyaziBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _GokyaziBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GokyaziBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        label: 'Ana Sayfa',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      _NavItem(
        label: 'Ritüel',
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
      ),
      _NavItem(
        label: 'Kehanetler',
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
      ),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 76 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: AppColors.isDarkMode
                ? const Color(0xD90C0A18)
                : AppColors.bgCard,
            border: Border(
              top: BorderSide(
                color: AppColors.isDarkMode
                    ? const Color(0x1FFFD700)
                    : AppColors.borderCard,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: List.generate(items.length, (i) {
                final on = i == currentIndex;
                final item = items[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        if (on)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 32,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xB3FFD700),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                on ? item.activeIcon : item.icon,
                                color: on
                                    ? const Color(0xFFFFD700)
                                    : AppColors.fgTertiary,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: AppTypography.fontDisplay,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  color: on
                                      ? const Color(0xFFFFD700)
                                      : AppColors.fgTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
