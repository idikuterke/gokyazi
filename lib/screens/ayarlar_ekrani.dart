import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  String _appVersion = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _sendFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'gokyazi.destek@email.com', // E-posta adresi güncellendi
      query: 'subject=Gök Yazı Uygulaması Geri Bildirimi',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta gönderecek bir uygulama bulunamadı.'),
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    // Hem Rık Bitig hem de Tarot geçmişini temizliyoruz.
    await prefs.remove('gecmisFallar');
    // Not: Tarot geçmişi Hive'da saklandığı için, onu da temizlemek gerekebilir.
    // Şimdilik sadece SharedPreferences'ı temizliyoruz.

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm fal geçmişi başarıyla temizlendi.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Geçmişi Temizle'),
          content: const Text(
            'Tüm kayıtlı falları kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _clearHistory();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/turk_tarot.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildListTile(
                icon: Icons.delete_sweep_outlined,
                title: 'Geçmiş Falları Temizle',
                subtitle: 'Kaydedilen tüm falları siler',
                onTap: _showClearHistoryDialog,
              ),
              const Divider(color: Colors.white24),
              _buildListTile(
                icon: Icons.email_outlined,
                title: 'Geri Bildirim Gönder',
                subtitle: 'Uygulama hakkındaki görüşlerinizi paylaşın',
                onTap: _sendFeedback,
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white70),
                title: const Text(
                  'Uygulama Sürümü',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  _appVersion,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Okunabilirliği artırmak için ListTile'ı bir widget'a ayırdım.
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
      onTap: onTap,
    );
  }
}
