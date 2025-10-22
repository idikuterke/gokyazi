import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 5 saniye sonra ana sayfaya yönlendir
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const OnboardingScreen()), // Yönlendirmeyi değiştir
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gokturkceStyle = TextStyle(
      fontFamily: 'Orkun',
      fontSize: 26,
      color: Colors.white,
      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
    );
    final transliterasyonStyle = TextStyle(
        fontSize: 14,
        color: Colors.white.withAlpha(204),
        fontStyle: FontStyle.italic);
    final turkceStyle =
        TextStyle(fontSize: 15, color: Colors.white.withAlpha(230));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/acilis_ekrani_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            color: Colors.black.withAlpha(128),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '𐰉𐰺𐰽 : 𐰖𐰃𐰞 : 𐰚𐰃𐰤𐱅𐰃 : 𐰖 : 𐰋𐰃𐰾 : 𐰘𐰃𐰏𐰼𐰢𐰃𐰚𐰀 : 𐱃𐰖𐰏𐰇𐰤𐱃𐰣 : 𐰢𐰣𐰃𐰽𐱃𐰣𐱃𐰴𐰃 : 𐰚𐰃𐰲𐰏 : 𐰓𐰃𐱃𐰺 : 𐰉𐰆𐰺𐰆𐰀 : 𐰍𐰆𐰺𐰆 : 𐰾𐰓𐰯 : 𐰲𐰢𐰔 : 𐰃𐰾𐰃𐰏 : 𐰽𐰭𐰆𐰣 : 𐰃𐱅𐰀𐰲𐰸 : 𐰇𐰲𐰇𐰤 : 𐰋𐰃𐱅𐰃𐰓𐰢',
                  textAlign: TextAlign.center,
                  style: gokturkceStyle,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bars yıl ekinti ay biš yigirmike taygüntan manıstantakı kiçig de(n)tar Burua guru : ešidip eçimiz isig saŋun itaçuk üçün bitidim',
                  textAlign: TextAlign.center,
                  style: transliterasyonStyle,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pars yılının ikinci ayın on beşinde (17 Mart 930) taygün-tan manastırındaki küçük keşiş Burua guruyu (hocayı) işitip ağabeyimiz sevgili Sangun İtaçuk için yazdım.',
                  textAlign: TextAlign.center,
                  style: turkceStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
