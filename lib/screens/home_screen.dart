import 'package:flutter/material.dart';
import './profil_ekrani.dart';
import './dogum_tarihi_giris_ekrani.dart';
import './mitoloji_sozlugu_ekrani.dart';
import './tarot_ekrani.dart';
import './fal_ekrani.dart';
import './ayarlar_ekrani.dart'; // Ayarlar ekranı için import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _AnasayfaBody(),
    );
  }
}

class _AnasayfaBody extends StatelessWidget {
  const _AnasayfaBody();

  @override
  Widget build(BuildContext context) {
    // Menü öğelerini, doğru ikon adları ve uzantıları ile tanımlıyoruz.
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': 'ikon_irk_bitig.png',
        'label': 'IRK BİTİG',
        'page': const FalEkrani(),
      },
      {
        'icon': 'ikon_tarot.png',
        'label': 'TÜRK TAROTU',
        'page': const TarotEkrani(),
      },
      {
        'icon': 'ikon_takvim.png',
        'label': 'TAKVİM',
        'page': const DogumTarihiGirisEkrani(),
      },
      {
        'icon': 'ikon_mitoloji.png',
        'label': 'MİTOLOJİ',
        'page': const MitolojiSozluguEkrani(),
      },
      {
        'icon': 'ikon_profil.png',
        'label': 'PROFİL',
        'page': const ProfilEkrani(),
      },
      // Yeni eklenen Ayarlar butonu (varsayımsal ikon adı, kendi ikonunuzla değiştirebilirsiniz)
      {
        'icon': 'ikon_ayarlar.png',
        'label': 'AYARLAR',
        'page': const AyarlarEkrani(),
      },
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Katman 1: Taş Arka Plan
        Image.asset('assets/images/scrool_buton.jpeg', fit: BoxFit.cover),

        // Katman 2: Butonları içeren Izgara Menüsü
        SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(24.0), // Kenarlardan boşluk
            // Izgara yapısını tanımlıyoruz
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // Ekran yatay olduğunda sütun sayısını artırarak uyum sağlar.
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.portrait
                  ? 2
                  : 3,
              crossAxisSpacing: 20, // Sütunlar arası boşluk
              mainAxisSpacing: 20, // Satırlar arası boşluk
              childAspectRatio: 1.2, // Butonların en/boy oranı
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _RuneButton(
                label: item['label'],
                iconPath: 'assets/images/${item['icon']}',
                page: item['page'],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Yeniden kullanılabilir, efektli Runik Buton Widget'ı
class _RuneButton extends StatefulWidget {
  final String label;
  final String iconPath;
  final Widget page;

  const _RuneButton({
    required this.label,
    required this.iconPath,
    required this.page,
  });

  @override
  State<_RuneButton> createState() => _RuneButtonState();
}

class _RuneButtonState extends State<_RuneButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovering = true),
        onTapUp: (_) {
          setState(() => _isHovering = false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget.page),
          );
        },
        onTapCancel: () => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 255, 255, 0.6),
                      blurRadius: 25.0,
                      spreadRadius: 3.0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconPath,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.white60,
                    size: 60,
                  ); // İkon bulunamazsa gösterilecek yedek ikon
                },
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'CinzelDecorative',
                  fontSize: 16,
                  letterSpacing: 1.5,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
