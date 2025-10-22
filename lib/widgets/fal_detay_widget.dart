import 'package:flutter/material.dart';
import '../screens/fal_ekrani.dart'; // HATA DÜZELTME: GosterimTuru enum'u için import eklendi

class FalDetayWidget extends StatelessWidget {
  final String baslik;
  final String metin;
  final bool gokturkceFont;
  final Function(GosterimTuru) onGosterimDegistir;

  const FalDetayWidget({
    super.key,
    required this.baslik,
    required this.metin,
    required this.gokturkceFont,
    required this.onGosterimDegistir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            baslik,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'CinzelDecorative',
            ),
          ),
          const Divider(height: 24, color: Colors.white30),
          Text(
            metin,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: gokturkceFont ? 24 : 16,
              height: 1.5,
              fontFamily: gokturkceFont ? 'Orkun' : null,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGosterimButonu(
                  context,
                  'Göktürkçe',
                  GosterimTuru.gokturkce,
                ),
                _buildGosterimButonu(
                  context,
                  'Okunuşu',
                  GosterimTuru.transliterasyon,
                ),
                _buildGosterimButonu(context, 'Anlamı', GosterimTuru.turkce),
                _buildGosterimButonu(
                  context,
                  'Modern Yorum',
                  GosterimTuru.modernYorum,
                ),
                _buildGosterimButonu(
                  context,
                  'Sorunuza Yanıtı',
                  GosterimTuru.geminiYorumu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGosterimButonu(
    BuildContext context,
    String label,
    GosterimTuru tur,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () => onGosterimDegistir(tur),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.4),
          foregroundColor: Colors.white70,
        ),
        child: Text(label),
      ),
    );
  }
}
