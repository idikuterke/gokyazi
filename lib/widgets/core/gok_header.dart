import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Standart ekran başlığı — Göktürk + Latin.
class GokHeader extends StatelessWidget {
  const GokHeader({
    super.key,
    required this.titleGokturk,
    required this.titleLatin,
    this.subtitle,
    this.action,
  });

  final String titleGokturk;
  final String titleLatin;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titleGokturk,
          style: TextStyle(
            fontFamily: AppTypography.fontRunic,
            fontSize: 32,
            height: 1.2,
            color: AppColors.amber500,
            shadows: [
              Shadow(
                color: AppColors.amber500.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.inlineGap),
        Text(
          titleLatin,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.fgPrimary,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.inlineGap),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.fgSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: AppSpacing.space4),
          action!,
        ],
      ],
    );
  }
}
