import 'package:flutter/material.dart';
import '../models/kullanici_model.dart';
import '../theme/app_colors.dart';

class SeviyeIlerlemeGostergesi extends StatelessWidget {
  final KullaniciModel kullanici;

  const SeviyeIlerlemeGostergesi({
    super.key,
    required this.kullanici,
  });

  @override
  Widget build(BuildContext context) {
    double yuzde = 0;
    if (kullanici.sonrakiSeviyeExperience > 0) {
      yuzde = (kullanici.experience / kullanici.sonrakiSeviyeExperience)
          .clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Seviye ${kullanici.seviye}',
              style: TextStyle(color: AppColors.fgPrimary),
            ),
            Text(
              '${kullanici.experience} / ${kullanici.sonrakiSeviyeExperience} DP',
              style: TextStyle(color: AppColors.fgSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: yuzde,
          backgroundColor: AppColors.fgDisabled,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber500),
          minHeight: 10,
        ),
      ],
    );
  }
}
