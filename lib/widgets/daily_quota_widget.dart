import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kullanici_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Günlük fal hakkı (`KullaniciModel.falHakki`, varsayılan 2/gün).
class DailyQuotaWidget extends StatelessWidget {
  const DailyQuotaWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final kullanici = context.watch<KullaniciModel>();
    final remaining = kullanici.falHakki;
    const maxDaily = 2;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(
          color: AppColors.amber500.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: remaining == 0 ? AppColors.fgTertiary : AppColors.amber500,
            size: compact ? 16 : 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Günlük hak: $remaining/$maxDaily',
            style: TextStyle(
              color: AppColors.fgPrimary,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (remaining == 0) ...[
            const SizedBox(width: 6),
            Text(
              '(Premium)',
              style: TextStyle(
                color: AppColors.danger.withValues(alpha: 0.9),
                fontSize: compact ? 11 : 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
