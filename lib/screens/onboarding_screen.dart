import 'package:flutter/material.dart';
import 'home_screen.dart'; // Yönlendirme için doğru dosyayı import ediyoruz

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Onboarding verilerini güncelledik.
  static const List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Göklere Uzanan Bir Yolculuk',
      'description':
          'Kadim Türklerin inanç ve mitoloji dolu dünyasına adım at. Tengri\'nin sonsuz bilgeliğini keşfet ve evrenin sırlarını öğrenmeye başla.',
      'image': 'assets/images/tengri.jpeg',
      'color': Color.fromARGB(255, 0, 1, 20), // Koyu Mavi
    },
    {
      'title': 'Bilgelik Yolunda Yükseliş',
      'description':
          'Yolun başındaki anlamıyla **Yolçı** olarak başladığın bu macerada, bilgelik kazandıkça **Bilge**, **Kam** ve nihayetinde **Tengrici** olacaksın.',
      'image': 'assets/images/yolculuk.jpeg',
      'color': Color.fromARGB(124, 0, 0, 0), // Koyu Teal
    },
    {
      'title': 'Kutsal Ruhların Gücü Seninle',
      'description':
          '**Kut** (kutsal enerji) kazanacak ve **Ülgen**\'in bilgeliğine erişeceksin. **Börü** (Kurt), **Bars** (Pars) gibi kutsal ruhların rehberliğinde ilerleyeceksin.',
      'image': 'assets/images/bozkurt.png',
      'color': Color.fromARGB(115, 0, 0, 0), // Koyu Turuncu
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentPageColor = _onboardingData[_currentPage]['color'] as Color;

    return Scaffold(
      backgroundColor: currentPageColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (_, index) {
              return _buildOnboardingPage(_onboardingData[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_onboardingData.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withAlpha(128),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                if (_currentPage == _onboardingData.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: currentPageColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Yolculuğa Başla',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    ),
                    child: const Text(
                      'Sonraki',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          data['image'],
          width: 250,
          height: 250,
          errorBuilder: (c, e, s) => const Icon(
            Icons.image_not_supported,
            size: 250,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          data['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            data['description'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
