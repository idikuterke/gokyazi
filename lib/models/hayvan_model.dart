// lib/models/hayvan_model.dart

class Hayvan {
  final String id;
  final int siraNo;
  final Adlar adlar;
  final YilinGenelEtkisi yilinGenelEtkisi;
  final Kisilik kisilik;
  final String mitolojiVeFolklor;
  final Kozmoloji kozmoloji;
  final String temelYinYang;
  final String mevsim;
  final List<String> anahtarKelimeler;
  final List<String> uyumluHayvanlar;
  final List<String> catismaliHayvanlar;
  final String? ongunBitki;
  final List<String> tarihiKisiler;
  final String benYiliMesaj;
  final String? simgeResmi;

  Hayvan({
    required this.id,
    required this.siraNo,
    required this.adlar,
    required this.yilinGenelEtkisi,
    required this.kisilik,
    required this.mitolojiVeFolklor,
    required this.kozmoloji,
    required this.temelYinYang,
    required this.mevsim,
    required this.anahtarKelimeler,
    required this.uyumluHayvanlar,
    required this.catismaliHayvanlar,
    this.ongunBitki,
    required this.tarihiKisiler,
    required this.benYiliMesaj,
    this.simgeResmi,
  });

  factory Hayvan.fromJson(Map<String, dynamic> json) {
    return Hayvan(
      id: json['id'] ?? '',
      siraNo: json['sira_no'] ?? 0,
      adlar: Adlar.fromJson(json['adlar'] ?? {}),
      yilinGenelEtkisi: YilinGenelEtkisi.fromJson(json['yilin_genel_etkisi'] ?? {}),
      kisilik: Kisilik.fromJson(json['kisilik'] ?? {}),
      mitolojiVeFolklor: json['mitoloji_ve_folklor'] ?? '',
      kozmoloji: Kozmoloji.fromJson(json['kozmoloji'] ?? {}),
      temelYinYang: json['temel_yin_yang'] ?? '',
      mevsim: json['mevsim'] ?? '',
      anahtarKelimeler: List<String>.from(json['anahtar_kelimeler'] ?? []),
      uyumluHayvanlar: List<String>.from(json['uyumlu_hayvanlar'] ?? []),
      catismaliHayvanlar: List<String>.from(json['catismali_hayvanlar'] ?? []),
      ongunBitki: json['ongun_bitki'],
      tarihiKisiler: List<String>.from(json['tarihi_kisiler'] ?? []),
      benYiliMesaj: json['ben_yili_mesaj'] ?? '',
      simgeResmi: json['simge_resmi'],
    );
  }
}

class Adlar {
  final String turkce;
  final String? eskiTurkce;
  final String? gokturkceYazim;
  final List<String> alternatifler;

  Adlar({
    required this.turkce,
    this.eskiTurkce,
    this.gokturkceYazim,
    required this.alternatifler,
  });

  factory Adlar.fromJson(Map<String, dynamic> json) {
    return Adlar(
      turkce: json['turkce'] ?? '',
      eskiTurkce: json['eski_turkce'],
      gokturkceYazim: json['gokturkce_yazim'],
      alternatifler: List<String>.from(json['alternatifler'] ?? []),
    );
  }
}

class YilinGenelEtkisi {
  final String tema;
  final String aciklama;
  final List<String> anahtarKelimeler;

  YilinGenelEtkisi({
    required this.tema,
    required this.aciklama,
    required this.anahtarKelimeler,
  });

  factory YilinGenelEtkisi.fromJson(Map<String, dynamic> json) {
    return YilinGenelEtkisi(
      tema: json['tema'] ?? '',
      aciklama: json['aciklama'] ?? '',
      anahtarKelimeler: List<String>.from(json['anahtar_kelimeler'] ?? []),
    );
  }
}

class Kisilik {
  final String ozet;
  final String detay;
  final List<String> gucluYonler;
  final List<String> zayifYonler;

  Kisilik({
    required this.ozet,
    required this.detay,
    required this.gucluYonler,
    required this.zayifYonler,
  });

  factory Kisilik.fromJson(Map<String, dynamic> json) {
    return Kisilik(
      ozet: json['ozet'] ?? '',
      detay: json['detay'] ?? '',
      gucluYonler: List<String>.from(json['guclu_yonler'] ?? []),
      zayifYonler: List<String>.from(json['zayif_yonler'] ?? []),
    );
  }
}

class Kozmoloji {
  final String? ongunHayvan;

  Kozmoloji({this.ongunHayvan});

  factory Kozmoloji.fromJson(Map<String, dynamic> json) {
    return Kozmoloji(
      ongunHayvan: json['ongun_hayvan'],
    );
  }
}

class ElementMeta {
  final String adTr;
  final String adEski;
  final String aciklama;
  final String yinYangEgilimi;
  final String mevsim;
  final String yon;
  final String renkHex;
  final List<String> anahtar;

  ElementMeta({
    required this.adTr,
    required this.adEski,
    required this.aciklama,
    required this.yinYangEgilimi,
    required this.mevsim,
    required this.yon,
    required this.renkHex,
    required this.anahtar,
  });

  factory ElementMeta.fromJson(Map<String, dynamic> json) {
    return ElementMeta(
      adTr: json['ad_tr'] ?? '',
      adEski: json['ad_eski'] ?? '',
      aciklama: json['aciklama'] ?? '',
      yinYangEgilimi: json['yin_yang_egilimi'] ?? '',
      mevsim: json['mevsim'] ?? '',
      yon: json['yon'] ?? '',
      renkHex: json['renk_hex'] ?? '#FFFFFF',
      anahtar: List<String>.from(json['anahtar'] ?? []),
    );
  }
}

class YinYangMeta {
  final String sembol;
  final String aciklama;
  final String renkHex;

  YinYangMeta({
    required this.sembol,
    required this.aciklama,
    required this.renkHex,
  });

  factory YinYangMeta.fromJson(Map<String, dynamic> json) {
    return YinYangMeta(
      sembol: json['sembol'] ?? '',
      aciklama: json['aciklama'] ?? '',
      renkHex: json['renk_hex'] ?? '#FFFFFF',
    );
  }
}

class YearAstrology {
  final Hayvan hayvan;
  final int dogumYili;
  final String element;
  final ElementMeta elementMeta;
  final String yinYang;
  final YinYangMeta yinYangMeta;

  YearAstrology({
    required this.hayvan,
    required this.dogumYili,
    required this.element,
    required this.elementMeta,
    required this.yinYang,
    required this.yinYangMeta,
  });
}
