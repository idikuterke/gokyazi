import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'cosmos_background.dart';
import 'gok_header.dart';

/// Ortak ekran iskeleti: arka plan + başlık + kaydırılabilir içerik.
class GokScreenScaffold extends StatelessWidget {
  const GokScreenScaffold({
    super.key,
    required this.body,
    this.titleGokturk,
    this.titleLatin,
    this.subtitle,
    this.appBarTitle,
    this.leading,
    this.actions,
    this.backgroundAsset,
    this.backgroundOpacity = 0.3,
    this.showHeader = true,
    this.scrollable = true,
    this.padding,
    this.floatingActionButton,
  });

  final Widget body;
  final String? titleGokturk;
  final String? titleLatin;
  final String? subtitle;
  final String? appBarTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final String? backgroundAsset;
  final double backgroundOpacity;
  final bool showHeader;
  final bool scrollable;
  final EdgeInsets? padding;
  final Widget? floatingActionButton;

  bool get _hasHeader =>
      showHeader && titleGokturk != null && titleLatin != null;

  @override
  Widget build(BuildContext context) {
    final headerBlock = _hasHeader
        ? [
            GokHeader(
              titleGokturk: titleGokturk!,
              titleLatin: titleLatin!,
              subtitle: subtitle,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ]
        : <Widget>[];

    final pagePadding =
        padding ?? const EdgeInsets.all(AppSpacing.pagePadding);

    final Widget mainContent;
    if (scrollable) {
      mainContent = SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [...headerBlock, body],
        ),
      );
    } else {
      mainContent = Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...headerBlock,
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgCosmos,
      extendBodyBehindAppBar: appBarTitle != null || leading != null,
      appBar: (appBarTitle != null || leading != null)
          ? AppBar(
              title: appBarTitle != null
                  ? Text(
                      appBarTitle!,
                      style: TextStyle(
                        color: AppColors.fgPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              leading: leading,
              actions: actions,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.amber500),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CosmosBackground(
            imageAsset: backgroundAsset ?? 'assets/images/tengri.webp',
            imageOpacity: backgroundOpacity,
          ),
          SafeArea(child: mainContent),
        ],
      ),
    );
  }
}
