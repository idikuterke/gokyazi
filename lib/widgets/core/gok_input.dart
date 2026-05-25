import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Standart metin alanı dekorasyonu.
class GokInput extends StatelessWidget {
  const GokInput({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: AppColors.fgPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: AppColors.fgSecondary),
        hintStyle: TextStyle(color: AppColors.fgTertiary),
        filled: true,
        fillColor: AppColors.bgInputDim,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rCard),
          borderSide: BorderSide(color: AppColors.borderCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rCard),
          borderSide: BorderSide(color: AppColors.borderCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.rCard),
          borderSide: BorderSide(color: AppColors.amber500, width: 1.5),
        ),
      ),
    );
  }
}
