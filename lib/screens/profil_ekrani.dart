import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kullanici_model.dart';
import '../providers/kozmik_provider.dart';
import '../services/auth_service.dart';
import '../services/deep_link_service.dart';
import '../services/kehanet_service.dart';
import '../widgets/seviye_ilerleme_gostergesi.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  late Future<Map<String, dynamic>> _quotaFuture;

  @override
  void initState() {
    super.initState();
    _quotaFuture = KehanetService().getQuotaInfo();
  }

  @override
  Widget build(BuildContext context) {
    final kullanici = Provider.of<KullaniciModel>(context);
    final authService = Provider.of<AuthService>(context);
    final userEmail = authService.currentUser?.email ?? 'Misafir';

    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      body: Stack(
        children: [
          // Background matching HTML design: tarot_arkayuz.png at 0.12 with blur
          Positioned.fill(
            child: Image.asset(
              'assets/images/tarot_arkayuz.webp',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.12),
            ),
          ),
          // Radial gradient overlay (purple-indigo top, cosmos bottom)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.2,
                  colors: [
                    AppColors.violetBgGradient[0],
                    AppColors.bgCosmos.withValues(alpha: 0.95),
                    AppColors.bgCosmos,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.amber500,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: AppSpacing.space5),

                  _buildWelcomeCard(kullanici, userEmail),

                  const SizedBox(height: AppSpacing.space5),

                  _buildAyFaziKarti(context),

                  const SizedBox(height: AppSpacing.space5),

                  _buildGokyuzuIntegration(),

                  const SizedBox(height: AppSpacing.space5),

                  _buildLevelCard(kullanici),

                  const SizedBox(height: AppSpacing.space5),

                  _buildStatsGrid(kullanici),

                  const SizedBox(height: AppSpacing.space3),

                  _buildQuotaCard(),

                  const SizedBox(height: AppSpacing.space5),

                  _buildStreakCard(kullanici),

                  const SizedBox(height: AppSpacing.space5),

                  _buildAchievementsCard(kullanici),

                  const SizedBox(height: AppSpacing.space5),

                  _buildHistorySection(kullanici),

                  const SizedBox(height: AppSpacing.space5),

                  _buildCustomizationCard(),

                  const SizedBox(height: AppSpacing.space5),

                  _buildAccountManagement(authService),

                  const SizedBox(height: AppSpacing.space8),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(KullaniciModel kullanici, String email) {
    final timeOfDay = DateTime.now().hour;
    String greeting = timeOfDay < 12
        ? 'Günaydın'
        : timeOfDay < 18
        ? 'İyi günler'
        : 'İyi akşamlar';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgCard, AppColors.bgIndigoLift],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderAmber, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.amber700, AppColors.amber500],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber500.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(Icons.person, size: 40, color: AppColors.bgCosmos),
          ),

          const SizedBox(width: AppSpacing.space5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${kullanici.unvan}!',
                  style: AppTypography.displaySm.copyWith(
                    color: AppColors.amber200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.fgSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ruhun bugün sana ne fısıldıyor?',
                  style: AppTypography.bodySm.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyFaziKarti(BuildContext context) {
    final kozmikProvider = KozmikProvider();
    final bugun = DateTime.now();
    final ayFazi = kozmikProvider.ayFaziYorum(bugun);
    final illumination = kozmikProvider.getMoonIllumination(bugun);
    
    return GestureDetector(
      onTap: () {
        // Detay modal göster
        _ayFaziDetayGoster(context, ayFazi);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
        decoration: BoxDecoration(
          color: AppColors.bgCardSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.amber500.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // AY İKONU (Büyük)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCardSoft,
              ),
              child: Center(
                child: Text(
                  ayFazi['ikon'] ?? '🌙',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.space3),
            
            // BİLGİLER
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bu Gece',
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.fgTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ayFazi['ad'] ?? '',
                    style: AppTypography.displaySm.copyWith(
                      color: AppColors.amber500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(illumination * 100).toInt()}% Aydınlanma',
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // DETAY OK
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.fgTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _ayFaziDetayGoster(BuildContext context, Map<String, String> ayFazi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.bgCosmos,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.rCard * 1.5),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DRAG HANDLE
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // İKON (Büyük)
            Text(
              ayFazi['ikon'] ?? '🌙',
              style: const TextStyle(fontSize: 80),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.space5),
            
            // AD
            Text(
              ayFazi['ad'] ?? '',
              style: AppTypography.displayLg.copyWith(
                color: AppColors.amber500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.space5),
            
            // YORUM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCardSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.amber500, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kozmik Rehberlik',
                        style: AppTypography.displayXs.copyWith(
                          color: AppColors.fgPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ayFazi['yorum'] ?? '',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.fgSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.space3),
            
            // MİTOLOJİ
            if (ayFazi['mitoloji'] != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cyanSpecial.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories, color: AppColors.cyanSpecial, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Mitoloji',
                          style: AppTypography.displayXs.copyWith(
                            color: AppColors.fgPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ayFazi['mitoloji']!,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.fgSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // KAPAT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgPressWell,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(KullaniciModel kullanici) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.bgCardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amber500.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seviye ${kullanici.seviye}',
                style: AppTypography.displayLg,
              ),
              Text(
                '${kullanici.experience} / ${kullanici.sonrakiSeviyeExperience} XP',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.fgSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SeviyeIlerlemeGostergesi(kullanici: kullanici),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(KullaniciModel kullanici) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${kullanici.kaderPuani}',
            'Kader Puanı',
            Icons.stars,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${kullanici.baktigiFalSayisi}',
            'Fal Sayısı',
            Icons.auto_stories,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${kullanici.falHakki}',
            'Günlük Hak',
            Icons.wb_sunny,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.bgCardSoft,
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayMd.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _quotaFuture,
      builder: (context, snapshot) {
        final isPremium = snapshot.data?['premium'] == true;
        final kalan = snapshot.data?['kalan'] as int? ?? 0;
        final label = snapshot.connectionState == ConnectionState.waiting
            ? '...'
            : isPremium
                ? '∞'
                : '$kalan / 10';

        return _buildStatCard(
          label,
          'AI Yorumu',
          isPremium ? Icons.all_inclusive : Icons.psychology,
          Colors.teal,
        );
      },
    );
  }

  Widget _buildStreakCard(KullaniciModel kullanici) {
    int streakDays = 5; // TODO: Backend'den çek

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700.withValues(alpha: 0.3),
            Colors.red.shade700.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.orange.shade400,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays gün üst üste!',
                  style: AppTypography.displayMd.copyWith(
                    color: Colors.orange.shade200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Günlük falını çekmeye devam et 🔥',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(KullaniciModel kullanici) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: 8,
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      collapsedBackgroundColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
      ),
      leading: Icon(Icons.emoji_events, color: AppColors.amber500, size: 28),
      title: Text(
        'Başarımlar',
        style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
      ),
      subtitle: Text(
        '3 / 10 kilidi açıldı',
        style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildAchievementBadge('İlk Fal', Icons.star, true),
              _buildAchievementBadge('5 Fal', Icons.auto_stories, true),
              _buildAchievementBadge('10 Fal', Icons.menu_book, true),
              _buildAchievementBadge('Tarot Ustası', Icons.style, false),
              _buildAchievementBadge('Mitoloji Bilgini', Icons.history_edu, false),
              _buildAchievementBadge('Yıldırım', Icons.flash_on, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, bool unlocked) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked
                ? AppColors.amber500.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            border: Border.all(
              color: unlocked ? AppColors.amber500 : Colors.grey.shade700,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? AppColors.amber500 : Colors.grey.shade600,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTypography.bodyXs.copyWith(
            color: unlocked ? AppColors.amber500 : AppColors.fgSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHistorySection(KullaniciModel kullanici) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: 8,
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      collapsedBackgroundColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
      ),
      leading: Icon(Icons.history, color: Colors.blue.shade400, size: 28),
      title: Text(
        'Geçmiş Fallar',
        style: AppTypography.displaySm.copyWith(color: Colors.blue.shade300),
      ),
      subtitle: Text(
        '${kullanici.kayitliIrkBitigFallari.length + kullanici.kayitliTarotFallari.length} fal',
        style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Text(
            'Detaylı geçmiş için "Kehanetler" sekmesine gidin.',
            style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationCard() {
    final kullanici = Provider.of<KullaniciModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.notifications_outlined,
              color: AppColors.amber500,
            ),
            title: Text(
              'Bildirimler',
              style: TextStyle(color: AppColors.fgPrimary),
            ),
            trailing: Switch(
              value: true,
              activeThumbColor: AppColors.amber500,
              onChanged: (value) {
                // TODO: Bildirim ayarı kaydet
              },
            ),
          ),
          Divider(color: Colors.grey.shade800, height: 1),
          ListTile(
            leading: Icon(Icons.brightness_6, color: AppColors.amber500),
            title: Text(
              'Açık Tema',
              style: TextStyle(color: AppColors.fgPrimary),
            ),
            subtitle: Text(
              kullanici.isDarkTheme ? 'Şu an: Karanlık' : 'Şu an: Açık',
              style: AppTypography.bodyXs.copyWith(color: AppColors.fgSecondary),
            ),
            trailing: Switch(
              value: !kullanici.isDarkTheme,
              activeThumbColor: AppColors.amber500,
              onChanged: (value) => kullanici.setDarkTheme(!value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagement(AuthService authService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.logout, color: Colors.orange.shade400),
            title: Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.fgPrimary),
            ),
            onTap: () => _confirmSignOut(authService),
          ),
          Divider(color: Colors.grey.shade800, height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red.shade400),
            title: Text(
              'Hesabı Sil',
              style: TextStyle(color: Colors.red.shade300),
            ),
            onTap: () => _confirmDeleteAccount(authService),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgIndigoLift,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Çıkış Yap',
          style: AppTypography.displaySm.copyWith(color: AppColors.amber500),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: AppTypography.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber700,
            ),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgIndigoLift,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hesabı Sil', style: TextStyle(color: Colors.red.shade300)),
        content: Text(
          'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecek.',
          style: AppTypography.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTypography.bodySm.copyWith(color: AppColors.fgSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Supabase'den kullanıcıyı sil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme özelliği yakında eklenecek'),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGokyuzuIntegration() {
    return FutureBuilder<bool>(
      future: DeepLinkService.isGokyuzuInstalled(),
      builder: (context, snapshot) {
        final isInstalled = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.space5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1B4A69).withValues(alpha: 0.8),
                const Color(0xFF0F2D4D).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isInstalled
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.blue.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isInstalled
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.cyan.shade300],
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GöKyüzü Günlüğü',
                          style: AppTypography.displayMd.copyWith(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isInstalled
                                    ? Colors.green.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isInstalled ? 'Bağlı' : 'Bağlı Değil',
                              style: AppTypography.bodySm.copyWith(
                                color: isInstalled
                                    ? Colors.green.shade300
                                    : AppColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                isInstalled
                    ? 'Kehanetlerinizi günlüğünüze kaydedin ve ruhsal yolculuğunuzu takip edin.'
                    : 'Kehanetlerinizi günlüğe kaydetmek için GöKyüzü Günlüğü\'nü indirin.',
                style: AppTypography.bodySm,
              ),

              const SizedBox(height: 16),

              if (isInstalled) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await DeepLinkService.sendToGokyuzuGunlugu(
                        context: context,
                        falTipi: 'test',
                        soru: 'Test bağlantısı',
                        sonuc:
                            'GöKyüzü Günlüğü ile YAZGI bağlantısı test ediliyor.',
                      );
                    },
                    icon: const Icon(Icons.sync, color: Colors.black),
                    label: const Text(
                      'Günlüğümü Aç',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.rCard),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<Map<String, dynamic>>(
                  future: DeepLinkService.getSyncStatus(),
                  builder: (context, snapshot) {
                    final syncData = snapshot.data ?? {'count': 0};

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Senkronize Fallar',
                            style: AppTypography.bodyXs.copyWith(
                              color: AppColors.fgSecondary,
                            ),
                          ),
                          Text(
                            '${syncData['count']} kehanet',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade300,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final playStoreUrl = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.goklabs.gokyuzu_gunlugu',
                      );

                      if (await canLaunchUrl(playStoreUrl)) {
                        await launchUrl(
                          playStoreUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.download, color: Colors.black),
                    label: const Text(
                      'GöKyüzü Günlüğü\'nü İndir',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.rCard),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
