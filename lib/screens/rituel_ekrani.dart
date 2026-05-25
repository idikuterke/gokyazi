// rituel_ekrani.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class RituelEkrani extends StatefulWidget {
  final VoidCallback onFinish;
  const RituelEkrani({super.key, required this.onFinish});

  @override
  State<RituelEkrani> createState() => _RituelEkraniState();
}

class _RituelEkraniState extends State<RituelEkrani> {
  final AudioPlayer _drum = AudioPlayer();
  final List<String> lines = [
    "🕯 Gözlerini kapa...",
    "🌬 Derin nefes al...",
    "✨ Ataların nefesi çevrende...",
    "🐺 Yolun görünmek üzere...",
    "🎲 Hazırsan kaderi çağır...",
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    for (var i = 0; i < lines.length; i++) {
      if (!mounted) return;

      setState(() => index = i);

      HapticFeedback.mediumImpact();

      try {
        await _drum.play(AssetSource("sounds/drum.wav"));
      } catch (e, st) {
        debugPrint('Rituel ses çalma hatası: $e\n$st');
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    widget.onFinish();
  }

  @override
  void dispose() {
    _drum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              "assets/animations/fog.json",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Text(
                lines[index],
                key: ValueKey(index),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
