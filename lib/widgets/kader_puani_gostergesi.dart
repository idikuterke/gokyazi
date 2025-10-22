import 'package:flutter/material.dart';
import '../models/kullanici_model.dart';

class KaderPuaniGostergesi extends StatelessWidget {
  final KullaniciModel kullanici;

  const KaderPuaniGostergesi({super.key, required this.kullanici});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.yellow[600],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Kader Puanı: ${kullanici.kaderPuani}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
