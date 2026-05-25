import 'package:apsl_sun_calc/apsl_sun_calc.dart' as apsl;
import 'package:flutter/material.dart';

class KozmikProvider extends ChangeNotifier {
  static const double _sinodikGun = 29.5;

  /// Ay faz indeksi — 0, 2, 4, 6
  int ayFaziHesapla(DateTime tarih) {
    try {
      final utcTarih = tarih.isUtc ? tarih : tarih.toUtc();
      final map = apsl.SunCalc.getMoonIllumination(utcTarih);
      final frac = (map['fraction'] as num).toDouble().clamp(0.0, 1.0);
      final ph = (map['phase'] as num).toDouble();

      if (frac < 0.05) return 0;
      if (frac > 0.93) return 4;
      return ph < 0.5 ? 2 : 6;
    } catch (_) {
      return _ayFaziHesaplaFallback(tarih);
    }
  }

  int _ayFaziHesaplaFallback(DateTime tarih) {
    final referensTarihi = DateTime(2000, 1, 6);
    final gunFarki = tarih.difference(referensTarihi).inMilliseconds /
        Duration.millisecondsPerDay;
    var cyclePos = gunFarki % _sinodikGun;
    if (cyclePos < 0) {
      cyclePos += _sinodikGun;
    }
    final segment = ((cyclePos / _sinodikGun) * 8).floor();
    return segment.clamp(0, 7);
  }

  /// Ay fazının adı ve Tengrici yorumunu döndürür
  Map<String, String> ayFaziYorum(DateTime tarih) {
    final fase = ayFaziHesapla(tarih);

    const yorumlar = <String, Map<String, String>>{
      '0': {
        'ad': 'Yeni Ay (Karanlık Ay)',
        'ikon': '🌑',
        'yorum':
            'Gökyüzü karanlık, enerji içe dönük. Yeni kararlar almak, niyet etmek ve nefsi dinlemek için en uygun zamandır. Bugün dışa dönük yorucu eylemlerden ziyade sükûneti tercih et.',
        'mitoloji':
            'Yeraltı, sükûnet ve tohumun toprağa düşmesi. Erlik ve Kara Han\'ın sessizliği.',
      },
      '2': {
        'ad': 'Büyüyen Ay (Hilal)',
        'ikon': '🌒',
        'yorum':
            'Ay büyüyor, yeryüzünün enerjisi artıyor. Aldığın kararları uygulamak, fiziksel olarak güçlenmek ve eyleme geçmek için bereketli günler. Diyetine ve su hedefine sıkı sarıl.',
        'mitoloji':
            'Umay Ana\'nın bereketi, doğanın uyanışı, yaşam enerjisinin yükselişi.',
      },
      '4': {
        'ad': 'Dolunay',
        'ikon': '🌕',
        'yorum':
            'Enerji zirvede ve görünür halde. Bedensel ve ruhsal gerilim artabilir. Nefsini kontrol altında tutman, öfke ve aşırılıklardan kaçınman gereken kritik bir gün.',
        'mitoloji':
            'Gök Tengri\'nin tam ışığı, enerjinin zirvesi. Kamların ritüel ve şifa için en çok kullandığı aydınlık gece.',
      },
      '6': {
        'ad': 'Küçülen Ay (Son Dördün)',
        'ikon': '🌘',
        'yorum':
            'Ay küçülürken bedeni ve zihni arındırma vaktidir. Kötü alışkanlıkları bırakmak, detoks yapmak ve zihinsel yüklerden kurtulmak için evrensel döngü seni destekliyor.',
        'mitoloji': 'Ateşle arınma, fazlalıklardan kurtulma, temizlenme dönemi.',
      },
    };

    return yorumlar['$fase'] ?? yorumlar['0']!;
  }

  // ── Ay evresi (apsl_sun_calc / SunCalc.getMoonIllumination) ─────────

  double getMoonPhase(DateTime tarih) {
    try {
      final utcTarih = tarih.isUtc ? tarih : tarih.toUtc();
      final map = apsl.SunCalc.getMoonIllumination(utcTarih);
      final phase = (map['phase'] as num).toDouble();
      return phase.clamp(0.0, 1.0);
    } catch (_) {
      final daysInCycle =
          (tarih.difference(DateTime.utc(2000, 1, 6)).inDays) % 30;
      return (daysInCycle / 29.530588853).clamp(0.0, 1.0);
    }
  }

  double getMoonIllumination(DateTime tarih) {
    try {
      final utcTarih = tarih.isUtc ? tarih : tarih.toUtc();
      final map = apsl.SunCalc.getMoonIllumination(utcTarih);
      final fraction = (map['fraction'] as num).toDouble();
      return fraction.clamp(0.0, 1.0);
    } catch (_) {
      final phase = getMoonPhase(tarih);
      return phase < 0.5 ? (phase * 2) : ((1.0 - phase) * 2);
    }
  }

  String getMoonPhaseName(DateTime tarih) {
    final fraction = getMoonIllumination(tarih);
    final phase = getMoonPhase(tarih);

    if (fraction < 0.05) return 'Yeni Ay';
    if (fraction > 0.93) return 'Dolunay 🌕';
    if (fraction < 0.42) {
      return phase < 0.5 ? 'Hilal 🌒' : 'Küçülen Hilal 🌘';
    }
    if (fraction <= 0.58) {
      return phase < 0.5 ? 'İlk Dördün 🌓' : 'Son Dördün 🌗';
    }
    return phase < 0.5 ? 'Büyüyen Ay 🌔' : 'Küçülen Ay 🌖';
  }

  String getMoonTooltip(DateTime tarih) {
    final illum = getMoonIllumination(tarih);
    return 'Ay: ${(illum * 100).toStringAsFixed(0)}%';
  }

  IconData getMoonIcon(DateTime tarih) {
    final fraction = getMoonIllumination(tarih);

    if (fraction < 0.05) return Icons.nightlight_round;
    if (fraction > 0.93) return Icons.brightness_high;
    if (fraction < 0.45) return Icons.nightlight;
    if (fraction < 0.55) return Icons.brightness_3;
    return Icons.brightness_3;
  }

  Color getMoonColor(BuildContext context, DateTime tarih) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fraction = getMoonIllumination(tarih);

    if (fraction < 0.05) {
      return isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    }
    if (fraction > 0.93) {
      return Colors.yellow.shade200;
    }
    if (fraction < 0.45) return Colors.amber.shade300;
    if (fraction < 0.55) return Colors.amber.shade100;
    return Colors.amber.shade100;
  }
}
