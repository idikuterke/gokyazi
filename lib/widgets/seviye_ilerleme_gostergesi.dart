import 'package:flutter/material.dart';
import '../models/kullanici_model.dart';

class SeviyeIlerlemeGostergesi extends StatelessWidget {
  // HATA DÜZELTME: Widget artık tek bir 'kullanici' parametresi alıyor.
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
            Text('Seviye ${kullanici.seviye}',
                style: const TextStyle(color: Colors.white)),
            Text(
                '${kullanici.experience} / ${kullanici.sonrakiSeviyeExperience} DP',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: yuzde,
          backgroundColor: Colors.grey.shade700,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          minHeight: 10,
        ),
      ],
    );
  }
}
