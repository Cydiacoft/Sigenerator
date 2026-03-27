enum GuideItemType { line, way, stn, oth, sub, text, cls, clss }

class GuideItemTypeNames {
  static const Map<GuideItemType, String> names = {
    GuideItemType.line: '线路',
    GuideItemType.way: '方向与站台',
    GuideItemType.stn: '车站设施',
    GuideItemType.oth: '字母与其他',
    GuideItemType.sub: '色带信息',
    GuideItemType.text: '文本框',
    GuideItemType.cls: '经典素材',
    GuideItemType.clss: '经典线路标',
  };

  static String getName(GuideItemType type) => names[type] ?? type.name;
}

enum TextAlignment { start, middle, end }

class MetroGuideItem {
  final String id;
  final String fileName;
  final GuideItemType type;
  final String? customUrl;
  final String? customSvgContent;
  final CustomText? customText;
  final String? customColor;
  final bool hasColorBand;
  final String? colorBandColor;

  MetroGuideItem({
    String? id,
    required this.fileName,
    required this.type,
    this.customUrl,
    this.customSvgContent,
    this.customText,
    this.customColor,
    this.hasColorBand = false,
    this.colorBandColor,
  }) : id =
           id ?? DateTime.now().millisecondsSinceEpoch.toString() + _randomId();

  static String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for (var i = 0; i < 9; i++) {
      result +=
          chars[(DateTime.now().microsecondsSinceEpoch + i * 7) % chars.length];
    }
    return result;
  }

  MetroGuideItem copyWith({
    String? id,
    String? fileName,
    GuideItemType? type,
    String? customUrl,
    String? customSvgContent,
    CustomText? customText,
    String? customColor,
    bool? hasColorBand,
    String? colorBandColor,
  }) {
    return MetroGuideItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      type: type ?? this.type,
      customUrl: customUrl ?? this.customUrl,
      customSvgContent: customSvgContent ?? this.customSvgContent,
      customText: customText ?? this.customText,
      customColor: customColor ?? this.customColor,
      hasColorBand: hasColorBand ?? this.hasColorBand,
      colorBandColor: colorBandColor ?? this.colorBandColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'type': type.name,
      'customUrl': customUrl,
      'customSvgContent': customSvgContent,
      'customText': customText?.toJson(),
      'customColor': customColor,
      'hasColorBand': hasColorBand,
      'colorBandColor': colorBandColor,
    };
  }

  factory MetroGuideItem.fromJson(Map<String, dynamic> json) {
    return MetroGuideItem(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      type: GuideItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GuideItemType.oth,
      ),
      customUrl: json['customUrl'] as String?,
      customSvgContent: json['customSvgContent'] as String?,
      customText: json['customText'] != null
          ? CustomText.fromJson(json['customText'] as Map<String, dynamic>)
          : null,
      customColor: json['customColor'] as String?,
      hasColorBand: json['hasColorBand'] as bool? ?? false,
      colorBandColor: json['colorBandColor'] as String?,
    );
  }
}

class CustomText {
  final String cn;
  final String en;
  final TextAlignment alignment;

  const CustomText({
    required this.cn,
    required this.en,
    this.alignment = TextAlignment.start,
  });

  Map<String, dynamic> toJson() {
    return {'cn': cn, 'en': en, 'alignment': alignment.name};
  }

  factory CustomText.fromJson(Map<String, dynamic> json) {
    return CustomText(
      cn: json['cn'] as String,
      en: json['en'] as String,
      alignment: TextAlignment.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlignment.start,
      ),
    );
  }

  CustomText copyWith({String? cn, String? en, TextAlignment? alignment}) {
    return CustomText(
      cn: cn ?? this.cn,
      en: en ?? this.en,
      alignment: alignment ?? this.alignment,
    );
  }
}

class GuideItemAssets {
  static const List<GuideItemType> orderedTypes = [
    GuideItemType.line,
    GuideItemType.way,
    GuideItemType.stn,
    GuideItemType.oth,
    GuideItemType.sub,
    GuideItemType.cls,
    GuideItemType.clss,
  ];

  static const Map<String, List<String>> lineItemsByCity = {
    'shanghai': [
      'line@01.svg',
      'line@02.svg',
      'line@03.svg',
      'line@04.svg',
      'line@05.svg',
      'line@06.svg',
      'line@07.svg',
      'line@08.svg',
      'line@09.svg',
      'line@10.svg',
      'line@11.svg',
      'line@12.svg',
      'line@13.svg',
      'line@14.svg',
      'line@15.svg',
      'line@16.svg',
      'line@17.svg',
      'line@18.svg',
      'line@19.svg',
      'line@20.svg',
      'line@21.svg',
      'line@22.svg',
      'line@23.svg',
      'line@24.svg',
      'line@25.svg',
      'line@26.svg',
      'line@27.svg',
      'line@28.svg',
      'line@29.svg',
      'line@30.svg',
      'line@31.svg',
    ],
    'beijing': [
      'line@01.svg',
      'line@02.svg',
      'line@03.svg',
      'line@04.svg',
      'line@05.svg',
      'line@06.svg',
      'line@07.svg',
      'line@08.svg',
      'line@09.svg',
      'line@10.svg',
      'line@11.svg',
      'line@12.svg',
      'line@13.svg',
      'line@14.svg',
      'line@15.svg',
      'line@16.svg',
      'line@17.svg',
      'line@18.svg',
      'line@19.svg',
      'line@20.svg',
      'line@21.svg',
      'line@22.svg',
      'line@23.svg',
      'line@24.svg',
      'line@25.svg',
      'line@26.svg',
      'line@27.svg',
      'line@28.svg',
      'line@29.svg',
      'line@30.svg',
    ],
    'guangzhou': [
      'gz01.svg',
      'gz02.svg',
      'gz03.svg',
      'gz04.svg',
      'gz05.svg',
      'gz06.svg',
      'gz07.svg',
      'gz08.svg',
      'gz09.svg',
      'gz13.svg',
      'gz14.svg',
      'gzGF.svg',
      'gzAPM.svg',
    ],
    'mtr': [
      'mtr1.svg',
      'mtr2.svg',
      'mtr3.svg',
      'mtr4.svg',
      'mtr5.svg',
      'mtr6.svg',
      'mtr7.svg',
      'mtr8.svg',
      'mtr9.svg',
      'mtr10.svg',
      'mtr11.svg',
    ],
    'jr': [
      'jr01.svg',
      'jr02.svg',
      'jr03.svg',
      'jr04.svg',
      'jr05.svg',
      'jr06.svg',
      'jr07.svg',
      'jr08.svg',
    ],
  };

  static const Map<String, List<String>> clssItemsByCity = {
    'shanghai': [
      'clss@01.svg',
      'clss@02.svg',
      'clss@03.svg',
      'clss@04.svg',
      'clss@05.svg',
      'clss@06.svg',
      'clss@07.svg',
      'clss@08.svg',
      'clss@09.svg',
      'clss@10.svg',
      'clss@11.svg',
      'clss@12.svg',
      'clss@13.svg',
      'clss@14.svg',
      'clss@15.svg',
      'clss@16.svg',
      'clss@17.svg',
      'clss@18.svg',
      'clss@19.svg',
      'clss@20.svg',
      'clss@21.svg',
      'clss@22.svg',
      'clss@23.svg',
      'clss@24.svg',
      'clss@25.svg',
      'clss@26.svg',
      'clss@27.svg',
      'clss@28.svg',
      'clss@29.svg',
      'clss@30.svg',
      'clss@31.svg',
    ],
    'beijing': [
      'clss@01.svg',
      'clss@02.svg',
      'clss@03.svg',
      'clss@04.svg',
      'clss@05.svg',
      'clss@06.svg',
      'clss@07.svg',
      'clss@08.svg',
      'clss@09.svg',
      'clss@10.svg',
      'clss@11.svg',
      'clss@12.svg',
      'clss@13.svg',
      'clss@14.svg',
      'clss@15.svg',
      'clss@16.svg',
      'clss@17.svg',
      'clss@18.svg',
      'clss@19.svg',
      'clss@20.svg',
      'clss@21.svg',
      'clss@22.svg',
      'clss@23.svg',
      'clss@24.svg',
      'clss@25.svg',
      'clss@26.svg',
      'clss@27.svg',
      'clss@28.svg',
      'clss@29.svg',
      'clss@30.svg',
      'clss@31.svg',
    ],
    'guangzhou': [
      'gz01.svg',
      'gz02.svg',
      'gz03.svg',
      'gz04.svg',
      'gz05.svg',
      'gz06.svg',
      'gz07.svg',
      'gz08.svg',
      'gz09.svg',
      'gz13.svg',
      'gz14.svg',
      'gzGF.svg',
      'gzAPM.svg',
    ],
    'mtr': [
      'mtr1.svg',
      'mtr2.svg',
      'mtr3.svg',
      'mtr4.svg',
      'mtr5.svg',
      'mtr6.svg',
      'mtr7.svg',
      'mtr8.svg',
      'mtr9.svg',
      'mtr10.svg',
      'mtr11.svg',
    ],
    'jr': [
      'jr01.svg',
      'jr02.svg',
      'jr03.svg',
      'jr04.svg',
      'jr05.svg',
      'jr06.svg',
      'jr07.svg',
      'jr08.svg',
    ],
  };

  static List<String> getLineItems(String city) {
    return lineItemsByCity[city] ?? lineItemsByCity['shanghai']!;
  }

  static List<String> getClssItems(String city) {
    return clssItemsByCity[city] ?? clssItemsByCity['shanghai']!;
  }

  static const List<String> lineItems = [
    'line@01.svg',
    'line@02.svg',
    'line@03.svg',
    'line@04.svg',
    'line@05.svg',
    'line@06.svg',
    'line@07.svg',
    'line@08.svg',
    'line@09.svg',
    'line@10.svg',
    'line@11.svg',
    'line@12.svg',
    'line@13.svg',
    'line@14.svg',
    'line@15.svg',
    'line@16.svg',
    'line@17.svg',
    'line@18.svg',
    'line@19.svg',
    'line@20.svg',
    'line@21.svg',
    'line@22.svg',
    'line@23.svg',
    'line@24.svg',
    'line@25.svg',
    'line@26.svg',
    'line@27.svg',
    'line@28.svg',
    'line@29.svg',
    'line@30.svg',
    'line@31.svg',
  ];

  static const List<String> wayItems = [
    'way@01.svg',
    'way@02.svg',
    'way@03.svg',
    'way@04.svg',
    'way@05.svg',
    'way@06.svg',
    'way@07.svg',
    'way@08.svg',
    'way@09.svg',
    'way@10.svg',
    'way@11.svg',
    'way@12.svg',
    'way@13.svg',
    'way@14.svg',
    'way@15.svg',
    'way@16.svg',
    'way@17.svg',
    'way@18.svg',
    'way@19.svg',
    'way@20.svg',
    'way@21.svg',
    'way@22.svg',
    'way@23.svg',
    'way@24.svg',
    'way@25.svg',
    'way@26.svg',
  ];

  static const List<String> stnItems = [
    'stn@01.svg',
    'stn@02.svg',
    'stn@03.svg',
    'stn@04.svg',
    'stn@05.svg',
    'stn@06.svg',
    'stn@07.svg',
    'stn@08.svg',
    'stn@09.svg',
    'stn@10.svg',
    'stn@11.svg',
    'stn@12.svg',
    'stn@13.svg',
    'stn@14.svg',
    'stn@15.svg',
    'stn@16.svg',
    'stn@17.svg',
    'stn@18.svg',
    'stn@19.svg',
    'stn@20.svg',
    'stn@21.svg',
    'stn@22.svg',
    'stn@23.svg',
    'stn@24.svg',
    'stn@25.svg',
    'stn@26.svg',
    'stn@27.svg',
    'stn@28.svg',
    'stn@29.svg',
  ];

  static const List<String> othItems = [
    'oth@01.svg',
    'oth@02.svg',
    'oth@03.svg',
    'oth@04.svg',
    'oth@05.svg',
    'oth@06.svg',
    'oth@07.svg',
    'oth@08.svg',
    'oth@09.svg',
    'oth@10.svg',
    'oth@11.svg',
    'oth@12.svg',
    'oth@13.svg',
    'oth@14.svg',
    'oth@15.svg',
    'oth@16.svg',
    'oth@17.svg',
    'oth@18.svg',
    'oth@19.svg',
    'oth@20.svg',
    'oth@21.svg',
    'oth@22.svg',
    'oth@23.svg',
    'oth@24.svg',
    'oth@25.svg',
    'oth@26.svg',
    'oth@27.svg',
    'oth@28.svg',
    'oth@29.svg',
    'oth@30.svg',
    'oth@A.svg',
    'oth@Dot.svg',
    'oth@space.svg',
    'oth@yl.svg',
    'oth@one.svg',
    'oth@two.svg',
    'oth@thr.svg',
    'oth@fou.svg',
  ];

  static const List<String> subItems = [
    'sub@exit.svg',
    'sub@text.svg',
    'sub@03.svg',
    'sub@04.svg',
    'sub@05.svg',
    'sub@06.svg',
    'sub@07.svg',
    'sub@08.svg',
    'sub@09.svg',
    'sub@10.svg',
    'sub@11.svg',
    'sub@12.svg',
    'sub@13.svg',
    'sub@14.svg',
    'sub@15.svg',
    'sub@16.svg',
    'sub@17.svg',
    'sub@18.svg',
    'sub@19.svg',
    'sub@20.svg',
    'sub@21.svg',
    'sub@space.svg',
    'sub@long.svg',
  ];

  static const List<String> clsItems = [
    'cls@01.svg',
    'cls@02.svg',
    'cls@03.svg',
    'cls@04.svg',
    'cls@05.svg',
    'cls@06.svg',
    'cls@07.svg',
    'cls@08.svg',
    'cls@09.svg',
    'cls@10.svg',
    'cls@11.svg',
    'cls@12.svg',
    'cls@13.svg',
    'cls@14.svg',
    'cls@15.svg',
    'cls@16.svg',
    'cls@17.svg',
    'cls@18.svg',
    'cls@19.svg',
    'cls@20.svg',
    'cls@21.svg',
    'cls@22.svg',
    'cls@23.svg',
    'cls@24.svg',
    'cls@25.svg',
    'cls@26.svg',
    'cls@27.svg',
    'cls@28.svg',
    'cls@29.svg',
    'cls@30.svg',
    'cls@31.svg',
    'cls@32.svg',
    'cls@33.svg',
    'cls@34.svg',
    'cls@35.svg',
    'cls@36.svg',
    'cls@37.svg',
  ];

  static const List<String> clssItems = [
    'clss@01.svg',
    'clss@02.svg',
    'clss@03.svg',
    'clss@04.svg',
    'clss@05.svg',
    'clss@06.svg',
    'clss@07.svg',
    'clss@08.svg',
    'clss@09.svg',
    'clss@10.svg',
    'clss@11.svg',
    'clss@12.svg',
    'clss@13.svg',
    'clss@14.svg',
    'clss@15.svg',
    'clss@16.svg',
    'clss@17.svg',
    'clss@18.svg',
    'clss@19.svg',
    'clss@20.svg',
    'clss@21.svg',
    'clss@22.svg',
    'clss@23.svg',
    'clss@24.svg',
    'clss@25.svg',
    'clss@26.svg',
    'clss@27.svg',
    'clss@28.svg',
    'clss@29.svg',
    'clss@30.svg',
    'clss@31.svg',
  ];

  static Map<GuideItemType, List<String>> groupedItemsByCity(String city) => {
    GuideItemType.line: getLineItems(city),
    GuideItemType.way: wayItems,
    GuideItemType.stn: stnItems,
    GuideItemType.oth: othItems,
    GuideItemType.sub: subItems,
    GuideItemType.cls: clsItems,
    GuideItemType.clss: getClssItems(city),
  };

  static Map<GuideItemType, List<String>> get groupedItems => {
    GuideItemType.line: lineItems,
    GuideItemType.way: wayItems,
    GuideItemType.stn: stnItems,
    GuideItemType.oth: othItems,
    GuideItemType.sub: subItems,
    GuideItemType.cls: clsItems,
    GuideItemType.clss: clssItems,
  };

  static GuideItemType getTypeFromFileName(String fileName) {
    final prefix = fileName.split('@').first;
    return GuideItemType.values.firstWhere(
      (type) => type.name == prefix,
      orElse: () => GuideItemType.oth,
    );
  }
}

class CanvasConfig {
  final List<MetroGuideItem> items;
  final String city;
  final DateTime lastModified;

  const CanvasConfig({
    required this.items,
    required this.city,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'city': city,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory CanvasConfig.fromJson(Map<String, dynamic> json) {
    return CanvasConfig(
      items: (json['items'] as List)
          .map(
            (entry) => MetroGuideItem.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      city: json['city'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }
}

class MetroGuideProject {
  final String name;
  final String? description;
  final String version;
  final String city;
  final String backgroundColor;
  final List<MetroGuideItem> items;
  final List<MetroGuideItem> customAssets;
  final DateTime createdAt;
  final DateTime lastModified;

  const MetroGuideProject({
    required this.name,
    this.description,
    this.version = '1.0.0',
    required this.city,
    this.backgroundColor = '#001D31',
    required this.items,
    this.customAssets = const [],
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'version': version,
      'city': city,
      'backgroundColor': backgroundColor,
      'items': items.map((item) => item.toJson()).toList(),
      'customAssets': customAssets.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory MetroGuideProject.fromJson(Map<String, dynamic> json) {
    return MetroGuideProject(
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as String? ?? '1.0.0',
      city: json['city'] as String,
      backgroundColor: json['backgroundColor'] as String? ?? '#001D31',
      items: (json['items'] as List)
          .map(
            (entry) => MetroGuideItem.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      customAssets: ((json['customAssets'] as List?) ?? const [])
          .map(
            (entry) => MetroGuideItem.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  MetroGuideProject copyWith({
    String? name,
    String? description,
    String? version,
    String? city,
    String? backgroundColor,
    List<MetroGuideItem>? items,
    List<MetroGuideItem>? customAssets,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return MetroGuideProject(
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      city: city ?? this.city,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      items: items ?? this.items,
      customAssets: customAssets ?? this.customAssets,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  static MetroGuideProject createNew({
    required String name,
    required String city,
    String? description,
  }) {
    final now = DateTime.now();
    return MetroGuideProject(
      name: name,
      description: description,
      city: city,
      items: const [],
      customAssets: const [],
      createdAt: now,
      lastModified: now,
    );
  }
}
