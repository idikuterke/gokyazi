import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'main_scaffold.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _showPassword = false;
  String? _focusedField; // 'email' | 'password'
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      if (_isSignUp) {
        await authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;

      if (!mounted) return;
      if (onboardingDone) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required String fieldKey,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    final focused = _focusedField == fieldKey;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused
              ? AppColors.amber500.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.amber500.withValues(alpha: 0.08),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.amber500.withValues(alpha: 0.18),
                  blurRadius: 22,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            icon,
            color: focused
                ? AppColors.amber500
                : Colors.white.withValues(alpha: 0.5),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure && !_showPassword,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              validator: validator,
              onTap: () => setState(() => _focusedField = fieldKey),
              onEditingComplete: () => setState(() => _focusedField = null),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) suffix,
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !_isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      resizeToAvoidBottomInset: true,
      body: Stack(
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
          // Radial gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.4),
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
          // ikon.png watermark
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 240,
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/ikon.webp',
                width: 480,
                height: 480,
              ),
            ),
          ),
          // Main form
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Logo area
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: _entered ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        offset: _entered
                            ? Offset.zero
                            : const Offset(0, -0.08),
                        child: Column(
                          children: [
                            Text(
                              '𐰏𐰇𐰚⸱𐰖𐰔𐰃',
                              style: TextStyle(
                                fontFamily: AppTypography.fontRunic,
                                fontSize: 42,
                                height: 1.1,
                                color: AppColors.amber500,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.amber500
                                        .withValues(alpha: 0.7),
                                    blurRadius: 22,
                                  ),
                                  const Shadow(
                                      color: Colors.black,
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'GÖK YAZI',
                              style: TextStyle(
                                fontFamily: AppTypography.fontDisplay,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 5.6,
                                color: AppColors.fgSecondary,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.9),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Glassmorphic card
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
                      opacity: _entered ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        offset: _entered
                            ? Offset.zero
                            : const Offset(0, 0.24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xB30C0A18),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x33FFD700),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x80000000),
                                    blurRadius: 60,
                                    offset: Offset(0, 30),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Tab toggle
                                  _buildTabToggle(),
                                  const SizedBox(height: 20),
                                  // E-posta label
                                  _buildFieldLabel('E-posta'),
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: _emailController,
                                    placeholder: 'sen@gokyazi.app',
                                    fieldKey: 'email',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'E-posta gerekli';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Geçerli bir e-posta girin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Şifre label
                                  _buildFieldLabel('Şifre'),
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: _passwordController,
                                    placeholder: '••••••••',
                                    fieldKey: 'password',
                                    icon: Icons.lock_outline,
                                    obscure: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Şifre gerekli';
                                      }
                                      if (v.length < 6) {
                                        return 'Şifre en az 6 karakter olmalı';
                                      }
                                      return null;
                                    },
                                    suffix: GestureDetector(
                                      onTap: () => setState(
                                          () => _showPassword = !_showPassword),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Icon(
                                          _showPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Şifremi Unuttum
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 0),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Şifremi Unuttum',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor: Colors.white
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Submit button
                                  _buildSubmitButton(canSubmit),
                                  const SizedBox(height: 20),
                                  // "veya" divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            height: 1,
                                            color: Colors.white
                                                .withValues(alpha: 0.08)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          'veya',
                                          style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 2,
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            height: 1,
                                            color: Colors.white
                                                .withValues(alpha: 0.08)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Footer toggle
                                  Center(
                                    child: Text.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white
                                              .withValues(alpha: 0.6),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _isSignUp
                                                ? 'Hesabın var mı? '
                                                : 'Hesabın yok mu? ',
                                          ),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () => setState(() {
                                                _isSignUp = !_isSignUp;
                                                _formKey.currentState?.reset();
                                              }),
                                              child: Text(
                                                _isSignUp
                                                    ? 'Giriş Yap'
                                                    : 'Hesap Oluştur',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFFFD56B),
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Color(0xFFFFD56B),
                                                ),
                                              ),
                                            ),
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
                    ),
                    const SizedBox(height: 24),
                    // Below-card hint
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: _entered ? 1.0 : 0.0,
                      child: Text(
                        'Tengri\'nin gözleri seni izliyor',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.56,
                          color: AppColors.fgTertiary,
                        ),
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
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          _buildTab('Giriş Yap', !_isSignUp),
          _buildTab('Hesap Oluştur', _isSignUp),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _isSignUp = label == 'Hesap Oluştur';
          _formKey.currentState?.reset();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? AppColors.amber500.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
              color: active
                  ? AppColors.amber500
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.56,
        color: Colors.white.withValues(alpha: 0.55),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSubmitButton(bool canSubmit) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: canSubmit
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE5B225), Color(0xFFC99411)],
              )
            : null,
        color: canSubmit ? null : const Color(0x66D4A017),
        boxShadow: canSubmit
            ? const [
                BoxShadow(
                  color: Color(0x59D4A017),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canSubmit ? _submit : null,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFF0C0A18),
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _isSignUp ? 'Hesap Oluştur' : 'Giriş Yap',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.8,
                      color: Color(0xFF0C0A18),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
