class MitolojiKarakteri {
  final String ad;
  final String unvan;
  final String aciklama;
  final String resimYolu;

  MitolojiKarakteri({
    required this.ad,
    required this.unvan,
    required this.aciklama,
    required this.resimYolu,
  });

  factory MitolojiKarakteri.fromJson(Map<String, dynamic> json) {
    return MitolojiKarakteri(
      ad: json['ad'] ?? 'Bilinmiyor',
      unvan: json['unvan'] ?? 'Unvan Yok',
      aciklama: json['aciklama'] ?? 'Açıklama bulunamadı.',
      resimYolu: json['resimYolu'] ?? '',
    );
  }
}
