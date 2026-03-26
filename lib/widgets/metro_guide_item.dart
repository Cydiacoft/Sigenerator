import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/metro_guide_models.dart';
import '../theme/app_theme.dart';
import '../utils/metro_guide_svg_utils.dart';

class MetroGuideItemWidget extends StatelessWidget {
  const MetroGuideItemWidget({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isDragging = false,
  });

  final MetroGuideItem item;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Opacity(opacity: isDragging ? 0.5 : 1, child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (item.type == GuideItemType.text) {
      return _buildTextItem();
    }

    if (_isCustomLine()) {
      return _buildCustomLineItem();
    }

    if (item.type == GuideItemType.sub &&
        (item.fileName == 'sub@exit.svg' ||
            item.fileName == 'sub@text.svg' ||
            item.fileName == 'sub@custom.svg')) {
      return _buildCustomSubItem();
    }

    if (item.customSvgContent != null) {
      return SvgPicture.string(item.customSvgContent!, fit: BoxFit.contain);
    }

    if (item.customUrl != null && item.customUrl!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(File(item.customUrl!), fit: BoxFit.contain);
    }

    if (item.customColor != null) {
      return FutureBuilder<String>(
        future: MetroGuideSvgUtils.loadColoredSvg(
          item.fileName,
          item.customColor!,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return SvgPicture.string(snapshot.data!, fit: BoxFit.contain);
        },
      );
    }

    return SvgPicture.asset(
      MetroGuideSvgUtils.assetPath(item.fileName),
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextItem() {
    final text = item.customText ?? const CustomText(cn: '', en: '');
    final alignment = switch (text.alignment) {
      TextAlignment.middle => CrossAxisAlignment.center,
      TextAlignment.end => CrossAxisAlignment.end,
      TextAlignment.start => CrossAxisAlignment.start,
    };
    final textAlign = switch (text.alignment) {
      TextAlignment.middle => TextAlign.center,
      TextAlignment.end => TextAlign.end,
      TextAlignment.start => TextAlign.start,
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 100, minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment,
        children: [
          if (text.cn.isNotEmpty)
            Text(
              text.cn,
              textAlign: textAlign,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          if (text.en.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text.en,
                textAlign: textAlign,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
          if (item.hasColorBand)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 28,
              width: double.infinity,
              color: _parseColor(item.colorBandColor ?? '#001D31'),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomLineItem() {
    if (item.type == GuideItemType.line) {
      return _buildLineBadgeItem();
    }

    final lineCode = item.customText?.cn.trim().isNotEmpty == true
        ? item.customText!.cn.trim()
        : 'XX';
    final lineName = item.customText?.en.trim().isNotEmpty == true
        ? item.customText!.en.trim()
        : '自定义线路';
    final lineColor = _parseColor(item.customColor ?? '#E4002B');

    return Container(
      constraints: const BoxConstraints(minWidth: 120, minHeight: 80),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1525),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: lineColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              lineCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              lineName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineBadgeItem() {
    final lineCode = item.customText?.cn.trim().isNotEmpty == true
        ? item.customText!.cn.trim()
        : 'XX';
    final lineColor = _parseColor(item.customColor ?? '#E4002B');

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: lineColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        lineCode,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  bool _isCustomLine() {
    return item.fileName == 'line@custom.svg' ||
        item.fileName == 'clss@custom.svg';
  }

  Widget _buildCustomSubItem() {
    if (item.fileName == 'sub@text.svg') {
      return _buildTextItem();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _parseColor(item.colorBandColor ?? '#001D31'),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.exit_to_app, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            item.customText?.cn.isNotEmpty == true ? item.customText!.cn : '出口',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      final normalized = colorStr.startsWith('#')
          ? colorStr.substring(1)
          : colorStr;
      final value = normalized.length == 6 ? 'FF$normalized' : normalized;
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return const Color(0xFF001D31);
    }
  }
}
