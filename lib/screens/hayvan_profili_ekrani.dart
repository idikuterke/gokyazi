// hayvan_profili_ekrani.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart'; // YENİ: Provider'ı import ediyoruz.
// KALDIRILDI: Artık dotenv kullanmıyoruz.
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/hayvan_model.dart';
import '../models/kullanici_model.dart'; // YENİ: KullaniciModel'i import ediyoruz.
import '../services/takvim_service.dart';
import '../services/gemini_service.dart';

class HayvanProfiliEkrani extends StatefulWidget {
  final Hayvan hayvan;
  final int dogumYili;

  const HayvanProfiliEkrani({
    super.key,
    required this.hayvan,
    required this.dogumYili,
  });

  @override
  State<HayvanProfiliEkrani> createState() => _HayvanProfiliEkraniState();
}

class _HayvanProfiliEkraniState extends State<HayvanProfiliEkrani> {
  String? _yillikYorum;
  bool _yorumYukleniyor = false;
  // YENİ: GeminiService'i nullable olarak state'e ekliyoruz.
  GeminiService? _geminiService;

  // --- DEĞİŞTİ: _yillikYorumAl fonksiyonunu tamamen yeniledik ---
  void _yillikYorumAl() async {
    if (_yorumYukleniyor) return;
    setState(() => _yorumYukleniyor = true);

    final currentYear = DateTime.now().year;
    final cacheKey = 'yillik_yorum_${currentYear}_${widget.dogumYili}';

    try {
      final cacheBox = await Hive.openBox('appCache');
      final cachedYorum = cacheBox.get(cacheKey);

      // 1. Önbelleği kontrol et
      if (cachedYorum != null) {
        if (mounted) {
          setState(() {
            _yillikYorum = cachedYorum as String;
            _yorumYukleniyor = false;
          });
        }
        return;
      }

      // 2. API'den veri çek
      final kullanici = context.read<KullaniciModel>();
      final apiKey = await kullanici.getApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Anahtarı bulunamadı.");
      }

      // GeminiService'i "ihtiyaç anında" oluştur
      _geminiService ??= GeminiService(apiKey: apiKey);

      final userMucel = TakvimService.getMucelDurumu(widget.dogumYili);
      final userAge = currentYear - widget.dogumYili;

      final yorum = await _geminiService!.getYillikYorum(
        userAnimal: widget.hayvan.id,
        currentAnimal: TakvimService.getAnimalIdForYear(currentYear),
        userMucel: userMucel['ad']!,
        userAge: userAge,
      );

      // 3. Başarılıysa önbelleğe kaydet
      await cacheBox.put(cacheKey, yorum);

      if (mounted) {
        setState(() => _yillikYorum = yorum);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _yillikYorum =
              'Yıllık yorum alınamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
        );
      }
      debugPrint('Yorum alma hatası: $e');
    } finally {
      if (mounted) {
        setState(() => _yorumYukleniyor = false);
      }
    }
  }

  void _paylasProfili() {
    final String paylasimMetni =
        "12 Hayvanlı Türk Takvimi'ne göre benim yıl hayvanım: ${widget.hayvan.adlar.turkce}! 🐎\n\n"
        "Öne çıkan özelliğim: '${widget.hayvan.kisilik.ozet}'\n\n"
        "Senin yıl hayvanın ne? Öğrenmek için Gök Yazı uygulamasını indir!";

    Share.share(paylasimMetni);
  }

  @override
  Widget build(BuildContext context) {
    // --- UI kodunda herhangi bir değişiklik yok, hepsi aynı kalıyor ---
    final mucelDurumu = TakvimService.getMucelDurumu(widget.dogumYili);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.hayvan.adlar.turkce} Yılı (${widget.dogumYili})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _paylasProfili,
            tooltip: 'Profili Paylaş',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/genel_arkaplan.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (widget.hayvan.simgeResmi != null &&
                widget.hayvan.simgeResmi!.isNotEmpty)
              Positioned(
                bottom: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/${widget.hayvan.simgeResmi!}',
                    width: 300,
                  ),
                ),
              ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(
                        context,
                        '🐎 ${widget.hayvan.adlar.turkce} Yılında Doğanların Özellikleri',
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '"${widget.hayvan.kisilik.ozet}"',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        context,
                        title: "Kişilik Profili",
                        children: [
                          Text(
                            widget.hayvan.kisilik.detay,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          _buildChipList(
                            "Güçlü Yönleriniz:",
                            widget.hayvan.kisilik.gucluYonler,
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildChipList(
                            "Zayıf Yönleriniz:",
                            widget.hayvan.kisilik.zayifYonler,
                            Colors.orange,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context,
                        title: "Yılın Genel Etkisi",
                        children: [
                          Text(
                            widget.hayvan.yilinGenelEtkisi.aciklama,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          _buildChipList(
                            "Anahtar Kelimeler:",
                            widget.hayvan.yilinGenelEtkisi.anahtarKelimeler,
                            Colors.blue,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context,
                        title: "Kozmolojik Bağlantılar",
                        children: [
                          _buildInfoRow(
                            Icons.public_outlined,
                            "Element:",
                            widget.hayvan.kozmoloji.element,
                          ),
                          _buildInfoRow(
                            Icons.explore_outlined,
                            "Yön:",
                            widget.hayvan.kozmoloji.yon,
                          ),
                          _buildInfoRow(
                            Icons.color_lens_outlined,
                            "Renk:",
                            widget.hayvan.kozmoloji.renk,
                          ),
                          _buildInfoRow(
                            Icons.circle_outlined,
                            "Yin/Yang:",
                            widget.hayvan.kozmoloji.yinYang,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context,
                        title: "Müçel Yaşam Döngünüz",
                        children: [
                          _buildInfoRow(
                            Icons.recycling_outlined,
                            "Dönem:",
                            mucelDurumu['ad']!,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mucelDurumu['aciklama']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      _buildYillikYorumWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYillikYorumWidget() {
    return _yillikYorum == null && !_yorumYukleniyor
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton.icon(
              onPressed: _yillikYorumAl,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Yıllık Yorumu Al'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          )
        : _yorumYukleniyor
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          )
        : _yillikYorum != null
        ? _buildSectionCard(
            context,
            title: "${DateTime.now().year} Yılı Yorumun",
            children: [
              Text(
                _yillikYorum!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [const Shadow(blurRadius: 5, color: Colors.black)],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(height: 24, color: Colors.white30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChipList(String label, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items
              .map(
                (item) => Chip(
                  label: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: color.withAlpha(102),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
