import 'dart:math';
import 'package:flutter/material.dart';
import '../services/takvim_service.dart';
import 'hayvan_profili_ekrani.dart';

class DogumTarihiGirisEkrani extends StatefulWidget {
  const DogumTarihiGirisEkrani({super.key});

  @override
  State<DogumTarihiGirisEkrani> createState() => _DogumTarihiGirisEkraniState();
}

// TickerProviderStateMixin, animasyonları yönetmek için eklendi.
class _DogumTarihiGirisEkraniState extends State<DogumTarihiGirisEkrani>
    with SingleTickerProviderStateMixin {
  DateTime? _secilenTarih;
  bool _isLoading = false;

  // Animasyon için bir kontrolcü eklendi.
  late final AnimationController _controller;

  // Hayvan resimlerinin listesi
  final List<String> _hayvanResimleri = [
    'assets/images/sican.png',
    'assets/images/ud.png',
    'assets/images/bars.png',
    'assets/images/tavsan.png',
    'assets/images/luu.png',
    'assets/images/yilan.png',
    'assets/images/at.png',
    'assets/images/koyun.png',
    'assets/images/bicin.png',
    'assets/images/takagu.png',
    'assets/images/it.png',
    'assets/images/tonguz.png',
  ];

  @override
  void initState() {
    super.initState();
    // Animasyon kontrolcüsü başlatılıyor ve sürekli dönmesi sağlanıyor.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 150), // Bir tam tur 150 saniye sürer.
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // Sayfa kapandığında animasyonu durdur.
    super.dispose();
  }

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _secilenTarih ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçin',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1A2E),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Color(0xFF0C0A18),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null && secilen != _secilenTarih) {
      setState(() {
        _secilenTarih = secilen;
      });
    }
  }

  Future<void> _hayvanBul() async {
    if (_secilenTarih == null || !mounted) return;
    setState(() => _isLoading = true);

    final hayvan = await TakvimService.getHayvanForYear(_secilenTarih!.year);

    if (mounted) {
      setState(() => _isLoading = false);
      if (hayvan != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HayvanProfiliEkrani(
              hayvan: hayvan,
              dogumYili: _secilenTarih!.year,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${_secilenTarih!.year} yılı için hayvan bilgisi bulunamadı.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Yıl Hayvanınızı Keşfedin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          _buildZodiacBackground(), // Arka plan artık bu widget ile oluşturuluyor.
    );
  }

  /// 12 Hayvanlı takvim çarkını içeren animasyonlu arka planı oluşturan widget.
  Widget _buildZodiacBackground() {
    return LayoutBuilder(builder: (context, constraints) {
      final aynaBoyutu = min(constraints.maxWidth, constraints.maxHeight);
      final carkYaricapi =
          aynaBoyutu * 0.35; // Hayvanların çark üzerindeki uzaklığı
      final hayvanBoyutu = aynaBoyutu * 0.15; // Hayvan resimlerinin boyutu

      return Stack(
        fit: StackFit.expand,
        children: [
          // Ana arka plan resmi
          Image.asset(
            'assets/images/takvim_arkaplan.png',
            fit: BoxFit.cover,
          ),

          // Animasyonlu Hayvan Çarkı
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: List.generate(_hayvanResimleri.length, (index) {
                  // Her bir hayvan için dönme açısını hesapla
                  final aci = 2 * pi * (index / _hayvanResimleri.length) +
                      _controller.value * 2 * pi;

                  // Trigonometri ile x ve y pozisyonlarını hesapla
                  final x = carkYaricapi * cos(aci);
                  final y = carkYaricapi * sin(aci);

                  return Positioned(
                    // Pozisyonu ekranın merkezine göre ayarla
                    left: constraints.maxWidth / 2 + x - (hayvanBoyutu / 2),
                    top: constraints.maxHeight / 2 + y - (hayvanBoyutu / 2),
                    child: SizedBox(
                      width: hayvanBoyutu,
                      height: hayvanBoyutu,
                      child: Image.asset(_hayvanResimleri[index]),
                    ),
                  );
                }),
              );
            },
          ),

          // Kullanıcı arayüzü (butonlar, yazılar vb.)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Lütfen doğum tarihinizi seçin',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _secilenTarih == null
                        ? 'Tarih Seç'
                        : '${_secilenTarih!.day}/${_secilenTarih!.month}/${_secilenTarih!.year}',
                  ),
                  onPressed: () => _tarihSec(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      _secilenTarih != null && !_isLoading ? _hayvanBul : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('Hayvanımı Bul'),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
