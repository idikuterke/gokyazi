// lib/models/kayitli_fal_model.dart

import 'fal_model.dart'; // Fal modelini tanıması için

class KayitliFal {
  final String kombinasyon;
  final String tarih;
  final Fal fal;
  final String soru;
  final String geminiYorumu;

  KayitliFal({
    required this.kombinasyon,
    required this.tarih,
    required this.fal,
    required this.soru,
    required this.geminiYorumu,
  });

  factory KayitliFal.fromJson(Map<String, dynamic> json) {
    return KayitliFal(
      kombinasyon: json['kombinasyon'] ?? '',
      tarih: json['tarih'] ?? '',
      fal: Fal.fromJson(json['fal'] ?? {}),
      soru: json['soru'] ?? 'Soru kaydedilmemiş.',
      geminiYorumu: json['geminiYorumu'] ?? 'Yorum kaydedilmemiş.',
    );
  }
  Map<String, dynamic> toJson() => {
        'kombinasyon': kombinasyon,
        'tarih': tarih,
        'fal': fal.toJson(),
        'soru': soru,
        'geminiYorumu': geminiYorumu,
      };
}
