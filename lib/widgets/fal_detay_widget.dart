import 'package:flutter/material.dart';
import '../models/fal_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'core/gok_button.dart';

class FalDetayWidget extends StatefulWidget {
  final Fal fal;
  final String? aiYorumu;
  final bool aiYorumYukleniyor;
  final VoidCallback onAiYorumIste;

  const FalDetayWidget({
    super.key,
    required this.fal,
    this.aiYorumu,
    this.aiYorumYukleniyor = false,
    required this.onAiYorumIste,
  });

  @override
  State<FalDetayWidget> createState() => _FalDetayWidgetState();
}

class _FalDetayWidgetState extends State<FalDetayWidget> {
  // İlk bölüm (Türkçe/Anlam) açık, diğerleri kapalı başlasın
  final Map<int, bool> _expanded = {0: true};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildAccordionItem(
            index: 0,
            title: 'Türkçe Çevirisi',
            icon: Icons.translate,
            content: widget.fal.turkce,
          ),
          _buildAccordionItem(
            index: 1,
            title: 'Kadim Yazıt (Göktürkçe)',
            icon: Icons.history_edu,
            content: widget.fal.gokturkce,
            isGokturkce: true,
          ),
          _buildAccordionItem(
            index: 2,
            title: 'Okunuşu',
            icon: Icons.record_voice_over,
            content: widget.fal.transliterasyon,
          ),
          _buildAccordionItem(
            index: 3,
            title: 'Modern Yorum',
            icon: Icons.lightbulb_outline,
            content: widget.fal.yorumModern,
          ),
          _buildAiAccordionItem(index: 4),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required IconData icon,
    required String content,
    bool isGokturkce = false,
  }) {
    final isExpanded = _expanded[index] ?? false;

    return Column(
      children: [
        if (index > 0) Divider(height: 1, color: AppColors.borderCard),
        InkWell(
          onTap: () {
            setState(() {
              _expanded[index] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.amber500, size: 20),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.displaySm.copyWith(
                      color: isExpanded ? AppColors.amber500 : AppColors.fgSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.fgDisabled,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              content,
              textAlign: isGokturkce ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                color: AppColors.fgPrimary,
                fontSize: isGokturkce ? 26 : 16,
                height: 1.6,
                fontFamily: isGokturkce ? 'Orkun' : null,
              ),
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildAiAccordionItem({required int index}) {
    final isExpanded = _expanded[index] ?? false;
    final hasYorum = widget.aiYorumu != null && widget.aiYorumu!.isNotEmpty;

    return Column(
      children: [
        Divider(height: 1, color: AppColors.borderCard),
        InkWell(
          onTap: () {
            setState(() {
              _expanded[index] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.cyanSpecial, size: 20),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    'Kam\'ın Yorumu (AI)',
                    style: AppTypography.displaySm.copyWith(
                      color: isExpanded ? AppColors.cyanSpecial : AppColors.fgSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.fgDisabled,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: widget.aiYorumYukleniyor
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : hasYorum
                    ? Text(
                        widget.aiYorumu!,
                        style: TextStyle(
                          color: AppColors.cyanSpecial.withValues(alpha: 0.9),
                          fontSize: 16,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bu kadim yazıtın sana özel şamanik yorumunu duymak istersen, bilgeliğin kapısını aralayabilirsin.',
                            style: TextStyle(color: AppColors.fgSecondary, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GokButton(
                            text: 'Söze Kulak Ver',
                            icon: Icons.auto_awesome,
                            onPressed: widget.onAiYorumIste,
                            style: GokButtonStyle.primary,
                          ),
                        ],
                      ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
