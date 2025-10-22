import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kayitli_fal_model.dart';

class FallarGecmisiEkrani extends StatefulWidget {
  const FallarGecmisiEkrani({super.key});

  @override
  State<FallarGecmisiEkrani> createState() => _FallarGecmisiEkraniState();
}

class _FallarGecmisiEkraniState extends State<FallarGecmisiEkrani> {
  List<KayitliFal> _gecmisFallar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gecmisFallariYukle();
  }

  Future<void> _gecmisFallariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> falStringListesi =
        prefs.getStringList('gecmisFallar') ?? [];
    final List<KayitliFal> yuklenenFallar = falStringListesi
        .map((falString) => KayitliFal.fromJson(json.decode(falString)))
        .toList();
    if (mounted) {
      setState(() {
        _gecmisFallar = yuklenenFallar.reversed.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _gecmisiTemizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gecmisFallar');
    setState(() => _gecmisFallar = []);
  }

  Future<void> _tekFaliSil(int index) async {
    final silinenFal = _gecmisFallar.removeAt(index);
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    final List<KayitliFal> kaydedilecekListe = _gecmisFallar.reversed.toList();
    final List<String> falStringListesi =
        kaydedilecekListe.map((fal) => json.encode(fal.toJson())).toList();
    await prefs.setStringList('gecmisFallar', falStringListesi);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${silinenFal.soru}" başlıklı fal silindi.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Geçmiş Fallar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _gecmisFallar.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: const Color(0xFF0c0a18).withAlpha(230),
                        title: const Text('Geçmişi Temizle',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                            'Tüm fal geçmişini silmek istediğinizden emin misiniz?',
                            style: TextStyle(color: Colors.white70)),
                        actions: <Widget>[
                          TextButton(
                              child: const Text('İptal'),
                              onPressed: () => Navigator.of(context).pop()),
                          TextButton(
                            child: const Text('Sil',
                                style: TextStyle(color: Colors.redAccent)),
                            onPressed: () {
                              _gecmisiTemizle();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Tüm Falları Sil',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/gecmis_fallar_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: Column(
                  children: [
                    if (_gecmisFallar.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Bir falı silmek için sola kaydırın.',
                          style: TextStyle(
                              color: Colors.white.withAlpha(179),
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    Expanded(
                      child: _gecmisFallar.isEmpty
                          ? const Center(
                              child: Text('Henüz bakılmış bir fal yok.',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: _gecmisFallar.length,
                              itemBuilder: (context, index) {
                                final kayitliFal = _gecmisFallar[index];
                                final dateTime =
                                    DateTime.tryParse(kayitliFal.tarih) ??
                                        DateTime.now();
                                final formattedDate =
                                    "${dateTime.day}.${dateTime.month}.${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

                                return Dismissible(
                                  key: Key(kayitliFal.tarih +
                                      Random().nextInt(9999).toString()),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    _tekFaliSil(index);
                                  },
                                  background: Container(
                                    color: Colors.red.withAlpha(179),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  child: Card(
                                    color: Colors.black.withAlpha(150),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ExpansionTile(
                                      leading: Text(kayitliFal.kombinasyon,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: 'Orkun')),
                                      title: Text(kayitliFal.soru,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(formattedDate,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      iconColor: Colors.white,
                                      collapsedIconColor: Colors.white70,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(16.0)
                                              .copyWith(top: 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _buildDetailSection(
                                                  "Sorunuza Yanıt:",
                                                  kayitliFal.geminiYorumu,
                                                  isSpecial: true),
                                              _buildDetailSection(
                                                  "Modern Yorum:",
                                                  kayitliFal.fal.yorumModern),
                                              _buildDetailSection(
                                                  "Kadim Anlam:",
                                                  kayitliFal.fal.turkce),
                                              _buildDetailSection(
                                                  "Okunuşu:",
                                                  kayitliFal
                                                      .fal.transliterasyon,
                                                  isItalic: true),
                                              _buildDetailSection(
                                                  "Göktürkçe Metin:",
                                                  kayitliFal.fal.gokturkce,
                                                  isOrkun: true),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String? content,
      {bool isSpecial = false, bool isItalic = false, bool isOrkun = false}) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSpecial ? Colors.blueAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: isItalic ? Colors.white70 : Colors.white,
              fontSize: isOrkun ? 22 : 15,
              height: 1.4,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontFamily: isOrkun ? 'Orkun' : null,
            ),
          ),
        ],
      ),
    );
  }
}
