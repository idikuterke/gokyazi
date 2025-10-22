import 'package:hive/hive.dart';
import 'fal_model.dart';

part 'kayitli_irk_bitig.g.dart';

@HiveType(typeId: 7)
class KayitliIrkBitig extends HiveObject {
  @HiveField(0)
  final String kombinasyon;

  @HiveField(1)
  final DateTime tarih;

  @HiveField(2)
  final Fal fal;

  @HiveField(3)
  final String soru;

  @HiveField(4)
  final String geminiYorumu;

  KayitliIrkBitig({
    required this.kombinasyon,
    required this.tarih,
    required this.fal,
    required this.soru,
    required this.geminiYorumu,
  });
}
