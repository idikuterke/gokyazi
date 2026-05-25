import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GroqService {
  final String apiKey;
  GroqService({required this.apiKey});

  static const String _groqEndpoint = "https://api.groq.com/openai/v1/chat/completions";
  static const String _xaiEndpoint = "https://api.x.ai/v1/chat/completions";

  /// --- ✨ GENEL İSTEK FONKSİYONU (Model Fallback Destekli) ---
  Future<String> _requestToGroq({
    required String prompt,
    required String system,
    List<String>? modelTry,
    int maxTokens = 700,
    double temp = 0.85,
  }) async {
    final isXai = apiKey.startsWith('xai-');
    final endpoint = isXai ? _xaiEndpoint : _groqEndpoint;
    
    modelTry ??= isXai 
        ? ["grok-2-latest", "grok-beta"] 
        : ["llama-3.1-8b-instant", "llama3-8b-8192", "llama-3.1-70b-versatile"];
        
    Exception? lastError;

    for (var model in modelTry) {
      try {
        final body = jsonEncode({
          "model": model,
          "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": prompt},
          ],
          "temperature": temp,
          "max_tokens": maxTokens,
        });

        final res = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                "Authorization": "Bearer $apiKey",
                "Content-Type": "application/json",
              },
              body: body,
            )
            .timeout(const Duration(seconds: 45));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data["choices"][0]["message"]["content"];
        } else {
          lastError = Exception("HTTP ${res.statusCode}: ${res.body}");
        }
      } on TimeoutException {
        lastError = Exception(
          "İstek zaman aşımına uğradı. İnternet bağlantını kontrol et.",
        );
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }

    throw lastError ?? Exception("Groq bilinmeyen hata");
  }

  Future<String> generateText(String prompt) => _requestToGroq(
        prompt: prompt,
        system:
            'Sen kadim Türk bilgeliğine sahip bir Tarot yorumcususun. Türkçe yanıt ver.',
        maxTokens: 1024,
      );

  /// 🔮 TAROT YORUMU
  Future<String> getTarotYorum({
    required String niyet,
    required List<String> kartlar,
    String? kozmikBaglam,
  }) async {
    final baglamMetni = kozmikBaglam != null ? '\nKozmik Bağlam:\n$kozmikBaglam\n' : '';
    final prompt =
        """
📌 *Türk Tarotu Bilgeliği*

Niyet: $niyet
$baglamMetni
Kartlar:
${kartlar.join("\n")}

Yorum formatı:
1) Bugünün enerjisi
2) Gizli ruhsal ders
3) Önündeki yol
4) Tengri'nin öğüdü (kısa)
""";

    return _requestToGroq(
      prompt: prompt,
      system: "Sen Orta Asya vizyonlu modern bir bilgesin, dil sade-mistik.",
    );
  }

  /// 🐺 IRK BITIG — Şamanik Fal Yorumu
  Future<String> getIrkBitigYorum({
    required String falMetni,
    required String soru,
    String? kozmikBaglam,
  }) async {
    final baglamMetni = kozmikBaglam != null ? '\nKozmik Bağlam:\n$kozmikBaglam\n' : '';
    final prompt =
        """
Sen Irk Bitig'in bilgelerinden birisin.

Fal Metni:
$falMetni

Soru: "$soru"
$baglamMetni
✨ Şamanik/Tengrici formatla yanıtla:

1) Ruhun işareti 🌬️
2) Gizli uyarı 🜂
3) Yol önerisi 🐎
4) Tengri hükmü (tek cümle)
- olumluysa: "Ança bilin edgü ol"
- zorlayıcıysa: "Ança bilin yablak ol"

Dilin: sade, kadim ve otoriter. 
Cümleler kısa, etkili.
Modern klişe yok. Tarot enerjisi yok.
""";

    return _requestToGroq(
      prompt: prompt,
      system: "Sen Tengri yolunda kadim Türk kam/bilge yorumcususun.",
    );
  }
}
