// Bu dosya bir Hive modeli değildir, bu yüzden Hive ile ilgili hiçbir kod içermez.
class TarotKarti {
  final int id;
  final String ad;
  final String duzAnlam;
  final String tersAnlam;
  final String resimYolu;
  final List<String> anahtarKelimeler;

  TarotKarti({
    required this.id,
    required this.ad,
    required this.duzAnlam,
    required this.tersAnlam,
    required this.resimYolu,
    required this.anahtarKelimeler,
  });

  factory TarotKarti.fromJson(Map<String, dynamic> json) {
    return TarotKarti(
      id: json['id'] ?? 0,
      ad: json['name_tr'] ?? 'Bilinmiyor',
      duzAnlam: json['meaning_up'] ?? 'Anlam bulunamadı.',
      tersAnlam: json['meaning_rev'] ?? 'Anlam bulunamadı.',
      resimYolu: json['image'] ?? '',
      anahtarKelimeler: List<String>.from(json['keywords'] ?? []),
    );
  }
}
