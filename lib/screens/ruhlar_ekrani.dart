import 'package:flutter/material.dart';

// Her bir ruh için basit bir veri modeli oluşturalım
class Ruh {
  final String ad;
  final String unvan;
  final String aciklama;
  final String resimYolu;

  const Ruh({
    required this.ad,
    required this.unvan,
    required this.aciklama,
    required this.resimYolu,
  });
}

class RuhlarEkrani extends StatelessWidget {
  const RuhlarEkrani({super.key});

  // Uygulamamızdaki ruhların listesi
  final List<Ruh> ruhlarListesi = const [
    Ruh(
      ad: "Ülgen Han",
      unvan: "İyilik ve Yaratılış Ruhu",
      aciklama:
          "Gök aleminin efendisi, yaratıcı tanrıdır. İnsanlara bilgiyi, ateşi ve yaşamı bahşeder. İyiliğin, bolluğun ve refahın kaynağı olarak kabul edilir. Altın kanatlı kartalıyla gökyüzünde süzülür.",
      resimYolu: "assets/images/ruh_ulgen.jpg",
    ),
    Ruh(
      ad: "Ak Ana",
      unvan: "Yaşam ve Su Ruhu",
      aciklama:
          "Hayatın başlangıcını simgeleyen, sonsuz sulardan gelen yaratıcı tanrıçadır. Işıktan bir bedeni vardır ve her şeyin başlangıcında Ülgen'e ilham vermiştir. Yaşamın, suyun ve denizin kutsallığını temsil eder.",
      resimYolu: "assets/images/ruh_ak_ana.png",
    ),
    Ruh(
      ad: "Alaz Han",
      unvan: "Ateşin Efendisi",
      aciklama:
          "Türk mitolojisinde ateşin ve ocağın koruyucu ruhudur. Ateşin hem aydınlatıcı ve ısıtıcı, hem de yakıcı ve arındırıcı gücünü temsil eder. Evlerdeki ocağın sönmemesini sağlar ve aileye bereket getirir.",
      resimYolu: "assets/images/ruh_alaz.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Kadim Ruhlar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Arka plan olarak parşömeni kullanalım
            image: AssetImage('assets/images/parşömen.png'),
            fit: BoxFit.cover,
            opacity: 0.5, // Arka planı biraz soluklaştıralım
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
          itemCount: ruhlarListesi.length,
          itemBuilder: (context, index) {
            final ruh = ruhlarListesi[index];
            return _buildRuhKarti(context, ruh);
          },
        ),
      ),
    );
  }

  // Her bir ruh için güzel bir kart oluşturan yardımcı metot
  Widget _buildRuhKarti(BuildContext context, Ruh ruh) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior:
          Clip.antiAlias, // Resmin kartın köşelerinden taşmasını engeller
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            ruh.resimYolu,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ruh.ad,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  ruh.unvan,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                ),
                const Divider(height: 24),
                Text(
                  ruh.aciklama,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
