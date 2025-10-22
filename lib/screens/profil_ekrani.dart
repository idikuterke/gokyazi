import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kullanici_model.dart';
import '../models/kayitli_irk_bitig.dart';
import '../models/kayitli_tarot.dart';
import '../models/tarot_karti.dart'; // YENİ: Kart anlamlarını göstermek için
import '../services/tarot_service.dart'; // YENİ: Tarot destesini yüklemek için
import '../widgets/seviye_ilerleme_gostergesi.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  // Tarot kartlarının anlamlarını gösterebilmek için tüm desteyi yüklüyoruz.
  late Future<void> _initTarotDeck;

  @override
  void initState() {
    super.initState();
    // Ekran açılırken TarotService'i bir kere çalıştırıp desteyi hazır hale getiriyoruz.
    _initTarotDeck = TarotService.getCardByName('');
  }

  @override
  Widget build(BuildContext context) {
    final kullanici = context.watch<KullaniciModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil & Geçmiş'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/turk_tarot.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfilKarti(context, kullanici),
              const SizedBox(height: 24),
              // YENİ: Detaylı Irk Bitig Geçmişi
              _buildIrkBitigGecmisi(
                kullanici.kayitliIrkBitigFallari.reversed.toList(),
              ),
              const SizedBox(height: 24),
              // YENİ: Detaylı Tarot Geçmişi
              _buildTarotGecmisi(
                kullanici.kayitliTarotFallari.reversed.toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (_buildProfilKarti ve _buildInfoColumn aynı kalabilir)
  Widget _buildProfilKarti(BuildContext context, KullaniciModel kullanici) {
    return Card(
      color: const Color.fromRGBO(20, 18, 38, 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.amber, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kullanici.unvan,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'CinzelDecorative',
                      ),
                    ),
                    Text(
                      'Seviye ${kullanici.seviye}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SeviyeIlerlemeGostergesi(kullanici: kullanici),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Kader Puanı',
                  kullanici.kaderPuani.toString(),
                ),
                _buildInfoColumn(
                  'Bakılan Fal',
                  kullanici.baktigiFalSayisi.toString(),
                ),
                _buildInfoColumn('Günlük Hak', kullanici.falHakki.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // --- YENİ WIDGET'LAR ---

  Widget _buildIrkBitigGecmisi(List<KayitliIrkBitig> fallar) {
    return Card(
      color: const Color.fromRGBO(20, 18, 38, 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: const Text(
          'Irk Bitig Geçmişi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconColor: Colors.amber,
        collapsedIconColor: Colors.white70,
        children: fallar.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Geçmiş fal bulunmuyor.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]
            : fallar.map((fal) => _buildIrkBitigTile(fal)).toList(),
      ),
    );
  }

  Widget _buildIrkBitigTile(KayitliIrkBitig kayit) {
    final formattedDate =
        "${kayit.tarih.day}.${kayit.tarih.month}.${kayit.tarih.year}";
    return ExpansionTile(
      leading: Text(
        kayit.kombinasyon,
        style: const TextStyle(
          color: Colors.amber,
          fontFamily: 'Orkun',
          fontSize: 20,
        ),
      ),
      title: Text(
        kayit.soru,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        formattedDate,
        style: const TextStyle(color: Colors.white70),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailSection(
                "Sorunuza Yanıt:",
                kayit.geminiYorumu,
                isSpecial: true,
              ),
              _buildDetailSection("Modern Yorum:", kayit.fal.yorumModern),
              _buildDetailSection("Kadim Anlam:", kayit.fal.turkce),
              _buildDetailSection(
                "Okunuşu:",
                kayit.fal.transliterasyon,
                isItalic: true,
              ),
              _buildDetailSection(
                "Göktürkçe Metin:",
                kayit.fal.gokturkce,
                isOrkun: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTarotGecmisi(List<KayitliTarot> fallar) {
    return Card(
      color: const Color.fromRGBO(20, 18, 38, 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: const Text(
          'Türk Tarotu Geçmişi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconColor: Colors.amber,
        collapsedIconColor: Colors.white70,
        children: fallar.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Geçmiş fal bulunmuyor.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]
            : fallar.map((fal) => _buildTarotTile(fal)).toList(),
      ),
    );
  }

  Widget _buildTarotTile(KayitliTarot kayit) {
    final formattedDate =
        "${kayit.tarih.day}.${kayit.tarih.month}.${kayit.tarih.year}";
    return ExpansionTile(
      leading: const Icon(Icons.filter_vintage_outlined, color: Colors.amber),
      title: Text(
        kayit.niyet,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        formattedDate,
        style: const TextStyle(color: Colors.white70),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailSection("Niyetiniz:", kayit.niyet),
              _buildDetailSection(
                "Göklerin Yorumu:",
                kayit.yorum,
                isSpecial: true,
              ),
              const SizedBox(height: 10),
              // Tarot kartlarının anlamlarını göstermek için FutureBuilder kullanıyoruz.
              FutureBuilder(
                future: _initTarotDeck,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: kayit.kartDetaylari.map((detay) {
                      final kartAdi = detay['ad'];
                      final tersMi = detay['tersMi'];
                      // TarotService'i doğrudan çağırmak yerine, önceden yüklenmiş desteden arıyoruz.
                      return FutureBuilder<TarotKarti?>(
                        future: TarotService.getCardByName(kartAdi),
                        builder: (context, cardSnapshot) {
                          if (!cardSnapshot.hasData)
                            return const SizedBox.shrink();
                          final kart = cardSnapshot.data!;
                          return _buildDetailSection(
                            "Kart: $kartAdi (${tersMi ? 'Ters' : 'Düz'})",
                            tersMi ? kart.tersAnlam : kart.duzAnlam,
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    String title,
    String? content, {
    bool isSpecial = false,
    bool isItalic = false,
    bool isOrkun = false,
  }) {
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
              color: isSpecial ? Colors.cyan.shade300 : Colors.amber.shade200,
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
