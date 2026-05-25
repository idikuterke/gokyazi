import 'package:flutter/material.dart';

class RuneTransition extends PageRouteBuilder {
  final Widget page;

  RuneTransition({required this.page})
    : super(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return Stack(
            children: [
              FadeTransition(opacity: fade, child: child),

              // Rün parlaması
              Center(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 2.4).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutQuad,
                      ),
                    ),
                    child: Text(
                      "𐰤", // Orhun alfabesinden “N” rünü = Yol, nasip, kader
                      style: TextStyle(
                        fontSize: 72,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontFamily: 'Orkun',
                        shadows: [
                          Shadow(
                            blurRadius: 30,
                            color: Colors.cyanAccent.withValues(alpha: 0.7),
                          ),
                          Shadow(
                            blurRadius: 60,
                            color: Colors.lightBlueAccent.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}
