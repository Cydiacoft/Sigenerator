import 'package:flutter/material.dart';

class RoadBoardTemplateSpec {
  const RoadBoardTemplateSpec({
    required this.id,
    required this.name,
    required this.canvasSize,
    required this.slots,
    this.backgroundSvgAsset,
    this.headerColor,
    this.headerRatio,
  });

  final String id;
  final String name;
  final Size canvasSize;
  final Map<String, RoadBoardSlotSpec> slots;
  final String? backgroundSvgAsset;
  final Color? headerColor;
  final double? headerRatio;

  factory RoadBoardTemplateSpec.fromJson(Map<String, dynamic> json) {
    final canvas =
        (json['canvasSize'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final slotList = (json['slots'] as List?)?.cast<Map>() ?? const <Map>[];
    final slots = <String, RoadBoardSlotSpec>{};
    for (final raw in slotList) {
      final slot = RoadBoardSlotSpec.fromJson(raw.cast<String, dynamic>());
      slots[slot.id] = slot;
    }
    return RoadBoardTemplateSpec(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      canvasSize: Size(
        (canvas['width'] as num?)?.toDouble() ?? 0,
        (canvas['height'] as num?)?.toDouble() ?? 0,
      ),
      slots: slots,
      backgroundSvgAsset:
          (json['backgroundSvgAsset'] as String?)?.trim().isEmpty == true
          ? null
          : json['backgroundSvgAsset'] as String?,
      headerColor: _parseHexColor(json['headerColor'] as String?),
      headerRatio: (json['headerRatio'] as num?)?.toDouble(),
    );
  }
}

class RoadBoardSlotSpec {
  const RoadBoardSlotSpec({
    required this.id,
    required this.rect,
    this.fontSize,
    this.useWhiteBox = false,
    this.useScenicBorder = false,
  });

  final String id;
  final Rect rect;
  final double? fontSize;
  final bool useWhiteBox;
  final bool useScenicBorder;

  factory RoadBoardSlotSpec.fromJson(Map<String, dynamic> json) {
    final rect =
        (json['rect'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return RoadBoardSlotSpec(
      id: (json['id'] ?? '').toString(),
      rect: Rect.fromLTWH(
        (rect['x'] as num?)?.toDouble() ?? 0,
        (rect['y'] as num?)?.toDouble() ?? 0,
        (rect['width'] as num?)?.toDouble() ?? 0,
        (rect['height'] as num?)?.toDouble() ?? 0,
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      useWhiteBox: json['useWhiteBox'] == true,
      useScenicBorder: json['useScenicBorder'] == true,
    );
  }
}

class RoadBoardTemplates {
  static const String standardCrossroadId = 'standard_crossroad';
  static const String placeDistanceId = 'place_distance';
  static const String placeDistanceMultilineId = 'place_distance_multiline';
  static const String serviceDistanceId = 'service_distance';
  static const String serviceAdvanceId = 'service_advance';
  static const String routeNumberId = 'route_number';
  static const String freeComposeId = 'free_compose';

  static const RoadBoardTemplateSpec standardCrossroad = RoadBoardTemplateSpec(
    id: standardCrossroadId,
    name: 'Standard Crossroad Guide Board',
    canvasSize: Size(1020, 496),
    slots: {
      'topLeft': RoadBoardSlotSpec(
        id: 'topLeft',
        rect: Rect.fromLTWH(22, 18, 134, 82),
        fontSize: 30,
        useWhiteBox: true,
      ),
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(186, 18, 404, 84),
        fontSize: 40,
      ),
      'topRight': RoadBoardSlotSpec(
        id: 'topRight',
        rect: Rect.fromLTWH(790, 18, 192, 80),
        fontSize: 22,
        useWhiteBox: true,
      ),
      'centerLeft': RoadBoardSlotSpec(
        id: 'centerLeft',
        rect: Rect.fromLTWH(22, 128, 294, 92),
        fontSize: 38,
      ),
      'center': RoadBoardSlotSpec(
        id: 'center',
        rect: Rect.fromLTWH(414, 110, 192, 170),
      ),
      'centerRight': RoadBoardSlotSpec(
        id: 'centerRight',
        rect: Rect.fromLTWH(692, 128, 290, 92),
        fontSize: 38,
      ),
      'bottomLeft': RoadBoardSlotSpec(
        id: 'bottomLeft',
        rect: Rect.fromLTWH(22, 344, 254, 64),
        fontSize: 18,
        useWhiteBox: true,
        useScenicBorder: true,
      ),
      'bottomCenter': RoadBoardSlotSpec(
        id: 'bottomCenter',
        rect: Rect.fromLTWH(432, 354, 194, 66),
        fontSize: 36,
      ),
      'bottomRight': RoadBoardSlotSpec(
        id: 'bottomRight',
        rect: Rect.fromLTWH(790, 344, 192, 64),
        fontSize: 18,
        useWhiteBox: true,
      ),
    },
  );

  static const RoadBoardTemplateSpec placeDistance = RoadBoardTemplateSpec(
    id: placeDistanceId,
    name: 'Place Distance Board',
    canvasSize: Size(1020, 502),
    backgroundSvgAsset:
        'assets/road_signs_info/svg/China_road_sign_\u8def_17a.svg',
    slots: {
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(82, 114, 611, 277),
      ),
      'topRight': RoadBoardSlotSpec(
        id: 'topRight',
        rect: Rect.fromLTWH(692, 114, 246, 277),
      ),
    },
  );

  static const RoadBoardTemplateSpec placeDistanceMultiline =
      RoadBoardTemplateSpec(
        id: placeDistanceMultilineId,
        name: 'Place Distance Multi-line Board',
        canvasSize: Size(1020, 843),
        backgroundSvgAsset:
            'assets/road_signs_info/svg/China_road_sign_\u8def_16.svg',
        slots: {
          'topCenter': RoadBoardSlotSpec(
            id: 'topCenter',
            rect: Rect.fromLTWH(60, 351, 651, 200),
          ),
          'topRight': RoadBoardSlotSpec(
            id: 'topRight',
            rect: Rect.fromLTWH(727, 351, 230, 200),
          ),
          'bottomCenter': RoadBoardSlotSpec(
            id: 'bottomCenter',
            rect: Rect.fromLTWH(60, 591, 902, 180),
          ),
        },
      );

  static const RoadBoardTemplateSpec serviceDistance = RoadBoardTemplateSpec(
    id: serviceDistanceId,
    name: 'Service Distance Board',
    canvasSize: Size(480, 260),
    slots: {
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(40, 20, 400, 100),
      ),
      'centerLeft': RoadBoardSlotSpec(
        id: 'centerLeft',
        rect: Rect.fromLTWH(40, 130, 280, 100),
      ),
      'centerRight': RoadBoardSlotSpec(
        id: 'centerRight',
        rect: Rect.fromLTWH(340, 130, 100, 100),
      ),
    },
  );

  static const RoadBoardTemplateSpec routeNumber = RoadBoardTemplateSpec(
    id: routeNumberId,
    name: 'Route Number Board',
    canvasSize: Size(470, 452),
    backgroundSvgAsset:
        'assets/road_signs_prc/svg/China_Expressway_Sign_without_number.svg',
    slots: {
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(40, 34, 390, 72),
      ),
      'center': RoadBoardSlotSpec(
        id: 'center',
        rect: Rect.fromLTWH(38, 128, 394, 186),
      ),
      'bottomCenter': RoadBoardSlotSpec(
        id: 'bottomCenter',
        rect: Rect.fromLTWH(48, 334, 374, 84),
      ),
    },
  );

  static const RoadBoardTemplateSpec serviceAdvance = RoadBoardTemplateSpec(
    id: serviceAdvanceId,
    name: 'Service And Parking Advance Board',
    canvasSize: Size(480, 260),
    slots: {
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(40, 20, 400, 100),
      ),
      'centerLeft': RoadBoardSlotSpec(
        id: 'centerLeft',
        rect: Rect.fromLTWH(40, 130, 280, 100),
      ),
      'centerRight': RoadBoardSlotSpec(
        id: 'centerRight',
        rect: Rect.fromLTWH(340, 130, 100, 100),
      ),
    },
  );

  static const RoadBoardTemplateSpec freeCompose = RoadBoardTemplateSpec(
    id: freeComposeId,
    name: 'Free Compose Board',
    canvasSize: Size(1020, 496),
    slots: {
      'topLeft': RoadBoardSlotSpec(
        id: 'topLeft',
        rect: Rect.fromLTWH(24, 20, 140, 80),
        fontSize: 30,
        useWhiteBox: true,
      ),
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(184, 20, 402, 80),
        fontSize: 34,
      ),
      'topRight': RoadBoardSlotSpec(
        id: 'topRight',
        rect: Rect.fromLTWH(700, 20, 286, 80),
        fontSize: 22,
        useWhiteBox: true,
      ),
      'centerLeft': RoadBoardSlotSpec(
        id: 'centerLeft',
        rect: Rect.fromLTWH(24, 124, 300, 96),
        fontSize: 34,
      ),
      'center': RoadBoardSlotSpec(
        id: 'center',
        rect: Rect.fromLTWH(416, 108, 190, 172),
      ),
      'centerRight': RoadBoardSlotSpec(
        id: 'centerRight',
        rect: Rect.fromLTWH(690, 124, 300, 96),
        fontSize: 34,
      ),
      'bottomLeft': RoadBoardSlotSpec(
        id: 'bottomLeft',
        rect: Rect.fromLTWH(30, 336, 284, 72),
        fontSize: 20,
        useWhiteBox: true,
      ),
      'bottomCenter': RoadBoardSlotSpec(
        id: 'bottomCenter',
        rect: Rect.fromLTWH(398, 350, 228, 66),
        fontSize: 30,
      ),
      'bottomRight': RoadBoardSlotSpec(
        id: 'bottomRight',
        rect: Rect.fromLTWH(700, 336, 284, 72),
        fontSize: 20,
        useWhiteBox: true,
      ),
    },
  );

  static const List<RoadBoardTemplateSpec> _fallbackAll =
      <RoadBoardTemplateSpec>[
        standardCrossroad,
        placeDistance,
        placeDistanceMultiline,
        serviceDistance,
        serviceAdvance,
        routeNumber,
        freeCompose,
      ];

  static List<RoadBoardTemplateSpec> _runtimeAll = _fallbackAll;

  static List<RoadBoardTemplateSpec> get all => _runtimeAll;

  static void replaceAll(List<RoadBoardTemplateSpec> templates) {
    if (templates.isEmpty) return;
    _runtimeAll = templates;
  }

  static void resetToFallback() {
    _runtimeAll = _fallbackAll;
  }

  static List<RoadBoardTemplateSpec> fromRegistryJson(
    Map<String, dynamic> json,
  ) {
    final rawTemplates =
        (json['templates'] as List?)?.cast<Map>() ?? const <Map>[];
    final parsed = <RoadBoardTemplateSpec>[];
    for (final raw in rawTemplates) {
      final spec = RoadBoardTemplateSpec.fromJson(raw.cast<String, dynamic>());
      if (spec.id.isEmpty || spec.slots.isEmpty) continue;
      parsed.add(spec);
    }
    return parsed;
  }

  static RoadBoardTemplateSpec? byId(String id) {
    for (final template in all) {
      if (template.id == id) return template;
    }
    return null;
  }
}

Color? _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceFirst('#', '').trim();
  if (cleaned.length != 6 && cleaned.length != 8) return null;
  final value = int.tryParse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  if (value == null) return null;
  return Color(value);
}
