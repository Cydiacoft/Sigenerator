import 'package:flutter/material.dart';

enum MetroCity { shanghai, guangzhou, mtr, jr }

enum MetroCityStyle { shanghai, guangzhou, mtr, jr }

class MetroCityInfo {
  final MetroCityStyle style;
  final MetroCity city;
  final String name;
  final Color bgColor;
  final Color textColor;
  final double lineBadgeSize;
  final double lineBadgeFontSize;
  final double baseFontSize;
  final String fontFamily;

  const MetroCityInfo({
    required this.style,
    required this.city,
    required this.name,
    required this.bgColor,
    required this.textColor,
    required this.lineBadgeSize,
    required this.lineBadgeFontSize,
    required this.baseFontSize,
    required this.fontFamily,
  });

  Color get defaultBgColor => bgColor;

  static const shanghai = MetroCityInfo(
    style: MetroCityStyle.shanghai,
    city: MetroCity.shanghai,
    name: '上海地铁',
    bgColor: Color(0xFF001D31),
    textColor: Colors.white,
    lineBadgeSize: 60,
    lineBadgeFontSize: 22,
    baseFontSize: 14,
    fontFamily: 'Microsoft YaHei',
  );

  static const guangzhou = MetroCityInfo(
    style: MetroCityStyle.guangzhou,
    city: MetroCity.guangzhou,
    name: '广州地铁',
    bgColor: Color(0xFF001D31),
    textColor: Colors.white,
    lineBadgeSize: 55,
    lineBadgeFontSize: 20,
    baseFontSize: 14,
    fontFamily: 'Microsoft YaHei',
  );

  static const mtr = MetroCityInfo(
    style: MetroCityStyle.mtr,
    city: MetroCity.mtr,
    name: 'MTR',
    bgColor: Color(0xFF001D31),
    textColor: Colors.white,
    lineBadgeSize: 58,
    lineBadgeFontSize: 18,
    baseFontSize: 13,
    fontFamily: 'Arial',
  );

  static const jr = MetroCityInfo(
    style: MetroCityStyle.jr,
    city: MetroCity.jr,
    name: 'JR East',
    bgColor: Color(0xFF0F4C3A),
    textColor: Colors.white,
    lineBadgeSize: 58,
    lineBadgeFontSize: 18,
    baseFontSize: 13,
    fontFamily: 'Arial',
  );

  static const List<MetroCityInfo> all = [shanghai, guangzhou, mtr, jr];
}

class MetroLineInfo {
  final int num;
  final String name;
  final String nameEn;
  final Color color;
  final MetroCity city;

  const MetroLineInfo({
    required this.num,
    required this.name,
    required this.nameEn,
    required this.color,
    required this.city,
  });

  Color get lineColor => color;
  int get number => num;

  static List<MetroLineInfo> getLines(MetroCityStyle style) {
    switch (style) {
      case MetroCityStyle.shanghai:
        return shanghaiLines;
      case MetroCityStyle.guangzhou:
        return guangzhouLines;
      case MetroCityStyle.mtr:
        return mtrLines;
      case MetroCityStyle.jr:
        return jrLines;
    }
  }

  static const List<MetroLineInfo> shanghaiLines = [
    MetroLineInfo(
      num: 1,
      name: '1号线',
      nameEn: 'Line 1',
      color: Color(0xFFC23A30),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 2,
      name: '2号线',
      nameEn: 'Line 2',
      color: Color(0xFFC23A30),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 3,
      name: '3号线',
      nameEn: 'Line 3',
      color: Color(0xFF006098),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 4,
      name: '4号线',
      nameEn: 'Line 4',
      color: Color(0xFFE60033),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 5,
      name: '5号线',
      nameEn: 'Line 5',
      color: Color(0xFF008E9C),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 6,
      name: '6号线',
      nameEn: 'Line 6',
      color: Color(0xFF008E9C),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 7,
      name: '7号线',
      nameEn: 'Line 7',
      color: Color(0xFFA6217F),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 8,
      name: '8号线',
      nameEn: 'Line 8',
      color: Color(0xFFD29700),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 9,
      name: '9号线',
      nameEn: 'Line 9',
      color: Color(0xFFFAC671),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 10,
      name: '10号线',
      nameEn: 'Line 10',
      color: Color(0xFF009B6B),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 11,
      name: '11号线',
      nameEn: 'Line 11',
      color: Color(0xFF8FC31F),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 12,
      name: '12号线',
      nameEn: 'Line 12',
      color: Color(0xFF009BC0),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 13,
      name: '13号线',
      nameEn: 'Line 13',
      color: Color(0xFFED796B),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 14,
      name: '14号线',
      nameEn: 'Line 14',
      color: Color(0xFFC76B00),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 15,
      name: '15号线',
      nameEn: 'Line 15',
      color: Color(0xFFF9E700),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 16,
      name: '16号线',
      nameEn: 'Line 16',
      color: Color(0xFFD5A7A1),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 17,
      name: '17号线',
      nameEn: 'Line 17',
      color: Color(0xFF6A357D),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 18,
      name: '18号线',
      nameEn: 'Line 18',
      color: Color(0xFF76A32D),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 19,
      name: '19号线',
      nameEn: 'Line 19',
      color: Color(0xFF00A9A9),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 20,
      name: '20号线',
      nameEn: 'Line 20',
      color: Color(0xFFD6ABC1),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 21,
      name: '21号线',
      nameEn: 'Line 21',
      color: Color(0xFFF7C8CE),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 22,
      name: '22号线',
      nameEn: 'Line 22',
      color: Color(0xFF35570B),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 23,
      name: '23号线',
      nameEn: 'Line 23',
      color: Color(0xFFE40077),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 24,
      name: '24号线',
      nameEn: 'Line 24',
      color: Color(0xFFE46022),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 25,
      name: '25号线',
      nameEn: 'Line 25',
      color: Color(0xFFE46022),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 26,
      name: '26号线',
      nameEn: 'Line 26',
      color: Color(0xFFB25921),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 27,
      name: '27号线',
      nameEn: 'Line 27',
      color: Color(0xFFDE82B2),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 28,
      name: '28号线',
      nameEn: 'Line 28',
      color: Color(0xFFE6081B),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 29,
      name: '29号线',
      nameEn: 'Line 29',
      color: Color(0xFFE6081B),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 30,
      name: '30号线',
      nameEn: 'Line 30',
      color: Color(0xFFA29BBB),
      city: MetroCity.shanghai,
    ),
    MetroLineInfo(
      num: 31,
      name: '31号线',
      nameEn: 'Line 31',
      color: Color(0xFF004BA0),
      city: MetroCity.shanghai,
    ),
  ];

  static const List<MetroLineInfo> guangzhouLines = [
    MetroLineInfo(
      num: 1,
      name: '1号线',
      nameEn: 'Line 1',
      color: Color(0xFFF3D03E),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 2,
      name: '2号线',
      nameEn: 'Line 2',
      color: Color(0xFF00629B),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 3,
      name: '3号线',
      nameEn: 'Line 3',
      color: Color(0xFFECA154),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 4,
      name: '4号线',
      nameEn: 'Line 4',
      color: Color(0xFF00843D),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 5,
      name: '5号线',
      nameEn: 'Line 5',
      color: Color(0xFFC5003E),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 6,
      name: '6号线',
      nameEn: 'Line 6',
      color: Color(0xFF80225F),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 7,
      name: '7号线',
      nameEn: 'Line 7',
      color: Color(0xFF97D700),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 8,
      name: '8号线',
      nameEn: 'Line 8',
      color: Color(0xFF008C95),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 9,
      name: '9号线',
      nameEn: 'Line 9',
      color: Color(0xFF71CC98),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 13,
      name: '13号线',
      nameEn: 'Line 13',
      color: Color(0xFF8E8C13),
      city: MetroCity.guangzhou,
    ),
    MetroLineInfo(
      num: 14,
      name: '14号线',
      nameEn: 'Line 14',
      color: Color(0xFF81312F),
      city: MetroCity.guangzhou,
    ),
  ];

  static const List<MetroLineInfo> mtrLines = [
    MetroLineInfo(
      num: 1,
      name: '东铁线',
      nameEn: 'East Rail Line',
      color: Color(0xFF007078),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 2,
      name: '荃湾线',
      nameEn: 'Tsuen Wan Line',
      color: Color(0xFFEFA540),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 3,
      name: '观塘线',
      nameEn: 'Kwun Tong Line',
      color: Color(0xFF80CC28),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 4,
      name: '港岛线',
      nameEn: 'Island Line',
      color: Color(0xFF7D5BBD),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 5,
      name: '东涌线',
      nameEn: 'Tung Chung Line',
      color: Color(0xFFF27E23),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 6,
      name: '迪士尼线',
      nameEn: 'Disneyland Resort Line',
      color: Color(0xFF1E6EB2),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 7,
      name: '南港岛线',
      nameEn: 'South Island Line',
      color: Color(0xFFEE2C74),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 8,
      name: '将军澳线',
      nameEn: 'Tseung Kwan O Line',
      color: Color(0xFFED7B23),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 9,
      name: '机场快线',
      nameEn: 'Airport Express',
      color: Color(0xFFA74629),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 10,
      name: '屯马线',
      nameEn: 'Tuen Ma Line',
      color: Color(0xFF4CB05E),
      city: MetroCity.mtr,
    ),
    MetroLineInfo(
      num: 11,
      name: '高速铁路',
      nameEn: 'High Speed Rail',
      color: Color(0xFF961A1E),
      city: MetroCity.mtr,
    ),
  ];

  static const List<MetroLineInfo> jrLines = [
    MetroLineInfo(
      num: 1,
      name: '山手线',
      nameEn: 'Yamanote Line',
      color: Color(0xFF7CC242),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 2,
      name: '中央线快速',
      nameEn: 'Chuo Rapid Line',
      color: Color(0xFFF15A22),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 3,
      name: '总武线',
      nameEn: 'Sobu Line',
      color: Color(0xFFFFD400),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 4,
      name: '京滨东北线',
      nameEn: 'Keihin-Tohoku Line',
      color: Color(0xFF00A7E3),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 5,
      name: '埼京线',
      nameEn: 'Saikyo Line',
      color: Color(0xFF00A040),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 6,
      name: '横须贺线',
      nameEn: 'Yokosuka Line',
      color: Color(0xFF1F2F6B),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 7,
      name: '京叶线',
      nameEn: 'Keiyo Line',
      color: Color(0xFFD40078),
      city: MetroCity.jr,
    ),
    MetroLineInfo(
      num: 8,
      name: '南武线',
      nameEn: 'Nambu Line',
      color: Color(0xFFFFC20E),
      city: MetroCity.jr,
    ),
  ];
}

class MetroTemplate {
  final String id;
  final String name;
  final MetroCity city;
  final Size canvasSize;
  final Color defaultBgColor;
  final List<MetroSlot> slots;

  const MetroTemplate({
    required this.id,
    required this.name,
    required this.city,
    required this.canvasSize,
    required this.defaultBgColor,
    required this.slots,
  });

  static List<MetroTemplate> getTemplates(MetroCity city) {
    return _templates
        .where((t) => t.city == city || t.city == MetroCity.shanghai)
        .toList();
  }

  static const List<MetroTemplate> _templates = [
    MetroTemplate(
      id: 'station',
      name: '站名牌',
      city: MetroCity.shanghai,
      canvasSize: Size(360, 90),
      defaultBgColor: Color(0xFF001D31),
      slots: [
        MetroSlot(id: 'line_badge', type: 'line', x: 15, y: 15, w: 60, h: 60),
        MetroSlot(
          id: 'name_cn',
          type: 'text',
          x: 90,
          y: 22,
          w: 250,
          h: 28,
          fontSize: 24,
        ),
        MetroSlot(
          id: 'name_en',
          type: 'text',
          x: 90,
          y: 52,
          w: 250,
          h: 22,
          fontSize: 12,
          color: Color(0xFF999999),
        ),
      ],
    ),
    MetroTemplate(
      id: 'direction',
      name: '方向指示牌',
      city: MetroCity.shanghai,
      canvasSize: Size(480, 120),
      defaultBgColor: Color(0xFF001D31),
      slots: [
        MetroSlot(id: 'arrow', type: 'arrow_right', x: 12, y: 35, w: 36, h: 50),
        MetroSlot(
          id: 'dest_cn',
          type: 'text',
          x: 58,
          y: 25,
          w: 200,
          h: 40,
          fontSize: 24,
        ),
        MetroSlot(
          id: 'dest_en',
          type: 'text',
          x: 58,
          y: 65,
          w: 200,
          h: 20,
          fontSize: 11,
          color: Color(0xFF999999),
        ),
        MetroSlot(
          id: 'next_cn',
          type: 'text',
          x: 290,
          y: 25,
          w: 175,
          h: 35,
          fontSize: 16,
        ),
        MetroSlot(
          id: 'next_en',
          type: 'text',
          x: 290,
          y: 60,
          w: 175,
          h: 18,
          fontSize: 10,
          color: Color(0xFF999999),
        ),
        MetroSlot(
          id: 'dist',
          type: 'text',
          x: 290,
          y: 85,
          w: 175,
          h: 18,
          fontSize: 10,
          color: Color(0xFF777777),
        ),
      ],
    ),
    MetroTemplate(
      id: 'exit',
      name: '出口信息牌',
      city: MetroCity.shanghai,
      canvasSize: Size(260, 160),
      defaultBgColor: Color(0xFF001D31),
      slots: [
        MetroSlot(
          id: 'exit_badge',
          type: 'exit_badge',
          x: 80,
          y: 12,
          w: 100,
          h: 32,
        ),
        MetroSlot(
          id: 'info_cn',
          type: 'text',
          x: 15,
          y: 55,
          w: 230,
          h: 80,
          fontSize: 14,
        ),
        MetroSlot(
          id: 'info_en',
          type: 'text',
          x: 15,
          y: 120,
          w: 230,
          h: 30,
          fontSize: 10,
          color: Color(0xFF999999),
        ),
      ],
    ),
    MetroTemplate(
      id: 'transfer',
      name: '换乘指引牌',
      city: MetroCity.shanghai,
      canvasSize: Size(380, 140),
      defaultBgColor: Color(0xFF001D31),
      slots: [
        MetroSlot(
          id: 'transfer_label',
          type: 'text',
          x: 145,
          y: 8,
          w: 90,
          h: 22,
          fontSize: 12,
          color: Color(0xFF999999),
        ),
        MetroSlot(id: 'line1', type: 'line', x: 20, y: 40, w: 55, h: 55),
        MetroSlot(
          id: 'line1_name',
          type: 'text',
          x: 85,
          y: 55,
          w: 110,
          h: 25,
          fontSize: 14,
        ),
        MetroSlot(
          id: 'arrow1',
          type: 'arrow_right',
          x: 195,
          y: 50,
          w: 25,
          h: 35,
        ),
        MetroSlot(id: 'line2', type: 'line', x: 230, y: 40, w: 55, h: 55),
        MetroSlot(
          id: 'line2_name',
          type: 'text',
          x: 295,
          y: 55,
          w: 70,
          h: 25,
          fontSize: 14,
        ),
        MetroSlot(
          id: 'transfer_info',
          type: 'text',
          x: 20,
          y: 110,
          w: 340,
          h: 22,
          fontSize: 11,
          color: Color(0xFF999999),
        ),
      ],
    ),
    MetroTemplate(
      id: 'line_info',
      name: '线路信息牌',
      city: MetroCity.shanghai,
      canvasSize: Size(320, 90),
      defaultBgColor: Color(0xFF001D31),
      slots: [
        MetroSlot(id: 'line_badge', type: 'line', x: 12, y: 15, w: 60, h: 60),
        MetroSlot(
          id: 'line_name_cn',
          type: 'text',
          x: 85,
          y: 18,
          w: 220,
          h: 26,
          fontSize: 18,
        ),
        MetroSlot(
          id: 'line_name_en',
          type: 'text',
          x: 85,
          y: 44,
          w: 220,
          h: 20,
          fontSize: 11,
          color: Color(0xFF999999),
        ),
        MetroSlot(
          id: 'direction',
          type: 'text',
          x: 85,
          y: 64,
          w: 220,
          h: 18,
          fontSize: 10,
          color: Color(0xFF777777),
        ),
      ],
    ),
  ];
}

class MetroSlot {
  final String id;
  final String label;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color textColor;
  final Alignment alignment;
  final bool editable;
  final MetroLineInfo? defaultLine;
  final String? arrowDirection;
  final String? iconName;

  const MetroSlot({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.label = '',
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
    Color? textColor,
    this.alignment = Alignment.centerLeft,
    this.editable = true,
    this.defaultLine,
    this.arrowDirection,
    this.iconName,
  }) : textColor = textColor ?? const Color(0xFFFFFFFF);

  Offset get position => Offset(x, y);
  Size get size => Size(w, h);
}

class RoadSignCategory {
  static const prohibitionSigns = [
    RoadSignDef(id: 'pr001', name: '禁止通行', code: 'GB 5768.2-2022/1'),
    RoadSignDef(id: 'pr002', name: '禁止驶入', code: 'GB 5768.2-2022/2'),
    RoadSignDef(id: 'pr003', name: '禁止机动车通行', code: 'GB 5768.2-2022/3'),
    RoadSignDef(id: 'pr004', name: '禁止载货汽车通行', code: 'GB 5768.2-2022/4'),
    RoadSignDef(id: 'pr005', name: '禁止电动自行车通行', code: 'GB 5768.2-2022/5'),
    RoadSignDef(id: 'pr006', name: '禁止人力车通行', code: 'GB 5768.2-2022/6'),
    RoadSignDef(id: 'pr007', name: '禁止行人通行', code: 'GB 5768.2-2022/7'),
    RoadSignDef(id: 'pr008', name: '禁止向左转弯', code: 'GB 5768.2-2022/8'),
    RoadSignDef(id: 'pr009', name: '禁止向右转弯', code: 'GB 5768.2-2022/9'),
    RoadSignDef(id: 'pr010', name: '禁止直行', code: 'GB 5768.2-2022/10'),
    RoadSignDef(id: 'pr011', name: '禁止掉头', code: 'GB 5768.2-2022/11'),
    RoadSignDef(id: 'pr012', name: '禁止超车', code: 'GB 5768.2-2022/12'),
    RoadSignDef(id: 'pr013', name: '解除禁止超车', code: 'GB 5768.2-2022/13'),
    RoadSignDef(id: 'pr014', name: '限制速度', code: 'GB 5768.2-2022/14'),
    RoadSignDef(id: 'pr015', name: '解除限制速度', code: 'GB 5768.2-2022/15'),
    RoadSignDef(id: 'pr016', name: '停车让行', code: 'GB 5768.2-2022/16'),
    RoadSignDef(id: 'pr017', name: '减速让行', code: 'GB 5768.2-2022/17'),
    RoadSignDef(id: 'pr018', name: '会车让行', code: 'GB 5768.2-2022/18'),
    RoadSignDef(id: 'pr019', name: '禁止鸣喇叭', code: 'GB 5768.2-2022/19'),
    RoadSignDef(id: 'pr020', name: '禁止长时停车', code: 'GB 5768.2-2022/20'),
  ];

  static const warningSigns = [
    RoadSignDef(id: 'wr001', name: '十字交叉', code: 'GB 5768.2-2022/101'),
    RoadSignDef(id: 'wr002', name: 'T形交叉', code: 'GB 5768.2-2022/102'),
    RoadSignDef(id: 'wr003', name: 'T形交叉左侧', code: 'GB 5768.2-2022/103'),
    RoadSignDef(id: 'wr004', name: 'Y形交叉', code: 'GB 5768.2-2022/104'),
    RoadSignDef(id: 'wr005', name: '环形交叉', code: 'GB 5768.2-2022/105'),
    RoadSignDef(id: 'wr006', name: '急弯路', code: 'GB 5768.2-2022/106'),
    RoadSignDef(id: 'wr007', name: '反向弯路', code: 'GB 5768.2-2022/107'),
    RoadSignDef(id: 'wr008', name: '连续弯路', code: 'GB 5768.2-2022/108'),
    RoadSignDef(id: 'wr009', name: '上坡路', code: 'GB 5768.2-2022/109'),
    RoadSignDef(id: 'wr010', name: '下坡路', code: 'GB 5768.2-2022/110'),
    RoadSignDef(id: 'wr011', name: '两侧变窄', code: 'GB 5768.2-2022/111'),
    RoadSignDef(id: 'wr012', name: '左侧变窄', code: 'GB 5768.2-2022/112'),
    RoadSignDef(id: 'wr013', name: '右侧变窄', code: 'GB 5768.2-2022/113'),
    RoadSignDef(id: 'wr014', name: '窄桥', code: 'GB 5768.2-2022/114'),
    RoadSignDef(id: 'wr015', name: '双向交通', code: 'GB 5768.2-2022/115'),
    RoadSignDef(id: 'wr016', name: '注意行人', code: 'GB 5768.2-2022/116'),
    RoadSignDef(id: 'wr017', name: '注意儿童', code: 'GB 5768.2-2022/117'),
    RoadSignDef(id: 'wr018', name: '注意非机动车', code: 'GB 5768.2-2022/118'),
    RoadSignDef(id: 'wr019', name: '注意信号灯', code: 'GB 5768.2-2022/119'),
    RoadSignDef(id: 'wr020', name: '注意落石', code: 'GB 5768.2-2022/120'),
    RoadSignDef(id: 'wr021', name: '傍山险路', code: 'GB 5768.2-2022/121'),
    RoadSignDef(id: 'wr022', name: '堤坝路', code: 'GB 5768.2-2022/122'),
    RoadSignDef(id: 'wr023', name: '村庄', code: 'GB 5768.2-2022/123'),
    RoadSignDef(id: 'wr024', name: '注意牲畜', code: 'GB 5768.2-2022/124'),
    RoadSignDef(id: 'wr025', name: '小心滑溜', code: 'GB 5768.2-2022/125'),
    RoadSignDef(id: 'wr026', name: '路面高凸', code: 'GB 5768.2-2022/126'),
    RoadSignDef(id: 'wr027', name: '路面低洼', code: 'GB 5768.2-2022/127'),
    RoadSignDef(id: 'wr028', name: '过水路面', code: 'GB 5768.2-2022/128'),
    RoadSignDef(id: 'wr029', name: '有人看守铁路道口', code: 'GB 5768.2-2022/129'),
    RoadSignDef(id: 'wr030', name: '无人看守铁路道口', code: 'GB 5768.2-2022/130'),
    RoadSignDef(id: 'wr031', name: '注意危险', code: 'GB 5768.2-2022/131'),
    RoadSignDef(id: 'wr032', name: '施工', code: 'GB 5768.2-2022/132'),
    RoadSignDef(id: 'wr033', name: '建议速度', code: 'GB 5768.2-2022/133'),
    RoadSignDef(id: 'wr034', name: '避险车道', code: 'GB 5768.2-2022/134'),
    RoadSignDef(id: 'wr035', name: '注意潮汐车道', code: 'GB 5768.2-2022/135'),
    RoadSignDef(id: 'wr036', name: '注意雨雪', code: 'GB 5768.2-2022/136'),
  ];

  static const mandatorySigns = [
    RoadSignDef(id: 'md001', name: '直行', code: 'GB 5768.2-2022/201'),
    RoadSignDef(id: 'md002', name: '向左转弯', code: 'GB 5768.2-2022/202'),
    RoadSignDef(id: 'md003', name: '向右转弯', code: 'GB 5768.2-2022/203'),
    RoadSignDef(id: 'md004', name: '直行和向左转弯', code: 'GB 5768.2-2022/204'),
    RoadSignDef(id: 'md005', name: '直行和向右转弯', code: 'GB 5768.2-2022/205'),
    RoadSignDef(id: 'md006', name: '向左和向右转弯', code: 'GB 5768.2-2022/206'),
    RoadSignDef(id: 'md007', name: '靠右侧道路行驶', code: 'GB 5768.2-2022/207'),
    RoadSignDef(id: 'md008', name: '靠左侧道路行驶', code: 'GB 5768.2-2022/208'),
    RoadSignDef(id: 'md009', name: '环岛行驶', code: 'GB 5768.2-2022/209'),
    RoadSignDef(id: 'md010', name: '最低限速', code: 'GB 5768.2-2022/210'),
    RoadSignDef(id: 'md011', name: '最高限速', code: 'GB 5768.2-2022/211'),
    RoadSignDef(id: 'md012', name: '干路先行', code: 'GB 5768.2-2022/212'),
    RoadSignDef(id: 'md013', name: '会车先行', code: 'GB 5768.2-2022/213'),
    RoadSignDef(id: 'md014', name: '非机动车行驶', code: 'GB 5768.2-2022/214'),
    RoadSignDef(id: 'md015', name: '行人专用', code: 'GB 5768.2-2022/215'),
    RoadSignDef(id: 'md016', name: '鸣喇叭', code: 'GB 5768.2-2022/216'),
    RoadSignDef(id: 'md017', name: '掉头', code: 'GB 5768.2-2022/217'),
  ];
}

class RoadSignDef {
  final String id;
  final String name;
  final String code;

  const RoadSignDef({required this.id, required this.name, required this.code});
}

class RoadTemplate {
  final String id;
  final String name;
  final Size canvasSize;
  final Color defaultBgColor;
  final List<RoadSlot> slots;

  const RoadTemplate({
    required this.id,
    required this.name,
    required this.canvasSize,
    required this.defaultBgColor,
    required this.slots,
  });

  static const List<RoadTemplate> templates = [
    RoadTemplate(
      id: 'crossroad',
      name: '十字路口指路牌',
      canvasSize: Size(600, 200),
      defaultBgColor: Color(0xFF059669),
      slots: [
        RoadSlot(
          id: 'title',
          type: 'text',
          x: 10,
          y: 8,
          w: 180,
          h: 22,
          fontSize: 12,
          color: Color(0xFFCCEECC),
        ),
        RoadSlot(
          id: 'north_arrow',
          type: 'arrow_up',
          x: 20,
          y: 45,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'north_road',
          type: 'text',
          x: 50,
          y: 45,
          w: 180,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'north_dest',
          type: 'text',
          x: 50,
          y: 72,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
        RoadSlot(
          id: 'south_arrow',
          type: 'arrow_down',
          x: 20,
          y: 110,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'south_road',
          type: 'text',
          x: 50,
          y: 110,
          w: 180,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'south_dest',
          type: 'text',
          x: 50,
          y: 137,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
        RoadSlot(
          id: 'east_arrow',
          type: 'arrow_right',
          x: 280,
          y: 45,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'east_road',
          type: 'text',
          x: 310,
          y: 45,
          w: 180,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'east_dest',
          type: 'text',
          x: 310,
          y: 72,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
        RoadSlot(
          id: 'west_arrow',
          type: 'arrow_left',
          x: 280,
          y: 110,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'west_road',
          type: 'text',
          x: 310,
          y: 110,
          w: 180,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'west_dest',
          type: 'text',
          x: 310,
          y: 137,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
      ],
    ),
    RoadTemplate(
      id: 'tjunc',
      name: 'T形路口指路牌',
      canvasSize: Size(500, 200),
      defaultBgColor: Color(0xFF059669),
      slots: [
        RoadSlot(
          id: 'title',
          type: 'text',
          x: 10,
          y: 8,
          w: 150,
          h: 22,
          fontSize: 12,
          color: Color(0xFFCCEECC),
        ),
        RoadSlot(
          id: 'north_arrow',
          type: 'arrow_up',
          x: 20,
          y: 50,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'north_road',
          type: 'text',
          x: 50,
          y: 50,
          w: 160,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'north_dest',
          type: 'text',
          x: 50,
          y: 77,
          w: 160,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
        RoadSlot(
          id: 'east_arrow',
          type: 'arrow_right',
          x: 250,
          y: 50,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'east_road',
          type: 'text',
          x: 280,
          y: 50,
          w: 150,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'east_dest',
          type: 'text',
          x: 280,
          y: 77,
          w: 150,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
        RoadSlot(
          id: 'west_arrow',
          type: 'arrow_left',
          x: 250,
          y: 100,
          w: 24,
          h: 24,
        ),
        RoadSlot(
          id: 'west_road',
          type: 'text',
          x: 280,
          y: 100,
          w: 150,
          h: 26,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'west_dest',
          type: 'text',
          x: 280,
          y: 127,
          w: 150,
          h: 20,
          fontSize: 12,
          color: Color(0xFFBBDDBB),
        ),
      ],
    ),
    RoadTemplate(
      id: 'direct',
      name: '方向指示牌',
      canvasSize: Size(200, 350),
      defaultBgColor: Color(0xFF0284C7),
      slots: [
        RoadSlot(
          id: 'main_road',
          type: 'text',
          x: 10,
          y: 10,
          w: 180,
          h: 40,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(id: 'arrow', type: 'arrow_up', x: 85, y: 70, w: 30, h: 40),
        RoadSlot(
          id: 'dest1',
          type: 'text',
          x: 10,
          y: 130,
          w: 180,
          h: 30,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        RoadSlot(
          id: 'dist1',
          type: 'text',
          x: 10,
          y: 160,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFAADDFF),
        ),
        RoadSlot(
          id: 'dest2',
          type: 'text',
          x: 10,
          y: 200,
          w: 180,
          h: 30,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        RoadSlot(
          id: 'dist2',
          type: 'text',
          x: 10,
          y: 230,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFAADDFF),
        ),
        RoadSlot(
          id: 'dest3',
          type: 'text',
          x: 10,
          y: 270,
          w: 180,
          h: 30,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        RoadSlot(
          id: 'dist3',
          type: 'text',
          x: 10,
          y: 300,
          w: 180,
          h: 20,
          fontSize: 12,
          color: Color(0xFFAADDFF),
        ),
      ],
    ),
    RoadTemplate(
      id: 'entrance',
      name: '入口预告标志',
      canvasSize: Size(500, 200),
      defaultBgColor: Color(0xFF059669),
      slots: [
        RoadSlot(
          id: 'entrance_type',
          type: 'text',
          x: 10,
          y: 10,
          w: 100,
          h: 22,
          fontSize: 12,
          color: Color(0xFFCCEECC),
        ),
        RoadSlot(
          id: 'highway_name',
          type: 'text',
          x: 10,
          y: 45,
          w: 480,
          h: 55,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'exits',
          type: 'text',
          x: 10,
          y: 115,
          w: 480,
          h: 30,
          fontSize: 16,
        ),
        RoadSlot(
          id: 'dists',
          type: 'text',
          x: 10,
          y: 150,
          w: 480,
          h: 25,
          fontSize: 14,
          color: Color(0xFFBBDDBB),
        ),
      ],
    ),
    RoadTemplate(
      id: 'exit_sign',
      name: '出口预告标志',
      canvasSize: Size(400, 150),
      defaultBgColor: Color(0xFFE60000),
      slots: [
        RoadSlot(
          id: 'exit_num',
          type: 'text',
          x: 15,
          y: 15,
          w: 80,
          h: 35,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        RoadSlot(
          id: 'exit_label',
          type: 'text',
          x: 100,
          y: 22,
          w: 60,
          h: 22,
          fontSize: 14,
          color: Color(0xFFFFCCCC),
        ),
        RoadSlot(
          id: 'dest1',
          type: 'text',
          x: 15,
          y: 60,
          w: 370,
          h: 30,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        RoadSlot(
          id: 'dest2',
          type: 'text',
          x: 15,
          y: 95,
          w: 370,
          h: 30,
          fontSize: 18,
        ),
        RoadSlot(
          id: 'dist',
          type: 'text',
          x: 15,
          y: 125,
          w: 370,
          h: 20,
          fontSize: 12,
          color: Color(0xFFFFCCCC),
        ),
      ],
    ),
    RoadTemplate(
      id: 'speed_limit',
      name: '限速标志',
      canvasSize: Size(100, 100),
      defaultBgColor: Color(0xFFE60000),
      slots: [
        RoadSlot(
          id: 'speed',
          type: 'text',
          x: 10,
          y: 20,
          w: 80,
          h: 60,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ],
    ),
  ];
}

class RoadSlot {
  final String id;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const RoadSlot({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
  });

  Offset get position => Offset(x, y);
  Size get size => Size(w, h);
}

typedef MetroLine = MetroLineInfo;
typedef MetroCityConfig = MetroCityInfo;

class MetroTemplatePresets {
  static List<MetroTemplate> getByCity(MetroCityStyle style) {
    switch (style) {
      case MetroCityStyle.shanghai:
        return MetroTemplate._templates
            .where((t) => t.city == MetroCity.shanghai)
            .toList();
      case MetroCityStyle.guangzhou:
        return MetroTemplate._templates
            .where(
              (t) =>
                  t.city == MetroCity.guangzhou || t.city == MetroCity.shanghai,
            )
            .toList();
      case MetroCityStyle.mtr:
        return MetroTemplate._templates
            .where(
              (t) => t.city == MetroCity.mtr || t.city == MetroCity.shanghai,
            )
            .toList();
      case MetroCityStyle.jr:
        return MetroTemplate._templates
            .where((t) => t.city == MetroCity.shanghai)
            .toList();
    }
  }
}

class MetroTemplateSlot extends MetroSlot {
  const MetroTemplateSlot({
    required super.id,
    required super.type,
    required super.x,
    required super.y,
    required super.w,
    required super.h,
    super.label,
    super.fontSize,
    super.fontWeight,
    super.color,
    super.textColor,
    super.alignment,
    super.editable,
    super.defaultLine,
    super.arrowDirection,
    super.iconName,
  });
}
