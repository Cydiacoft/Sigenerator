import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/metro_guide_models.dart';
import '../theme/app_theme.dart';
import '../utils/metro_guide_svg_utils.dart';

class MetroGuideToolbarItem extends StatelessWidget {
  const MetroGuideToolbarItem({
    super.key,
    this.fileName,
    this.item,
    this.onTap,
    this.compact = false,
  }) : assert(fileName != null || item != null);

  final String? fileName;
  final MetroGuideItem? item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final guideItem = item;
    final child = Container(
      height: compact ? 42 : 60,
      width: compact ? 42 : null,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Center(child: _buildPreview(guideItem)),
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

  Widget _buildPreview(MetroGuideItem? guideItem) {
    if (guideItem != null && _isCustomLine(guideItem)) {
      return _buildCustomLinePreview(guideItem);
    }

    if (guideItem?.customSvgContent != null) {
      return SvgPicture.string(
        guideItem!.customSvgContent!,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (guideItem?.customUrl != null &&
        guideItem!.customUrl!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(guideItem.customUrl!),
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final resolvedFileName = guideItem?.fileName ?? fileName!;
    return SvgPicture.asset(
      MetroGuideSvgUtils.assetPath(resolvedFileName),
      fit: BoxFit.contain,
      placeholderBuilder: (_) => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildCustomLinePreview(MetroGuideItem guideItem) {
    if (guideItem.type == GuideItemType.line) {
      return _buildLineBadgePreview(guideItem);
    }

    final lineCode = guideItem.customText?.cn.trim().isNotEmpty == true
        ? guideItem.customText!.cn.trim()
        : 'XX';
    final lineName = guideItem.customText?.en.trim().isNotEmpty == true
        ? guideItem.customText!.en.trim()
        : '自定义线路';
    final lineColor = _parseColor(guideItem.customColor ?? '#E4002B');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: compact ? 20 : 24,
          height: compact ? 20 : 24,
          decoration: BoxDecoration(color: lineColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            lineCode,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              lineName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineBadgePreview(MetroGuideItem guideItem) {
    final lineCode = guideItem.customText?.cn.trim().isNotEmpty == true
        ? guideItem.customText!.cn.trim()
        : 'XX';
    final lineColor = _parseColor(guideItem.customColor ?? '#E4002B');

    return Container(
      width: compact ? 26 : 32,
      height: compact ? 26 : 32,
      decoration: BoxDecoration(
        color: lineColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      alignment: Alignment.center,
      child: Text(
        lineCode,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  bool _isCustomLine(MetroGuideItem guideItem) {
    return guideItem.fileName == 'line@custom.svg' ||
        guideItem.fileName == 'clss@custom.svg';
  }

  Color _parseColor(String colorStr) {
    try {
      final normalized = colorStr.startsWith('#')
          ? colorStr.substring(1)
          : colorStr;
      final value = normalized.length == 6 ? 'FF$normalized' : normalized;
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return const Color(0xFFE4002B);
    }
  }
}
