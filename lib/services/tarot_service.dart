import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/tarot_karti.dart';

class TarotService {
  static Map<String, TarotKarti>? _tarotDestesi;

  static Future<Map<String, TarotKarti>> _loadDeck() async {
    if (_tarotDestesi != null) return _tarotDestesi!;

    final String jsonString = await rootBundle.loadString(
      'assets/data/turk_tarotu.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    _tarotDestesi = {
      for (var kartJson in jsonList)
        kartJson['name_tr']: TarotKarti.fromJson(kartJson),
    };

    return _tarotDestesi!;
  }

  // Kart adına göre kartın tüm bilgilerini getirir.
  static Future<TarotKarti?> getCardByName(String name) async {
    final deck = await _loadDeck();
    return deck[name];
  }
}
