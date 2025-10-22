// lib/models/hayvan_model.dart

// Ana Hayvan sınıfı
// lib/models/hayvan_model.dart

class Hayvan {
  final String id;
  final int siraNo;
  final Adlar adlar;
  final YilinGenelEtkisi yilinGenelEtkisi;
  final Kisilik kisilik;
  final String mitolojiVeFolklor;
  final Kozmoloji kozmoloji;
  final List<String> uyumluHayvanlar;
  final List<String> catismaliHayvanlar;
  final String? ongunBitki;
  final List<String> tarihiKisiler;
  final String benYiliMesaj;
  final String? simgeResmi; // YENİ

  Hayvan({
    required this.id,
    required this.siraNo,
    required this.adlar,
    required this.yilinGenelEtkisi,
    required this.kisilik,
    required this.mitolojiVeFolklor,
    required this.kozmoloji,
    required this.uyumluHayvanlar,
    required this.catismaliHayvanlar,
    this.ongunBitki,
    required this.tarihiKisiler,
    required this.benYiliMesaj,
    this.simgeResmi, // YENİ
  });

  factory Hayvan.fromJson(String id, Map<String, dynamic> json) {
    return Hayvan(
      id: id,
      siraNo: json['sira_no'],
      adlar: Adlar.fromJson(json['adlar']),
      yilinGenelEtkisi: YilinGenelEtkisi.fromJson(json['yilin_genel_etkisi']),
      kisilik: Kisilik.fromJson(json['kisilik']),
      mitolojiVeFolklor: json['mitoloji_ve_folklor'],
      kozmoloji: Kozmoloji.fromJson(json['kozmoloji']),
      uyumluHayvanlar: List<String>.from(json['uyumlu_hayvanlar'] ?? []),
      catismaliHayvanlar: List<String>.from(json['catismali_hayvanlar'] ?? []),
      ongunBitki: json['ongun_bitki'],
      tarihiKisiler: List<String>.from(json['tarihi_kisiler'] ?? []),
      benYiliMesaj: json['ben_yili_mesaj'],
      simgeResmi: json['simge_resmi'], // YENİ
    );
  }
}

// ... dosyanın geri kalanı aynı ...}

// İç içe geçmiş JSON objeleri için yardımcı sınıflar (Artık Hayvan sınıfının DIŞINDA)
class Adlar {
  final String turkce;
  final String? eskiTurkce;
  final List<String> alternatifler;

  Adlar({required this.turkce, this.eskiTurkce, required this.alternatifler});

  factory Adlar.fromJson(Map<String, dynamic> json) {
    return Adlar(
      turkce: json['turkce'],
      eskiTurkce: json['eski_turkce'],
      alternatifler: List<String>.from(json['alternatifler'] ?? []),
    );
  }
}

class YilinGenelEtkisi {
  final String tema;
  final String aciklama;
  final List<String> anahtarKelimeler;

  YilinGenelEtkisi(
      {required this.tema,
      required this.aciklama,
      required this.anahtarKelimeler});

  factory YilinGenelEtkisi.fromJson(Map<String, dynamic> json) {
    return YilinGenelEtkisi(
      tema: json['tema'],
      aciklama: json['aciklama'],
      anahtarKelimeler: List<String>.from(json['anahtar_kelimeler'] ?? []),
    );
  }
}

class Kisilik {
  final String ozet;
  final String detay;
  final List<String> gucluYonler;
  final List<String> zayifYonler;

  Kisilik(
      {required this.ozet,
      required this.detay,
      required this.gucluYonler,
      required this.zayifYonler});

  factory Kisilik.fromJson(Map<String, dynamic> json) {
    return Kisilik(
      ozet: json['ozet'],
      detay: json['detay'],
      gucluYonler: List<String>.from(json['guclu_yonler'] ?? []),
      zayifYonler: List<String>.from(json['zayif_yonler'] ?? []),
    );
  }
}

class Kozmoloji {
  final String element;
  final String yon;
  final String renk;
  final String yinYang;

  Kozmoloji(
      {required this.element,
      required this.yon,
      required this.renk,
      required this.yinYang});

  factory Kozmoloji.fromJson(Map<String, dynamic> json) {
    return Kozmoloji(
      element: json['element'],
      yon: json['yon'],
      renk: json['renk'],
      yinYang: json['yin_yang'],
    );
  }
}
