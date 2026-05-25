import 'package:flutter/foundation.dart';

import '../models/kullanici_model.dart';

/// Provider ile kullanılır (`Consumer` / `context.watch`).
/// Riverpod yerine mevcut `provider` paketiyle uyumludur.
class ReadingStatsNotifier extends ChangeNotifier {
  ReadingStatsNotifier(this._kullanici) {
    _kullanici.addListener(_sync);
    _sync();
  }

  final KullaniciModel _kullanici;
  int _readingCount = 0;
  int _savedEntries = 0;

  int get readingCount => _readingCount;
  int get savedEntries => _savedEntries;

  void _sync() {
    _readingCount = _kullanici.baktigiFalSayisi;
    _savedEntries = _kullanici.kayitliIrkBitigFallari.length +
        _kullanici.kayitliTarotFallari.length;
    notifyListeners();
  }

  void increment() {
    _readingCount = _kullanici.baktigiFalSayisi;
    _savedEntries = _kullanici.kayitliIrkBitigFallari.length +
        _kullanici.kayitliTarotFallari.length;
    notifyListeners();
  }

  void decrement() {
    if (_readingCount > 0) _readingCount--;
    notifyListeners();
  }

  @override
  void dispose() {
    _kullanici.removeListener(_sync);
    super.dispose();
  }
}
