import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'login_screen.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _contentCtrl;
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _contentOpacity;
  late final Animation<double> _contentScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _bottomOpacity;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _contentOpacity = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    );
    _contentScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 0.18).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _bottomOpacity = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _contentCtrl.forward();
    });

    _navigateBasedOnAuth();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_navigated || !mounted) return;
    _navigated = true;

    final supabase = Supabase.instance.client;

    // Session kontrolü
    final session = supabase.auth.currentSession;
    
    if (session != null && !session.isExpired) {
      // Oturum var, direkt ana ekrana git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      // Oturum yok, login'e git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session != null && !session.isExpired) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: GestureDetector(
        onTap: _navigate,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // tengri.jpeg background
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/tengri.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Radial gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.24),
                    radius: 1.1,
                    colors: [
                      const Color(0x8C2D1B69),
                      const Color(0xF20C0A18),
                      AppColors.bgCosmos,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            // ikon.png watermark
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _iconOpacity,
                builder: (_, child) => Opacity(
                  opacity: _iconOpacity.value,
                  child: child,
                ),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -50),
                    child: Image.asset(
                      'assets/images/ikon.webp',
                      width: 400,
                      height: 400,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Center content
            Center(
              child: FadeTransition(
                opacity: _contentOpacity,
                child: ScaleTransition(
                  scale: _contentScale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '𐰏𐰇𐰚⸱𐰖𐰔𐰃',
                        style: TextStyle(
                          fontFamily: AppTypography.fontRunic,
                          fontSize: 56,
                          height: 1.1,
                          color: AppColors.amber500,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: AppColors.amber500.withValues(alpha: 0.7),
                              blurRadius: 24,
                            ),
                            Shadow(
                              color: AppColors.amber500.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GÖK YAZI',
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: 9.9,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.amber500.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kadim Bilgeliğin Kapısı',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 1.95,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom: shimmer bar + tap hint
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: _bottomOpacity,
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 2,
                        child: AnimatedBuilder(
                          animation: _shimmerCtrl,
                          builder: (_, __) {
                            const sweepWidth = 48.0;
                            const totalTravel = 120.0 + sweepWidth;
                            final offset =
                                _shimmerCtrl.value * totalTravel - sweepWidth;
                            return ClipRect(
                              child: Stack(
                                children: [
                                  Container(
                                    color:
                                        Colors.white.withValues(alpha: 0.08),
                                  ),
                                  Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: SizedBox(
                                      width: sweepWidth,
                                      height: 2,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.amber500,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Devam etmek için dokun',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
