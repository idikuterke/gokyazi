import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Tüm ekranlarda ortak kozmik arka plan.
class CosmosBackground extends StatelessWidget {
  const CosmosBackground({
    super.key,
    this.imageAsset = 'assets/images/tengri.webp',
    this.imageOpacity = 0.3,
  });

  final String imageAsset;
  final double imageOpacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bgCosmos,
          image: DecorationImage(
            image: AssetImage(imageAsset),
            fit: BoxFit.cover,
            opacity: imageOpacity,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2D1B69).withValues(alpha: 0.8),
              AppColors.bgCosmos,
            ],
          ),
        ),
      ),
    );
  }
}
