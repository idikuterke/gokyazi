import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService extends ChangeNotifier {
  User? get currentUser => supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.id;

  StreamSubscription? _authSubscription;

  AuthService() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Email ile kayıt ol
  Future<void> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Kayıt başarısız oldu';
      }

      // MANUEL PROFIL OLUŞTUR (trigger çalışmazsa)
      try {
        await supabase.from('user_profiles').insert({
          'id': response.user!.id,
          'email': email,
        });

        await supabase.from('ai_quota').insert({
          'user_id': response.user!.id,
        });
      } catch (e) {
        debugPrint('Profil oluşturma hatası (normal olabilir): $e');
        // Hata olsa bile devam et (trigger zaten oluşturmuş olabilir)
      }

      notifyListeners();
    } on AuthException catch (e) {
      throw 'Kayıt hatası: ${e.message}';
    } catch (e) {
      throw 'Beklenmeyen hata: $e';
    }
  }

  /// Email ile giriş yap
  Future<void> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      notifyListeners();
    } on AuthException catch (e) {
      throw 'Giriş hatası: ${e.message}';
    } catch (e) {
      throw 'Beklenmeyen hata: $e';
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('Çıkış hatası: $e');
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw 'Şifre sıfırlama hatası: ${e.message}';
    }
  }

  /// Kullanıcı profili bilgilerini al
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId!)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Profil yükleme hatası: $e');
      return null;
    }
  }

  /// Doğum tarihi kaydet
  Future<void> saveUserProfile({
    required DateTime dogumTarihi,
    required int dogumYili,
    required int hayvanProfili,
  }) async {
    if (!isAuthenticated) throw 'Kullanıcı girişi gerekli';

    try {
      await supabase.from('user_profiles').upsert({
        'id': userId,
        'email': currentUser!.email,
        'dogum_tarihi': dogumTarihi.toIso8601String(),
        'dogum_yili': dogumYili,
        'hayvan_profili': hayvanProfili,
      });
    } catch (e) {
      throw 'Profil kaydetme hatası: $e';
    }
  }
}
