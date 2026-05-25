import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/tarot_karti.dart';
import '../models/tarot_spread.dart';

class TarotService {
  static List<TarotKarti>? _kartlar;
  static List<TarotSpread>? _spreadler;
  static List<SpecialRule>? _specialRules;
  static Map<String, dynamic>? _aiPrompts;

  // Deck keşi (turk_tarotu_full.json['cards'] veya legacy turk_tarotu.json)
  static Future<List<TarotKarti>> getKartlar() async {
    if (_kartlar != null) return _kartlar!;

    try {
      final response =
          await rootBundle.loadString('assets/data/turk_tarotu_full.json');
      final data = json.decode(response) as Map<String, dynamic>;
      _kartlar = (data['cards'] as List)
          .map((k) => TarotKarti.fromJson(k))
          .toList();
    } catch (e) {
      debugPrint('Hata: $e');
      // Legacy flat-array fallback
      final response =
          await rootBundle.loadString('assets/data/turk_tarotu.json');
      final list = json.decode(response) as List<dynamic>;
      _kartlar = list.map((k) => TarotKarti.fromJson(k)).toList();
    }

    return _kartlar!;
  }

  static Future<List<TarotSpread>> getSpreadler() async {
    if (_spreadler != null) return _spreadler!;

    final response =
        await rootBundle.loadString('assets/data/turk_tarotu_full.json');
    final data = json.decode(response) as Map<String, dynamic>;

    _spreadler = (data['spreads'] as List)
        .map((s) => TarotSpread.fromJson(s))
        .toList();

    return _spreadler!;
  }

  static Future<List<SpecialRule>> getSpecialRules() async {
    if (_specialRules != null) return _specialRules!;

    final response =
        await rootBundle.loadString('assets/data/turk_tarotu_full.json');
    final data = json.decode(response) as Map<String, dynamic>;

    _specialRules = (data['special_rules'] as List)
        .map((r) => SpecialRule.fromJson(r))
        .toList();

    return _specialRules!;
  }

  static Future<Map<String, dynamic>> getAiPrompts() async {
    if (_aiPrompts != null) return _aiPrompts!;

    final response =
        await rootBundle.loadString('assets/data/turk_tarotu_full.json');
    final data = json.decode(response) as Map<String, dynamic>;

    _aiPrompts = data['ai_prompts'] as Map<String, dynamic>;

    return _aiPrompts!;
  }

  static Future<TarotSpread?> getSpreadById(String id) async {
    final list = await getSpreadler();
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> checkSpecialRule({
    required String spreadId,
    required int cardId,
    required int position,
  }) async {
    final rules = await getSpecialRules();

    for (final rule in rules) {
      if (rule.spreadId == spreadId && rule.triggerCardId == cardId) {
        if (rule.triggerPosition == null) return rule.aiDirective;
        if (rule.triggerPosition == position) return rule.aiDirective;
      }
    }

    return null;
  }

  // Eski ad bazlı arama (geriye uyumluluk)
  static Future<TarotKarti?> getCardByName(String name) async {
    final kartlar = await getKartlar();
    try {
      return kartlar.firstWhere((k) => k.ad == name);
    } catch (_) {
      return null;
    }
  }
}
