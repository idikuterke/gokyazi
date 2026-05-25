import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FogEffect extends StatelessWidget {
  final double opacity;

  const FogEffect({super.key, this.opacity = 0.7});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: opacity,
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Lottie.asset(
              "assets/animations/fog.json",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
