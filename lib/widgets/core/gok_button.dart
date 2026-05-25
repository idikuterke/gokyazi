import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum GokButtonStyle { primary, secondary, ghost }

/// Tek standart buton — tüm uygulamada kullanılır.
class GokButton extends StatelessWidget {
  const GokButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = GokButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final GokButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Color bgColor;
    Color fgColor;

    switch (style) {
      case GokButtonStyle.primary:
        bgColor = AppColors.amber500;
        fgColor = AppColors.fgOnAmber;
        break;
      case GokButtonStyle.secondary:
        bgColor = AppColors.bgCard;
        fgColor = AppColors.fgPrimary;
        break;
      case GokButtonStyle.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.amber500;
        break;
    }

    if (!enabled && style == GokButtonStyle.primary) {
      bgColor = AppColors.fgDisabled;
      fgColor = AppColors.fgSecondary;
    }

    final button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.4),
        disabledForegroundColor: fgColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rButton),
          side: style == GokButtonStyle.ghost
              ? BorderSide(color: AppColors.amber500)
              : BorderSide.none,
        ),
        elevation: 0,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.inlineGap),
                ],
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
