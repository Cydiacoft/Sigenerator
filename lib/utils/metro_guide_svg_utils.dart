import 'package:flutter/services.dart';
import '../models/metro_guide_models.dart';
import '../models/metro_models.dart';

class MetroGuideSvgUtils {
  MetroGuideSvgUtils._();

  static const String assetDirectory = 'assets/metro_guide';
  static final Map<String, Future<String>> _svgCache = {};

  static String assetPath(String fileName, [MetroCityStyle? city]) {
    if (city == null || city == MetroCityStyle.shanghai) {
      return '$assetDirectory/$fileName';
    }
    return '$assetDirectory/${city.name}/$fileName';
  }

  static String getCityAssetDirectory(MetroCityStyle city) {
    if (city == MetroCityStyle.shanghai) {
      return assetDirectory;
    }
    return '$assetDirectory/${city.name}';
  }

  static Future<String> loadSvg(String fileName, [MetroCityStyle? city]) {
    final resolvedPath = assetPath(
      fileName,
      city ?? _inferCityFromFileName(fileName),
    );
    return _svgCache.putIfAbsent(
      resolvedPath,
      () => rootBundle.loadString(resolvedPath),
    );
  }

  static Future<String> loadColoredSvg(
    String fileName,
    String color, [
    MetroCityStyle? city,
  ]) async {
    final rawSvg = await loadSvg(fileName, city);
    return applyColor(rawSvg, color);
  }

  static String applyColor(String svg, String color) {
    var output = svg;

    final colorGroupPattern = RegExp(
      r'(<g[^>]*id="c"[^>]*>)([\s\S]*?)(</g>)',
      multiLine: true,
    );
    if (colorGroupPattern.hasMatch(output)) {
      output = output.replaceAllMapped(colorGroupPattern, (match) {
        final content = match.group(2) ?? '';
        final coloredContent = _replaceColorTokens(content, color);
        return '${match.group(1)}$coloredContent${match.group(3)}';
      });
    } else {
      output = _replaceColorTokens(output, color);
    }

    return output;
  }

  static String _replaceColorTokens(String svg, String color) {
    return svg
        .replaceAll(RegExp(r'#003670', caseSensitive: false), color)
        .replaceAll(RegExp(r'#3670', caseSensitive: false), color)
        .replaceAllMapped(
          RegExp("""fill=["']#[0-9a-fA-F]{3,8}["']"""),
          (match) =>
              match.group(0)!.contains('#fff') ||
                  match.group(0)!.contains('#FFF')
              ? match.group(0)!
              : 'fill="$color"',
        )
        .replaceAllMapped(
          RegExp(r'(fill:\s*)(#[0-9a-fA-F]{3,8})', caseSensitive: false),
          (match) => '${match.group(1)}$color',
        );
  }

  static MetroCityStyle? _inferCityFromFileName(String fileName) {
    if (fileName.startsWith('gz')) {
      return MetroCityStyle.guangzhou;
    }
    if (fileName.startsWith('mtr')) {
      return MetroCityStyle.mtr;
    }
    if (fileName.startsWith('jr')) {
      return MetroCityStyle.jr;
    }
    return null;
  }

  static String buildCustomLineSvg(MetroGuideItem item) {
    final lineCode = _escapeXml(
      item.customText?.cn.trim().isNotEmpty == true
          ? item.customText!.cn.trim()
          : 'XX',
    );
    final lineName = _escapeXml(
      item.customText?.en.trim().isNotEmpty == true
          ? item.customText!.en.trim()
          : 'Custom Line',
    );
    final lineColor = item.customColor ?? '#E4002B';

    if (item.type == GuideItemType.line) {
      return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 175 150">
  <rect x="4" y="4" width="167" height="142" rx="10" ry="10" fill="#0E1525" stroke="#FFFFFF" stroke-width="3"/>
  <rect x="0" y="110" width="175" height="40" fill="$lineColor"/>
  <circle cx="42" cy="75" r="28" fill="$lineColor" stroke="#FFFFFF" stroke-width="4"/>
  <text x="42" y="81" text-anchor="middle" fill="#FFFFFF" font-size="20" font-weight="700" font-family="Microsoft YaHei, Arial">$lineCode</text>
  <text x="88" y="66" fill="#FFFFFF" font-size="18" font-weight="700" font-family="Microsoft YaHei, Arial">$lineName</text>
  <text x="88" y="90" fill="#D9E1EA" font-size="10" font-weight="600" font-family="Arial">METRO LINE</text>
</svg>''';
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 185 150">
  <rect y="25" width="185" height="100" rx="8" ry="8" fill="$lineColor"/>
  <rect x="3" y="28" width="179" height="94" rx="6" ry="6" fill="none" stroke="#FFFFFF" stroke-width="3"/>
  <circle cx="38" cy="75" r="22" fill="#FFFFFF" fill-opacity="0.14" stroke="#FFFFFF" stroke-width="3"/>
  <text x="38" y="81" text-anchor="middle" fill="#FFFFFF" font-size="18" font-weight="700" font-family="Microsoft YaHei, Arial">$lineCode</text>
  <text x="70" y="70" fill="#FFFFFF" font-size="18" font-weight="700" font-family="Microsoft YaHei, Arial">$lineName</text>
  <text x="70" y="92" fill="#F3F6F9" font-size="10" font-weight="600" font-family="Arial">CLASSIC LINE</text>
</svg>''';
  }

  static String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
