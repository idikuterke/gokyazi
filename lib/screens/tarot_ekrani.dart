// tarot_ekrani.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/kullanici_model.dart';
import '../models/tarot_karti.dart';
import '../models/kayitli_tarot.dart';
import '../services/gemini_service.dart';

enum TarotAsamasi { acilimSec, niyetGir, kartlariCek, yorumGoster }

enum TarotAcilimi { tekKart, ucKart }

class TarotEkrani extends StatefulWidget {
  const TarotEkrani({super.key});

  @override
  State<TarotEkrani> createState() => _TarotEkraniState();
}

class _TarotEkraniState extends State<TarotEkrani>
    with TickerProviderStateMixin {
  late Future<List<TarotKarti>> _deste;
  List<TarotKarti> _secilenKartlar = [];
  Map<int, bool> _kartlarTersMi = {};
  Map<int, bool> _kartlarAcikMi = {};

  TarotAsamasi _asama = TarotAsamasi.acilimSec;
  TarotAcilimi? _seciliAcilim;
  String? _geminiYorumu;
  bool _yorumYukleniyor = false;
  bool _aciklamaGoster = false;

  final TextEditingController _niyetController = TextEditingController();
  // DEĞİŞTİ: GeminiService'i nullable yaptık ve başlangıçta oluşturmuyoruz.
  GeminiService? _geminiService;

  @override
  void initState() {
    super.initState();
    _deste = _loadKartlar();
  }

  @override
  void dispose() {
    _niyetController.dispose();
    super.dispose();
  }

  Future<List<TarotKarti>> _loadKartlar() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/turk_tarotu.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => TarotKarti.fromJson(json)).toList();
  }

  void _kartCek(List<TarotKarti> deste) {
    if (deste.isEmpty || _seciliAcilim == null) return;
    final random = Random();
    final desteKopyasi = List<TarotKarti>.from(deste);
    desteKopyasi.shuffle(random);

    int kartSayisi = _seciliAcilim == TarotAcilimi.tekKart ? 1 : 3;

    setState(() {
      _asama = TarotAsamasi.kartlariCek;
      _secilenKartlar = desteKopyasi.take(kartSayisi).toList();
      _kartlarTersMi = {
        for (var i = 0; i < kartSayisi; i++) i: random.nextBool(),
      };
      _kartlarAcikMi = {for (var i = 0; i < kartSayisi; i++) i: false};
    });
  }

  void _kartiAc(int index) {
    setState(() {
      _kartlarAcikMi[index] = true;
      // YENİ: Tüm kartlar açıldıysa, yorumu otomatik olarak al.
      if (!_kartlarAcikMi.containsValue(false)) {
        _asama = TarotAsamasi.yorumGoster;
        _aciklamaGoster = true;
        _yorumuAl(); // Otomatik API çağrısı
      }
    });
  }

  Future<void> _yorumuAl() async {
    // Yorum zaten alınıyorsa veya alınmışsa tekrar tetikleme
    if (_yorumYukleniyor || _geminiYorumu != null) return;

    setState(() => _yorumYukleniyor = true);
    String? yorum;
    try {
      final kullanici = context.read<KullaniciModel>();
      final apiKey = await kullanici.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Anahtarı bulunamadı.");
      }

      // YENİ: GeminiService'i burada, API anahtarıyla birlikte "ihtiyaç anında" oluşturuyoruz.
      _geminiService ??= GeminiService(apiKey: apiKey);

      // DEĞİŞTİ: Metot çağrısından apiKey parametresini kaldırdık.
      yorum = await _geminiService!.getTarotYorumu(
        niyet: _niyetController.text,
        secilenKartlar: _secilenKartlar,
        kartlarTersMi: _kartlarTersMi,
      );

      final kartDetaylari = _secilenKartlar.asMap().entries.map((entry) {
        return {
          'ad': entry.value.ad,
          'tersMi': _kartlarTersMi[entry.key] ?? false,
        };
      }).toList();

      final yeniKayit = KayitliTarot(
        tarih: DateTime.now(),
        niyet: _niyetController.text,
        kartDetaylari: kartDetaylari,
        yorum: yorum,
      );

      await kullanici.kayitliTarotFaliEkle(yeniKayit);
      await kullanici.addExperience(25);
    } catch (e) {
      yorum = "Bir hata oluştu: ${e.toString()}";
      debugPrint("Tarot yorum hatası: $e");
    }

    if (mounted) {
      setState(() {
        _geminiYorumu = yorum;
        _yorumYukleniyor = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _secilenKartlar = [];
      _kartlarTersMi = {};
      _kartlarAcikMi = {};
      _asama = TarotAsamasi.acilimSec;
      _seciliAcilim = null;
      _geminiYorumu = null;
      _niyetController.clear();
      _aciklamaGoster = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... UI kodunun geri kalanı aynı, herhangi bir değişiklik yok ...
    // build, _buildCurrentStage, _buildAcilimSecimEkrani, _buildNiyetEkrani,
    // _buildFalEkrani, _buildYorumAlani, _buildKartAnlami metodları birebir aynı kalacak.
    // Sadece _buildGeminiYorumu widget'ını güncelleyeceğiz.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Türk Tarotu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/scrool_buton.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color.fromRGBO(0, 0, 0, 0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: FutureBuilder<List<TarotKarti>>(
          future: _deste,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Kartlar yüklenemedi: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Kart destesi boş.'));
            }

            final deste = snapshot.data!;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStage(deste),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStage(List<TarotKarti> deste) {
    switch (_asama) {
      case TarotAsamasi.acilimSec:
        return _buildAcilimSecimEkrani();
      case TarotAsamasi.niyetGir:
        return _buildNiyetEkrani(deste);
      case TarotAsamasi.kartlariCek:
      case TarotAsamasi.yorumGoster:
        return _buildFalEkrani();
    }
  }

  Widget _buildAcilimSecimEkrani() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Kaderini aydınlatmak için\nbir açılım seç.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() {
              _seciliAcilim = TarotAcilimi.tekKart;
              _asama = TarotAsamasi.niyetGir;
            }),
            style: _buttonStyle(),
            child: const Text('Tek Kart Açılımı'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {
              _seciliAcilim = TarotAcilimi.ucKart;
              _asama = TarotAsamasi.niyetGir;
            }),
            style: _buttonStyle(),
            child: const Text('Üç Kart Açılımı'),
          ),
        ],
      ),
    );
  }

  Widget _buildNiyetEkrani(List<TarotKarti> deste) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Yorumunu netleştirmek için\nbir niyet belirt veya soru sor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _niyetController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Niyetiniz...',
              labelStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _kartCek(deste),
            style: _buttonStyle(),
            child: const Text('Kartları Çek'),
          ),
        ],
      ),
    );
  }

  Widget _buildFalEkrani() {
    return Column(
      children: [
        const Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(_secilenKartlar.length, (index) {
              return _FlippableCard(
                isFlipped: _kartlarAcikMi[index]!,
                isReversed: _kartlarTersMi[index]!,
                kart: _secilenKartlar[index],
                onTap: () => _kartiAc(index),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildYorumAlani(),
          ),
        ),
        if (_asama == TarotAsamasi.kartlariCek)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Kartların sırrını çözmek için üzerlerine dokun.',
              style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
            ),
          ),
        if (_asama == TarotAsamasi.yorumGoster)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _reset,
              style: _buttonStyle(),
              child: const Text('Yeniden Bak'),
            ),
          ),
      ],
    );
  }

  Widget _buildYorumAlani() {
    if (!_aciklamaGoster) return const SizedBox.shrink();

    return Column(
      children: [
        ...List.generate(_secilenKartlar.length, (index) {
          final kart = _secilenKartlar[index];
          final tersMi = _kartlarTersMi[index]!;
          return _buildKartAnlami(kart, tersMi, index);
        }),
        const SizedBox(height: 30),
        _buildGeminiYorumu(),
      ],
    );
  }

  Widget _buildKartAnlami(TarotKarti kart, bool tersMi, int index) {
    String baslik = kart.ad;
    if (_secilenKartlar.length > 1) {
      if (index == 0) baslik = "Geçmiş: $baslik";
      if (index == 1) baslik = "Şimdi: $baslik";
      if (index == 2) baslik = "Gelecek: $baslik";
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Text(
            '$baslik ${tersMi ? "(Ters)" : "(Düz)"}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tersMi ? kart.tersAnlam : kart.duzAnlam,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // DEĞİŞTİ: "Yorum Al" butonu kaldırıldı, doğrudan yüklenme durumu gösteriliyor.
  Widget _buildGeminiYorumu() {
    if (_yorumYukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_geminiYorumu != null) {
      return Column(
        children: [
          const Text(
            'Göklerin Yorumu',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _geminiYorumu!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      );
    }
    // Yorum henüz alınmadıysa veya hata oluştuysa boş bir alan döner.
    // _yorumuAl fonksiyonu otomatik tetiklendiği için butona gerek kalmadı.
    return const SizedBox.shrink();
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[700],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      textStyle: const TextStyle(fontSize: 18, fontFamily: 'CinzelDecorative'),
    );
  }
}

// _FlippableCard widget'ı aynı kalacak, değişiklik yok.
class _FlippableCard extends StatelessWidget {
  final bool isFlipped;
  final bool isReversed;
  final TarotKarti kart;
  final VoidCallback onTap;

  const _FlippableCard({
    required this.isFlipped,
    required this.isReversed,
    required this.kart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.of(context).size.height * 0.35;

    return GestureDetector(
      onTap: isFlipped ? null : onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(isFlipped) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder
                  ? min(rotateAnim.value, pi / 2)
                  : rotateAnim.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: isFlipped
            ? Transform.rotate(
                key: const ValueKey(true),
                angle: isReversed ? pi : 0,
                child: Image.asset(kart.resimYolu, height: cardHeight),
              )
            : Image.asset(
                key: const ValueKey(false),
                'assets/images/tarot_arkayuz.png',
                height: cardHeight,
              ),
      ),
    );
  }
}
