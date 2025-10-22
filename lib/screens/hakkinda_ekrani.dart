import 'package:flutter/material.dart';

class HakkindaEkrani extends StatelessWidget {
  const HakkindaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Hakkında"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/parşömen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                // DÜZELTİLDİ: withOpacity(0.6) -> withAlpha(153)
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, "Gök Yazı'nın Felsefesi"),
                  const Text(
                    "Gök Yazı, kadim Türk bilgeligini ve kozmolojisini modern teknolojiyle buluşturan bir köprüdür. Amacımız, Irk Bitig'in kehanetlerinden ve 12 Hayvanlı Türk Takvimi'nin derin karakter analizlerinden ilham alarak, kullanıcılarımıza kişisel bir keşif ve farkındalık yolculuğu sunmaktır.",
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "İlham Kaynaklarımız"),
                  const Text(
                    "Bu uygulama, başta 8. yüzyıla ait kehanet kitabı 'Irk Bitig' olmak üzere, Kaşgarlı Mahmud'un 'Dîvânu Lugâti't-Türk' eserindeki kültürel anlatılar ve Türk mitolojisinin zengin mirasından beslenmektedir. Sunduğumuz yorumlar, bu kadim kaynakların modern yaşamla rezonans kurma potansiyelini keşfetme arzusunun bir ürünüdür.",
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Sorumluluk Reddi"),
                  Text(
                    "Gök Yazı, yalnızca eğlence ve kişisel farkındalık amacıyla tasarlanmıştır. Sunulan yorumlar, tarihi ve mitolojik metinlerin sembolik birer yansıması olup, profesyonel bir tavsiye veya geleceğe yönelik kesin bir bilgi olarak kabul edilmemelidir.",
                    // DÜZELTİLDİ: withOpacity(0.7) -> withAlpha(179)
                    style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Başlıklar için standart bir stil oluşturan yardımcı metot
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.amber.shade200,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
