import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/intersection_scene.dart';

class ExportUtils {
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> saveImage(
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/traffic_signs';
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('$path/$filename');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> exportAllSigns(
    GlobalKey northKey,
    GlobalKey eastKey,
    GlobalKey southKey,
    GlobalKey westKey,
    IntersectionScene scene,
  ) async {
    final paths = <String>[];

    final directions = ['north', 'east', 'south', 'west'];
    final keys = [northKey, eastKey, southKey, westKey];

    for (int i = 0; i < 4; i++) {
      final bytes = await captureWidget(keys[i]);
      if (bytes != null) {
        final filename =
            '${scene.name.isEmpty ? "intersection" : scene.name}_${directions[i]}.png';
        final path = await saveImage(bytes, filename);
        if (path != null) {
          paths.add(path);
        }
      }
    }

    return paths;
  }

  static Future<List<String>> exportAllSvg(IntersectionScene scene) async {
    final paths = <String>[];
    final directions = ['north', 'east', 'south', 'west'];

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/road_signs_svg';
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      for (final direction in directions) {
        final svg = _generateSvg(scene, direction);
        final filename =
            '${scene.name.isEmpty ? "intersection" : scene.name}_$direction.svg';
        final file = File('$path/$filename');
        await file.writeAsString(svg);
        paths.add(file.path);
      }
    } catch (e) {
      return [];
    }

    return paths;
  }

  static String _generateSvg(IntersectionScene scene, String direction) {
    final info = scene.directionInfo(direction);
    final bgColor = _colorToHex(_getGuideColor(scene, info));
    final fgColor = _colorToHex(scene.foregroundColor);
    
    return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500">
  <rect x="0" y="0" width="400" height="500" rx="18" fill="$bgColor" stroke="$fgColor" stroke-width="6"/>
  <rect x="18" y="18" width="364" height="464" rx="10" fill="rgba(0,0,0,0.12)"/>
  <text x="40" y="70" fill="$fgColor" font-size="24" font-weight="bold">${_getDirectionLabel(scene, direction)}</text>
  <rect x="280" y="45" width="70" height="25" rx="12" fill="rgba(255,255,255,0.16)"/>
  <text x="315" y="63" fill="$fgColor" font-size="14" font-weight="bold" text-anchor="middle">${_roadTypeLabel(info.roadType)}</text>
  <text x="40" y="95" fill="$fgColor" font-size="14" opacity="0.88">${scene.name.isEmpty ? '未命名路口' : scene.name}</text>
  <rect x="40" y="140" width="100" height="180" rx="10" fill="rgba(255,255,255,0.96)"/>
  <rect x="280" y="140" width="80" height="180" rx="10" fill="rgba(255,255,255,0.1)"/>
  ${_drawArrowSvg(direction, fgColor)}
  <text x="150" y="180" fill="$fgColor" font-size="32" font-weight="bold">${info.destination.isEmpty ? '请输入通往地点' : info.destination}</text>
  <line x1="150" y1="240" x2="350" y2="240" stroke="$fgColor" stroke-width="2" opacity="0.25"/>
  <text x="150" y="265" fill="$fgColor" font-size="22" opacity="0.96">${info.roadName.isEmpty ? '请输入道路名称' : info.roadName}</text>
  <rect x="40" y="360" width="340" height="50" rx="8" fill="rgba(0,0,0,0.12)"/>
  <text x="55" y="390" fill="$fgColor" font-size="14" font-weight="bold">${_destinationTypeLabel(info.destinationType)}</text>
  <text x="175" y="390" fill="$fgColor" font-size="14" opacity="0.92">${_shapeLabel(scene.intersectionShape)}</text>
  <text x="310" y="390" fill="$fgColor" font-size="14" opacity="0.9">${info.signIds.length} 个关联元素</text>
  <rect x="40" y="430" width="340" height="45" rx="8" fill="rgba(255,255,255,0.06)"/>
  <text x="55" y="455" fill="$fgColor" font-size="12" opacity="0.82">${info.signIds.isEmpty ? '当前未挂接路标元素' : '当前方向已挂接 ${info.signIds.length} 个路标元素'}</text>
</svg>''';
  }

  static String _drawArrowSvg(String direction, String color) {
    return switch (direction) {
      'north' => '<path d="M320 280 L320 180 L280 230 M320 180 L360 230" stroke="$color" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      'south' => '<path d="M320 180 L320 280 L280 230 M320 280 L360 230" stroke="$color" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      'east' => '<path d="M230 230 L330 230 L280 190 M330 230 L280 270" stroke="$color" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      'west' => '<path d="M370 230 L270 230 L320 190 M270 230 L320 270" stroke="$color" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      _ => '',
    };
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  static Color _getGuideColor(IntersectionScene scene, DirectionInfo info) {
    switch (info.destinationType) {
      case DestinationType.highway:
        return scene.highwayColor;
      case DestinationType.scenic:
        return scene.scenicColor;
      case DestinationType.general:
        return switch (info.roadType) {
          RoadType.highway => scene.highwayColor,
          RoadType.scenic => scene.scenicColor,
          RoadType.general => scene.backgroundColor,
        };
    }
  }

  static String _getDirectionLabel(IntersectionScene scene, String direction) {
    return switch (scene.directionWordMode) {
      DirectionWordMode.chinese => switch (direction) {
          'north' => '北向',
          'east' => '东向',
          'south' => '南向',
          'west' => '西向',
          _ => '北向',
        },
      DirectionWordMode.english => switch (direction) {
          'north' => 'NORTH',
          'east' => 'EAST',
          'south' => 'SOUTH',
          'west' => 'WEST',
          _ => 'NORTH',
        },
      DirectionWordMode.custom => scene.customDirectionWords[direction] ?? 'N',
    };
  }

  static String _roadTypeLabel(RoadType type) {
    return switch (type) {
      RoadType.general => '普通',
      RoadType.highway => '高速',
      RoadType.scenic => '景区',
    };
  }

  static String _destinationTypeLabel(DestinationType type) {
    return switch (type) {
      DestinationType.general => '普通道路方向',
      DestinationType.highway => '高速方向',
      DestinationType.scenic => '景区方向',
    };
  }

  static String _shapeLabel(IntersectionShape shape) {
    return switch (shape) {
      IntersectionShape.crossroad => '十字路口',
      IntersectionShape.skewLeft => '左高右低',
      IntersectionShape.skewRight => '左低右高',
      IntersectionShape.skewForwardLeft => '前路偏左',
      IntersectionShape.skewForwardRight => '前路偏右',
      IntersectionShape.roundabout => '环岛',
      IntersectionShape.tJunctionFrontLeft => '丁字路口(前+左)',
      IntersectionShape.tJunctionFrontRight => '丁字路口(前+右)',
      IntersectionShape.tJunctionLeftRight => '丁字路口(左+右)',
      IntersectionShape.yJunction => '三岔路口',
      IntersectionShape.diamondBridgeHighTop => '菱形桥(高级,在上)',
      IntersectionShape.diamondBridgeHighBottom => '菱形桥(高级,在下)',
      IntersectionShape.diamondBridgeLowTop => '菱形桥(低级,在上)',
      IntersectionShape.diamondBridgeLowBottom => '菱形桥(低级,在下)',
      IntersectionShape.cloverleafBridgeDoubleTop => '苜蓿叶形桥(双出口,在上)',
      IntersectionShape.cloverleafBridgeDoubleBottom => '苜蓿叶形桥(双出口,在下)',
      IntersectionShape.cloverleafBridgeSingleTop => '苜蓿叶形桥(单出口,在上)',
      IntersectionShape.cloverleafBridgeSingleBottom => '苜蓿叶形桥(单出口,在下)',
      IntersectionShape.spiralBridgeDoubleTop => '漩涡形桥(双出口,在上)',
      IntersectionShape.spiralBridgeDoubleBottom => '漩涡形桥(双出口,在下)',
      IntersectionShape.spiralBridgeSingleTop => '漩涡形桥(单出口,在上)',
      IntersectionShape.spiralBridgeSingleBottom => '漩涡形桥(单出口,在下)',
      IntersectionShape.roundaboutBridgeTop => '环岛桥(在上)',
      IntersectionShape.roundaboutBridgeBottom => '环岛桥(在下)',
      IntersectionShape.leftLongRightShort => '左长右短',
      IntersectionShape.rightLongLeftShort => '右长左短',
      IntersectionShape.leftRightLongFrontShort => '左右长前短',
    };
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.title,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late TextEditingController _hexController;
  late Color _selectedColor;

  final List<Color> _presetColors = [
    const Color(0xFF1A1A2E),
    const Color(0xFF16213E),
    const Color(0xFF0F3460),
    const Color(0xFF533483),
    const Color(0xFFE94560),
    const Color(0xFFFFD700),
    const Color(0xFF4A90A4),
    const Color(0xFF2ECC71),
    const Color(0xFFE74C3C),
    const Color(0xFF3498DB),
    const Color(0xFF9B59B6),
    const Color(0xFF1ABC9C),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _hexController = TextEditingController(text: _colorToHex(_selectedColor));
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  bool get _isLightColor {
    final r = _selectedColor.r;
    final g = _selectedColor.g;
    final b = _selectedColor.b;
    return (r * 0.299 + g * 0.587 + b * 0.114) > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isLightColor ? Colors.black : Colors.white;
    
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((color) {
                final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      _hexController.text = _colorToHex(color);
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _hexController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'HEX颜色值',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF475569)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
                prefixText: '#',
                prefixStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
              ),
              onChanged: (value) {
                try {
                  setState(() {
                    _selectedColor = _hexToColor(value);
                  });
                } catch (_) {}
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white54, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _colorToHex(_selectedColor),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  child: const Text('确认'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
