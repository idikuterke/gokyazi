import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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

  runApp(
    ChangeNotifierProvider.value(
      value: kullaniciModel,
      child: const GokYaziApp(),
    ),
  );
}

class GokYaziApp extends StatelessWidget {
  const GokYaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gök Yazı',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0A18),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(surface: const Color(0xFF0C0A18)),
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        fontFamily: 'Orkun',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
