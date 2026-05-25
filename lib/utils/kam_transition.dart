import 'dart:ui';
import 'package:flutter/material.dart';

class KamTransition extends PageRouteBuilder {
  final Widget page;

  KamTransition({required this.page})
    : super(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
          );

          final scale = Tween(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
          );

          final blur = Tween(begin: 20.0, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blur.value,
                      sigmaY: blur.value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  Opacity(
                    opacity: fade.value,
                    child: Transform.scale(scale: scale.value, child: child),
                  ),
                ],
              );
            },
          );
        },
      );
}
