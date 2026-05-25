import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/kullanici_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  String _appVersion = '—';
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = packageInfo.version);
  }

  Future<void> _sendFeedback() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'gokyazi.destek@email.com',
      query: 'subject=Gök Yazı Uygulaması Geri Bildirimi',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta uygulaması bulunamadı.')),
      );
    }
  }

  Future<void> _clearHistory() async {
    await context.read<KullaniciModel>().tumKayitliFallariTemizle();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tüm fal geçmişi temizlendi.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Geçmişi Temizle',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tüm kayıtlı falları kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: AppColors.fgSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            child: Text('Sil', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<KullaniciModel>();
    final isDark = model.isDarkTheme;
    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: Stack(
        children: [
          // Gradient only — no background image (matches design)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.4,
                  colors: [
                    AppColors.primaryBgGradient[0].withValues(alpha: 0.5),
                    AppColors.primaryBgGradient[1].withValues(alpha: 0.9),
                    AppColors.bgCosmos,
                  ],
                  stops: const [0, 0.6, 1],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  children: [
                    _SettingsGroup(
                      title: 'Görünüm',
                      children: [
                        _SettingsRow(
                          icon: isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          title: isDark ? 'Karanlık Tema' : 'Açık Tema',
                          subtitle: isDark
                              ? 'Cosmos · aktif'
                              : 'Stardust · aktif',
                          right: _Toggle(
                            on: isDark,
                            onChange: () async =>
                                await model.setDarkTheme(!isDark),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Animasyonlar',
                          subtitle: 'Geçiş efektleri ve glow',
                          right: _Toggle(on: true, onChange: () {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SettingsGroup(
                      title: 'Dil',
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mevcut',
                                style: TextStyle(
                                  color: Color(0x8CFFFFFF),
                                  fontSize: 10,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              SizedBox(height: 10),
                              _LangRow(
                                code: 'TR',
                                label: 'Türkçe',
                                active: true,
                              ),
                              _LangRow(
                                code: 'AZ',
                                label: 'Azərbaycanca',
                                active: false,
                              ),
                              _LangRow(
                                code: 'KK',
                                label: 'Қазақша',
                                active: false,
                              ),
                              _LangRow(
                                code: 'UZ',
                                label: "Oʻzbekcha",
                                active: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsGroup(
                      title: 'Ses & His',
                      children: [
                        _SettingsRow(
                          icon: Icons.volume_up_outlined,
                          title: 'Ses Efektleri',
                          subtitle: 'Davul ve geçiş sesleri',
                          right: _Toggle(
                            on: _soundEnabled,
                            onChange: () =>
                                setState(() => _soundEnabled = !_soundEnabled),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.vibration,
                          title: 'Titreşim',
                          subtitle: 'Zar atışında dokunsal',
                          right: _Toggle(
                            on: _hapticEnabled,
                            onChange: () => setState(
                              () => _hapticEnabled = !_hapticEnabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsGroup(
                      title: 'Hakkında',
                      children: [
                        _SettingsRow(
                          icon: Icons.info_outline,
                          title: 'Versiyon',
                          right: Text(
                            _appVersion,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.fgSecondary,
                            ),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.email_outlined,
                          title: 'İletişim',
                          subtitle: 'destek@gokyazi.app',
                          right: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0x66FFFFFF),
                          ),
                          onTap: _sendFeedback,
                        ),
                        const _SettingsRow(
                          icon: Icons.policy_outlined,
                          title: 'Gizlilik Politikası',
                          right: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0x66FFFFFF),
                          ),
                        ),
                        const _SettingsRow(
                          icon: Icons.description_outlined,
                          title: 'Kullanım Şartları',
                          right: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0x66FFFFFF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsGroup(
                      title: 'Veri',
                      children: [
                        _SettingsRow(
                          icon: Icons.delete_sweep_outlined,
                          title: 'Geçmiş Falları Temizle',
                          subtitle: 'Kaydedilen tüm falları siler',
                          danger: true,
                          right: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0x66FFFFFF),
                          ),
                          onTap: _showClearDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        "GÖK YAZI · TENGRİ'NİN SESİ",
                        style: TextStyle(
                          color: Color(0x59FFFFFF),
                          fontSize: 10,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0x0FFFFFFF)
                        : const Color(0x1F000000),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x26FFD700)
                          : const Color(0x4D000000),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : AppColors.fgPrimary,
                    size: 16,
                  ),
                ),
              ),
            ),
            Text(
              'AYARLAR',
              style: TextStyle(
                fontFamily: AppTypography.fontDisplay,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 3.5,
                color: AppColors.fgPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- shared components ----------

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0x80FFFFFF),
              fontSize: 10,
              letterSpacing: 2.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xB20C0A18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x26FFD700), width: 1),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? right;
  final VoidCallback? onTap;
  final bool danger;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.right,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x0AFFFFFF), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: danger
                    ? const Color(0x26F44336)
                    : const Color(0x1FFFC107),
                border: Border.all(
                  color: danger
                      ? const Color(0x59F44336)
                      : const Color(0x4DFFC107),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: danger ? AppColors.danger : AppColors.amber500,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? AppColors.danger : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.fgTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (right != null) right!,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;
  final dynamic onChange;

  const _Toggle({required this.on, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = onChange();
        if (result is Future) {
          await result;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: on ? const Color(0xB3FFC107) : const Color(0x1FFFFFFF),
          border: Border.all(color: const Color(0x26FFFFFF), width: 1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  final String code;
  final String label;
  final bool active;

  const _LangRow({
    required this.code,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active ? const Color(0x1FFFC107) : Colors.transparent,
          border: Border.all(
            color: active ? const Color(0x73FFC107) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0x1FFFC107),
                border: Border.all(color: const Color(0x4DFFC107), width: 1),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    color: AppColors.amber500,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            if (!active)
              const Text(
                'Yakında',
                style: TextStyle(
                  color: Color(0x73FFFFFF),
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              )
            else
              Icon(Icons.check, size: 16, color: AppColors.amber500),
          ],
        ),
      ),
    );
  }
}
