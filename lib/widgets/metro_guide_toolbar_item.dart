import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/metro_guide_models.dart';
import '../models/metro_models.dart';
import '../theme/app_theme.dart';
import '../utils/metro_guide_svg_utils.dart';

class MetroGuideToolbarItem extends StatelessWidget {
  const MetroGuideToolbarItem({
    super.key,
    this.fileName,
    this.item,
    this.onTap,
    this.compact = false,
    this.city,
  }) : assert(fileName != null || item != null);

  final String? fileName;
  final MetroGuideItem? item;
  final VoidCallback? onTap;
  final bool compact;
  final MetroCityStyle? city;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: compact ? 42 : 60,
      width: compact ? 42 : null,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Center(child: _buildPreview()),
    );

    if (compact) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }

  Widget _buildPreview() {
    if (item != null && _isCustomLine(item!)) {
      return SvgPicture.string(
        MetroGuideSvgUtils.buildCustomLineSvg(item!),
        fit: BoxFit.contain,
      );
    }

    if (item?.customSvgContent != null) {
      return SvgPicture.string(
        item!.customSvgContent!,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (item?.customUrl != null &&
        item!.customUrl!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(item!.customUrl!),
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final resolvedFileName = item?.fileName ?? fileName!;
    return SvgPicture.asset(
      MetroGuideSvgUtils.assetPath(resolvedFileName, city),
      fit: BoxFit.contain,
      placeholderBuilder: (_) => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  bool _isCustomLine(MetroGuideItem guideItem) {
    return guideItem.fileName == 'line@custom.svg' ||
        guideItem.fileName == 'clss@custom.svg';
  }
}
