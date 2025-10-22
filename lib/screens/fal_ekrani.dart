// fal_ekrani.dart

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
// KALDIRILDI: Artık dotenv kullanmıyoruz.
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/fal_model.dart';
import '../models/kayitli_irk_bitig.dart';
import '../services/gemini_service.dart';
import '../widgets/fal_detay_widget.dart';
import '../widgets/zar_widget.dart';
import '../models/kullanici_model.dart';

enum GosterimTuru {
  gokturkce,
  transliterasyon,
  turkce,
  modernYorum,
  geminiYorumu,
}

class FalEkrani extends StatefulWidget {
  const FalEkrani({super.key});
  @override
  State<FalEkrani> createState() => _FalEkraniState();
}

class _FalEkraniState extends State<FalEkrani> {
  Fal? gosterilenFal;
  String? geminiYorumu;
  bool isProcessRunning = false;
  List<int> zarSonuclari = [];
  final TextEditingController _soruController = TextEditingController();

  GosterimTuru _aktifGosterim = GosterimTuru.gokturkce;
  String _aktifMetin = "";
  String _aktifBaslik = "";

  // YENİ: GeminiService'i nullable olarak state'e ekliyoruz.
  GeminiService? _geminiService;

  final List<String> _ritualMessages = [
    'Niyetine ve soruna odaklan...',
    'Ata ruhları seni dinliyor...',
    'Irk Bitig yol gösterecek...',
  ];
  String? _displayedMessage;

  @override
  void dispose() {
    _soruController.dispose();
    super.dispose();
  }

  void _paylasFali() {
    if (gosterilenFal == null) return;
    final String soru = _soruController.text.isEmpty
        ? 'Bir soru sormadan'
        : _soruController.text;
    final String yorum = geminiYorumu ?? gosterilenFal!.yorumModern;
    final String paylasimMetni =
        "Gök Yazı uygulamasıyla sorduğum soruya gelen yanıt:\n\n"
        "Sorum: '$soru'\n\n"
        "Yorum: '$yorum'\n\n"
        "Sen de kadim Türk bilgeliğiyle yolunu aydınlatmak için Gök Yazı'yı indir!";
    Share.share(paylasimMetni);
  }

  void _resetForNewFortune() {
    setState(() {
      gosterilenFal = null;
      geminiYorumu = null;
      zarSonuclari = [];
      _soruController.clear();
      _aktifMetin = "";
      _aktifBaslik = "";
      _displayedMessage = null;
    });
  }

  Future<void> _faliKaydet(
    Fal fal,
    String kombinasyon,
    String soru,
    String geminiYorumu,
  ) async {
    final yeniKayit = KayitliIrkBitig(
      kombinasyon: kombinasyon,
      tarih: DateTime.now(),
      fal: fal,
      soru: soru,
      geminiYorumu: geminiYorumu,
    );
    // 'context' kullanım hatasını önlemek için mounted kontrolü ekleyebiliriz.
    if (mounted) {
      await context.read<KullaniciModel>().kayitliIrkBitigFaliEkle(yeniKayit);
    }
  }

  // --- DEĞİŞTİ: _yorumuAlVeKaydet fonksiyonunu tamamen yeniledik ---
  Future<void> _yorumuAlVeKaydet(Fal bulunanFal, String kombinasyonKey) async {
    try {
      final kullanici = context.read<KullaniciModel>();
      // API anahtarını artık KullaniciModel'den alıyoruz.
      final apiKey = await kullanici.getApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Anahtarı bulunamadı.");
      }

      // GeminiService'i "ihtiyaç anında" (lazy) oluşturuyoruz.
      _geminiService ??= GeminiService(apiKey: apiKey);

      final String gelenYorum = await _geminiService!.getGeminiInterpretation(
        fal: bulunanFal,
        soru: _soruController.text,
      );

      if (mounted) {
        setState(() {
          geminiYorumu = gelenYorum;
          if (_aktifGosterim == GosterimTuru.geminiYorumu) {
            _aktifMetin = gelenYorum;
          }
        });
      }

      await _faliKaydet(
        bulunanFal,
        kombinasyonKey,
        _soruController.text,
        gelenYorum,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          // YENİ: Kullanıcı dostu hata mesajı
          geminiYorumu =
              "Yorum alınırken bir sorun oluştu. Lütfen internet bağlantınızı kontrol edin.";
          if (_aktifGosterim == GosterimTuru.geminiYorumu) {
            _aktifMetin = geminiYorumu!;
          }
        });
      }
      debugPrint('Gemini Yorum Alma Hatası: $e');
    }
  }

  void _gosterimMetniniGuncelle(GosterimTuru tur) {
    if (gosterilenFal == null) return;
    if (tur == GosterimTuru.geminiYorumu && geminiYorumu == null) {
      setState(() {
        _aktifGosterim = tur;
        _aktifBaslik = "Sorunuza Yanıtı";
        _aktifMetin = "✨ Göklerin bilgeliği sorunu yorumluyor...";
      });
      return;
    }
    setState(() {
      _aktifGosterim = tur;
      switch (tur) {
        case GosterimTuru.gokturkce:
          _aktifBaslik = "Kadim Metin";
          _aktifMetin = gosterilenFal!.gokturkce;
          break;
        case GosterimTuru.transliterasyon:
          _aktifBaslik = "Okunuşu";
          _aktifMetin = gosterilenFal!.transliterasyon;
          break;
        case GosterimTuru.turkce:
          _aktifBaslik = "Anlamı";
          _aktifMetin = gosterilenFal!.turkce;
          break;
        case GosterimTuru.modernYorum:
          _aktifBaslik = "Modern Yorum";
          _aktifMetin = gosterilenFal!.yorumModern;
          break;
        case GosterimTuru.geminiYorumu:
          _aktifBaslik = "Sorunuza Yanıtı";
          _aktifMetin = geminiYorumu!;
          break;
      }
    });
  }

  Future<void> falCek() async {
    if (isProcessRunning || _soruController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      isProcessRunning = true;
      gosterilenFal = null;
      geminiYorumu = null;
      zarSonuclari = [];
      _aktifMetin = "";
      _aktifBaslik = "";
    });

    try {
      final kullanici = context.read<KullaniciModel>();
      kullanici.falSayisiArttir();
      kullanici.addExperience(15);
    } catch (e) {
      debugPrint('Provider Hatası: $e');
    }

    try {
      for (int i = 0; i < 3; i++) {
        setState(() => _displayedMessage = _ritualMessages[i]);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        setState(() {
          zarSonuclari.add(Random().nextInt(4) + 1);
          _displayedMessage = null;
        });
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String kombinasyonKey = zarSonuclari.join('-');
      final String jsonString = await rootBundle.loadString(
        'assets/fallar.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final falData = data[kombinasyonKey];

      if (falData != null) {
        final Fal bulunanFal = Fal.fromJson(falData);
        if (!mounted) return;
        setState(() {
          gosterilenFal = bulunanFal;
          _gosterimMetniniGuncelle(GosterimTuru.gokturkce);
        });
        await _yorumuAlVeKaydet(bulunanFal, kombinasyonKey);
      } else {
        if (!mounted) return;
        setState(() {
          _aktifMetin =
              "Bu kombinasyon ($kombinasyonKey) için bir fal bulunamadı.";
          _aktifBaslik = "Hata";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aktifMetin = "Beklenmeyen bir hata oluştu: ${e.toString()}";
        _aktifBaslik = "Hata";
      });
      debugPrint('Genel Fal Hatası: $e');
    } finally {
      if (mounted) {
        setState(() => isProcessRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- UI kodunda herhangi bir değişiklik yok, hepsi aynı kalıyor ---
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Irk Bitig"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Ana Sayfa',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (gosterilenFal != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _paylasFali,
              tooltip: 'Falı Paylaş',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fal_ekrani_bg2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (gosterilenFal == null) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isProcessRunning
                        ? Column(
                            key: const ValueKey('loading'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: zarSonuclari.length > index
                                        ? ZarWidget(sayi: zarSonuclari[index])
                                        : const SizedBox(width: 50, height: 50),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              AnimatedOpacity(
                                opacity: _displayedMessage != null ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  _displayedMessage ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : TextField(
                            key: const ValueKey('input'),
                            controller: _soruController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Niyetini veya sorunu buraya yaz...',
                              labelStyle: TextStyle(
                                color: Colors.white.withAlpha(150),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withAlpha(100),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (text) => setState(() {}),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        isProcessRunning || _soruController.text.trim().isEmpty
                        ? null
                        : falCek,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withAlpha(160),
                      disabledBackgroundColor: Colors.black.withAlpha(80),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      minimumSize: const Size(150, 50),
                    ),
                    child: isProcessRunning
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Zarları At',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ZarWidget(sayi: zarSonuclari[0]),
                      ZarWidget(sayi: zarSonuclari[1]),
                      ZarWidget(sayi: zarSonuclari[2]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FalDetayWidget(
                    baslik: _aktifBaslik,
                    metin: _aktifMetin,
                    gokturkceFont: _aktifGosterim == GosterimTuru.gokturkce,
                    onGosterimDegistir: _gosterimMetniniGuncelle,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _resetForNewFortune,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withAlpha(200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Yeni Soru Sor',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
