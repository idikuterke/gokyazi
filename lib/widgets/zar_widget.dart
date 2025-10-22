// lib/widgets/zar_widget.dart

import 'package:flutter/material.dart';

class ZarWidget extends StatelessWidget {
  final int sayi;
  const ZarWidget({super.key, required this.sayi});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        border: Border.all(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          sayi > 0 ? 'o' * sayi : "",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -2.0),
        ),
      ),
    );
  }
}
