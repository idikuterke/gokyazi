import '../models/kullanici_model.dart';
import 'gemini_service.dart';
import 'groq_service.dart';

/// [.env] üzerinden okunan anahtarlarla Gemini / Groq istemcilerini tembel oluşturur.
/// [Provider] ile ağaçta sunulur; ekranlar önce Gemini, yoksa Groq dener.
class AiServicesHolder {
  AiServicesHolder(this._kullanici);

  final KullaniciModel _kullanici;

  GeminiService? _gemini;
  String? _lastGeminiKey;
  GroqService? _groq;
  String? _lastGroqKey;

  GeminiService? get geminiOrNull {
    final k = _kullanici.getApiKey();
    if (k == null || k.isEmpty) return null;
    if (_gemini == null || _lastGeminiKey != k) {
      _gemini = GeminiService(apiKey: k);
      _lastGeminiKey = k;
    }
    return _gemini;
  }

  GroqService? get groqOrNull {
    final k = _kullanici.getGroqApiKey();
    if (k == null || k.isEmpty) return null;
    if (_groq == null || _lastGroqKey != k) {
      _groq = GroqService(apiKey: k);
      _lastGroqKey = k;
    }
    return _groq;
  }

  /// En az bir AI sağlayıcı yapılandırılmış mı?
  bool get hasAnyBackend => geminiOrNull != null || groqOrNull != null;

  /// Önce Gemini'yi dener, hata alırsa (örn. 429 Limit) Groq'a düşer.
  Future<String> generateTextWithFallback({
    required String prompt,
  }) async {
    Exception? geminiError;
    final gemini = geminiOrNull;
    
    if (gemini != null) {
      try {
        return await gemini.generateText(prompt);
      } catch (e) {
        geminiError = Exception('Gemini Hatası: $e');
      }
    }

    final groq = groqOrNull;
    if (groq != null) {
      try {
        return await groq.generateText(prompt);
      } catch (e) {
        throw Exception('Groq Hatası: $e. Önceki Hata: ${geminiError?.toString() ?? ""}');
      }
    }

    if (geminiError != null) throw geminiError;
    throw Exception('Gök kapalı: .env içinde geçerli GEMINI veya GROQ anahtarı bulunamadı.');
  }
}
