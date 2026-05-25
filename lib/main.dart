import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/kullanici_model.dart';
import 'models/kazanilan_rozet.dart';
import 'models/favori_fal.dart';
import 'models/kayitli_tarot.dart';
import 'models/kayitli_irk_bitig.dart';
import 'models/user_progress.dart';
import 'models/kullanici_verisi.dart';
import 'models/achievement.dart';
import 'models/collection_card.dart';
import 'models/fal_model.dart';
import 'screens/splash_screen.dart';
import 'providers/reading_stats_provider.dart';
import 'services/auth_service.dart';
import 'services/ai_services_holder.dart';
import 'providers/kozmik_provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'models/kullanici_model.dart' show KullaniciModel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("HATA: .env dosyası yüklenemedi! $e");
  }

  // Supabase bağlantısını güvenli bir şekilde başlat
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty ||
      supabaseUrl.contains('placeholder') ||
      supabaseAnonKey.isEmpty ||
      supabaseAnonKey.contains('placeholder')) {
    debugPrint(
      "⚠️ UYARI: Supabase URL veya Anon Anahtarı eksik ya da varsayılan değerde! Lütfen .env dosyasını güncelleyin.",
    );
  }

  await Supabase.initialize(
    url: supabaseUrl.isNotEmpty
        ? supabaseUrl
        : 'https://placeholder-please-set-your-supabase-url.supabase.co',
    anonKey: supabaseAnonKey.isNotEmpty
        ? supabaseAnonKey
        : 'placeholder-please-set-your-supabase-anon-key',
  );

  await Hive.initFlutter();

  Hive.registerAdapter(KullaniciVerisiAdapter());
  Hive.registerAdapter(UserProgressAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(KazanilanRozetAdapter());
  Hive.registerAdapter(CollectionCardAdapter());
  Hive.registerAdapter(FavoriFalAdapter());
  Hive.registerAdapter(KayitliTarotAdapter());
  Hive.registerAdapter(KayitliIrkBitigAdapter());
  // HATA DÜZELTME: FalAdapter'ı kaydetmek için doğru komut.
  Hive.registerAdapter(FalAdapter());

  await Hive.openBox('appCache');

  final kullaniciModel = KullaniciModel();
  await kullaniciModel.loadData();
  final readingStats = ReadingStatsNotifier(kullaniciModel);

  await SentryFlutter.init(
    (options) => options.dsn = dotenv.env['SENTRY_DSN'] ?? 'YOUR_DSN',
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: kullaniciModel),
          ChangeNotifierProvider.value(value: readingStats),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => KozmikProvider()),
          Provider<AiServicesHolder>(
            create: (_) => AiServicesHolder(kullaniciModel),
          ),
        ],
        child: const GokYaziApp(),
      ),
    ),
  );
}

final supabase = Supabase.instance.client;

class GokYaziApp extends StatelessWidget {
  const GokYaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KullaniciModel>(
      builder: (context, model, _) {
        final isDark = model.isDarkTheme;
        // Build both theme objects (each has isDarkMode side-effect),
        // then restore isDarkMode so all direct AppColors references are correct.
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        AppColors.isDarkMode = isDark;
        return MaterialApp(
          title: 'Gök Yazı',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
