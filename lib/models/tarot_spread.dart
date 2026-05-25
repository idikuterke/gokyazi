class TarotSpread {
  final String id;
  final String nameTr;
  final String nameGokturk;
  final int cardCount;
  final String difficulty;
  final String description;
  final String? image;
  final List<SpreadPosition> positions;
  final String? specialNote;

  TarotSpread({
    required this.id,
    required this.nameTr,
    required this.nameGokturk,
    required this.cardCount,
    required this.difficulty,
    required this.description,
    this.image,
    required this.positions,
    this.specialNote,
  });

  factory TarotSpread.fromJson(Map<String, dynamic> json) {
    return TarotSpread(
      id: json['id'],
      nameTr: json['name_tr'],
      nameGokturk: json['name_gokturk'],
      cardCount: json['card_count'],
      difficulty: json['difficulty'],
      description: json['description'],
      image: json['image'],
      positions: (json['positions'] as List)
          .map((p) => SpreadPosition.fromJson(p))
          .toList(),
      specialNote: json['special_note'],
    );
  }
}

class SpreadPosition {
  final int index;
  final String nameTr;
  final String nameGokturk;
  final String nameLatin;
  final String meaning;

  SpreadPosition({
    required this.index,
    required this.nameTr,
    required this.nameGokturk,
    required this.nameLatin,
    required this.meaning,
  });

  factory SpreadPosition.fromJson(Map<String, dynamic> json) {
    return SpreadPosition(
      index: json['index'],
      nameTr: json['name_tr'],
      nameGokturk: json['name_gokturk'],
      nameLatin: json['name_latin'],
      meaning: json['meaning'],
    );
  }
}

class SpecialRule {
  final String id;
  final String spreadId;
  final int triggerCardId;
  final String triggerCardName;
  final int? triggerPosition;
  final String aiDirective;

  SpecialRule({
    required this.id,
    required this.spreadId,
    required this.triggerCardId,
    required this.triggerCardName,
    this.triggerPosition,
    required this.aiDirective,
  });

  factory SpecialRule.fromJson(Map<String, dynamic> json) {
    return SpecialRule(
      id: json['id'],
      spreadId: json['spread_id'],
      triggerCardId: json['trigger_card_id'],
      triggerCardName: json['trigger_card_name'],
      triggerPosition: json['trigger_position'],
      aiDirective: json['ai_directive'],
    );
  }
}
