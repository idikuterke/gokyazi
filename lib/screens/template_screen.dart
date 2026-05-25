import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../widgets/core/gok_button.dart';
import '../widgets/core/gok_card.dart';
import '../widgets/core/gok_input.dart';
import '../widgets/core/gok_screen_scaffold.dart';

/// Yeni ekranlar için referans şablon.
class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GokScreenScaffold(
      titleGokturk: '𐰏𐰇𐰚⸱𐰖𐰔𐰃',
      titleLatin: 'GÖK YAZI',
      subtitle: 'Kadim bilgelik yolu',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GokCard(
            child: GokInput(
              controller: TextEditingController(),
              labelText: 'Niyetini yaz',
            ),
          ),
          const SizedBox(height: AppSpacing.widgetGap),
          GokButton(
            text: 'Devam Et',
            icon: Icons.auto_awesome,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
