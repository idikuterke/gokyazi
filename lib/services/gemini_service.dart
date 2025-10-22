// gemini_service.dart

import 'dart:async';
import 'dart:convert';
// DEĞİŞTİ: Hatalı import düzeltildi.
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/fal_model.dart';
import '../models/tarot_karti.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/';
  static const String _modelName = 'gemini-pro';
  final String apiKey;

  GeminiService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw ArgumentError("API Anahtarı boş olamaz!");
    }
  }

  Future<String> getGeminiInterpretation({
    required Fal fal,
    required String soru,
  }) async {
    final prompt =
        """
      Sen bir kadim Türk falcısısın. Türkçe olarak fal yorumu yap.
      Kullanıcının sorusu: '$soru'
      Kadim metin: '${fal.gokturkce}'
      Modern Yorum: '${fal.yorumModern}'

      Yukarıdaki bilgileri kullanarak, kullanıcının sorusuna özel, modern ve bilge bir şekilde fal yorumu yap. Yorumun en az 100 kelime olmalı, ancak 250 kelimeyi geçmemeli.
    """;
    return await _sendPromptToGemini(prompt: prompt);
  }

  Future<String> getYillikYorum({
    required String userAnimal,
    required String currentAnimal,
    required String userMucel,
    required int userAge,
  }) async {
    final prompt =
        '''
      Sen kadim Türk bilgeliğine sahip bir "aksakal" rolündesin. Aşağıdaki bilgilere dayanarak, kullanıcıya özel bir yıllık yorum ve rehberlik sun.

      ### KULLANICI BİLGİLERİ:
      - Doğum Yılı Hayvanı: $userAnimal
      - İçinde Bulunulan Yılın Hayvanı: $currentAnimal
      - Mevcut Müçel Durumu: $userMucel
      - Yaşı: $userAge

      ### TALİMATLAR:
      1. İki hayvan yılı arasındaki ilişkiyi Türk mitolojisi ve kültürüne göre yorumla
      2. Mevcut müçel durumunu dikkate alarak kişisel gelişim tavsiyeleri ver
      3. İçinde bulunulan yılın enerjisini açıkla
      4. "Kut" enerjisini nasıl güçlendirebileceğine dair önerilerde bulun
      5. Kısa, anlaşılır ve motive edici bir dil kullan
      6. Toplam 150-200 kelimeyi geçme

      Yorumunu doğrudan Türkçe olarak ve samimi bir üslupla yaz.
    ''';
    return await _sendPromptToGemini(prompt: prompt);
  }

  Future<String> getTarotYorumu({
    required String niyet,
    required List<TarotKarti> secilenKartlar,
    required Map<int, bool> kartlarTersMi,
  }) async {
    String kartBilgileri = secilenKartlar
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          TarotKarti kart = entry.value;
          bool tersMi = kartlarTersMi[index] ?? false;
          String durum = tersMi ? "Ters" : "Düz";
          return "${index + 1}. Kart: ${kart.ad} ($durum) - Anlamı: ${tersMi ? kart.tersAnlam : kart.duzAnlam}";
        })
        .join('\n');

    final prompt =
        '''
      Sen usta bir Tarot yorumcususun ve Türk mitolojisi konusunda derin bilgiye sahipsin. Aşağıdaki bilgilere dayanarak, kullanıcıya özel, derin ve anlamlı bir Tarot yorumu yap.

      ### KULLANICI BİLGİLERİ:
      - Niyeti / Sorusu: "$niyet"

      ### AÇILIMDAKİ KARTLAR:
      $kartBilgileri

      ### TALİMATLAR:
      1. Yorumunu doğrudan kullanıcıya hitap ederek, samimi ve bilge bir dille yaz.
      2. Kartların anlamlarını kullanıcının niyetiyle bütünleştirerek kişisel bir rehberlik sun.
      3. Kartların birbiriyle olan ilişkisini ve hikayesini anlat.
      4. Toplam 200-250 kelime arasında bir yorum yap.
    ''';
    return await _sendPromptToGemini(prompt: prompt);
  }

  Future<String> _sendPromptToGemini({required String prompt}) async {
    final fullUrl = '$_baseUrl$_modelName:generateContent?key=$apiKey';

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 512,
        "stopSequences": [],
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE",
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE",
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE",
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE",
        },
      ],
    };

    try {
      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 45));

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null) return text;
            }
          }
        }
        throw Exception('API yanıtı geçerli bir yorum içermiyor.');
      } else {
        final errorMessage = data['error']?['message'] ?? response.reasonPhrase;
        throw Exception('API Hatası: ${response.statusCode} - $errorMessage');
      }
    } on TimeoutException {
      throw Exception(
        "İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.",
      );
    } catch (e) {
      debugPrint('Gemini servisinde beklenmeyen bir hata: $e');
      rethrow;
    }
  }
}
