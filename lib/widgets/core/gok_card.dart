import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Tek standart kart — tüm uygulamada kullanılır.
class GokCard extends StatelessWidget {
  const GokCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isGlassmorphic = false,
    this.customColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isGlassmorphic;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: isGlassmorphic
            ? AppColors.bgCard.withValues(alpha: 0.7)
            : (customColor ?? AppColors.bgCard),
        border: Border.all(color: AppColors.borderCard),
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber500.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.rCard),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
