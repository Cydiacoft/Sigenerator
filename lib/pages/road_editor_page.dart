import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/intersection_scene.dart';
import '../models/road_canvas_viewport.dart';
import '../models/road_board_document.dart';
import '../models/road_board_template.dart';
import '../utils/export_utils.dart';
import '../widgets/road_ruler_strip.dart';
import '../widgets/road_sign_canvas.dart';

enum _WorkbenchLayoutPreset { leftOnly, centerOnly, rightOnly, both }

class RoadEditorPage extends StatefulWidget {
  const RoadEditorPage({super.key});

  @override
  State<RoadEditorPage> createState() => _RoadEditorPageState();
}

class _RoadEditorPageState extends State<RoadEditorPage> {
  static const List<String> _dirs = ['north', 'east', 'south', 'west'];
  static const List<String> _topTabs = <String>[
    '地点距离',
    '服务区距离',
    '服务区和停车区预告',
    '道路编号和命名编号',
    '自由编辑模式',
  ];
  static const List<String> _signTypes = <String>[
    '自由模式',
    '左出口↖',
    '左出口↑',
    '直行↑',
    '车道指引↓',
    '右出口↗',
    '右出口↑',
  ];
  static const Map<String, Color> _gbBoardColors = <String, Color>{
    '绿色': Color(0xFF007A22),
    '蓝色': Color(0xFF20308E),
    '棕色': Color(0xFF8B5A2B),
  };
  static const double _boardContentInset = 6.0;

  final GlobalKey _boardKey = GlobalKey();
  final TransformationController _canvasViewController =
      TransformationController();
  final FocusNode _editorFocusNode = FocusNode();

  late IntersectionScene _scene;
  late Map<String, List<TextNode>> _boards;
  String _junctionNameEn = 'pleme a cafone';
  String _activeDirection = 'north';
  String? _selectedNodeId = 'item_center';
  TextNode? _clipboardNode;
  String? _projectFilePath;
  double _leftPanelWidth = 260;
  double _rightPanelWidth = 260;
  bool _showLeftPanel = true;
  bool _showRightPanel = true;
  _WorkbenchLayoutPreset _layoutPreset = _WorkbenchLayoutPreset.both;
  bool _enableCrossroadMode = false;
  double _canvasZoom = 0.78;
  Offset _canvasPanOffset = Offset.zero;
  final List<double> _verticalGuides = <double>[];
  final List<double> _horizontalGuides = <double>[];
  double? _draftVerticalGuide;
  double? _draftHorizontalGuide;
  int _rightPanelSection = 0;
  String _activeTopTab = '自由编辑模式';
  String _activeSignType = '车道指引↓';
  String _activeBoardColor = '蓝色';
  double _boardOpacity = 1.0;
  bool _showExitDistance = false;
  bool _showTopInfoBar = false;
  bool _showEnglishLine = true;
  String _selectedElementKind = '文本';
  String _activeTemplateId = RoadBoardTemplates.freeComposeId;
  String _placeName = '南通';
  bool _placePrefixIcon = false;
  bool _placeSuffixIcon = false;
  String _placeDistanceKm = '23';
  bool _placeIncludeEnglish = false;
  String _serviceName = '先锋';
  String _serviceDistanceKm = '1.5';
  bool _serviceIncludeEnglish = false;
  final Set<String> _serviceIcons = <String>{'P', 'Fuel', 'Food', 'Repair'};
  String _routeFontType = 'B型交通标志专用字体';
  String _routeRoadClass = '国家高速';
  String _routeMainCode = 'G15';
  bool _routeHasBranch = true;
  String _routeBranchCode = 'W';
  bool _routeHasAlias = true;
  String _routeAlias = '沈海高速';

  RoadBoardTemplateSpec get _template =>
      RoadBoardTemplates.byId(_activeTemplateId) ??
      RoadBoardTemplates.standardCrossroad;

  bool get _isCrossroadEditing =>
      _activeTopTab == '自由编辑模式' && _enableCrossroadMode;

  @override
  void initState() {
    super.initState();
    _canvasViewController.addListener(_onCanvasTransformChanged);
    HardwareKeyboard.instance.addHandler(_handleEditorShortcuts);
    _scene = IntersectionScene(
      name: '张家井',
      intersectionShape: IntersectionShape.crossroad,
      backgroundColor: const Color(0xFF20308E),
      foregroundColor: Colors.white,
      scenicColor: const Color(0xFF8B5A2B),
      north: DirectionInfo(
        roadName: '甘城路',
        roadNameEn: 'Sladizevo:puto',
        destination: '光辉园(西门)',
        destinationEn: 'Posiploda (cine koke)',
        destinationType: DestinationType.scenic,
      ),
      east: DirectionInfo(
        roadName: '西先拂街',
        roadNameEn: 'kokiSeonPhourl:puto',
        destination: '先拂天阶',
        destinationEn: 'SeonPhourlnebibibore',
      ),
      south: DirectionInfo(
        roadName: '张家井大街',
        roadNameEn: 'Dcanqovilipivebe:putumo',
        destination: '中河湾',
        destinationEn: 'Tavaputifosahure',
      ),
      west: DirectionInfo(
        roadName: '西先拂街',
        roadNameEn: 'kokiSeonPhourl:puto',
        destination: '西麦仓',
        destinationEn: 'Kokimagipume',
      ),
    );
    _activeBoardColor = _colorNameFor(_scene.backgroundColor);
    _boards = {for (final dir in _dirs) dir: _buildBoard(dir)};
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleEditorShortcuts);
    _canvasViewController.removeListener(_onCanvasTransformChanged);
    _canvasViewController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _boards[_activeDirection]!;
    final selected = _selectedNode(nodes);
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Focus(
        focusNode: _editorFocusNode,
        autofocus: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildToolbar(context),
              Expanded(
                child: Row(
                  children: [
                    if (_showLeftPanel) _buildLeftPanel(),
                    if (_showLeftPanel)
                      _buildPanelResizer(
                        onDrag: (delta) => setState(() {
                          _leftPanelWidth = (_leftPanelWidth + delta).clamp(
                            260.0,
                            520.0,
                          );
                        }),
                      ),
                    Expanded(child: _buildCanvasPanel(nodes, selected)),
                    if (_showRightPanel)
                      _buildPanelResizer(
                        onDrag: (delta) => setState(() {
                          _rightPanelWidth = (_rightPanelWidth - delta).clamp(
                            260.0,
                            520.0,
                          );
                        }),
                      ),
                    if (_showRightPanel) _buildRightPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            tooltip: '返回',
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '道路指路牌编辑器',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '深色三栏工作区，保留生成器流程并强化可视化编辑',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _newProject,
            icon: const Icon(Icons.note_add_outlined, size: 18),
            label: const Text('新建'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _openProject,
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: const Text('打开'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _saveProject,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(_projectFilePath == null ? '保存' : '保存项目'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _saveProjectAs,
            icon: const Icon(Icons.save_as_outlined, size: 18),
            label: const Text('另存为'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _saveBoardJson,
            icon: const Icon(Icons.data_object, size: 18),
            label: const Text('保存 JSON'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: _exportBoardPng,
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text('导出 PNG'),
          ),
          const SizedBox(width: 16),
          _buildVsCodeLayoutSwitcher(),
        ],
      ),
    );
  }

  Widget _buildPanelResizer({required ValueChanged<double> onDrag}) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: Container(
          width: 10,
          color: const Color(0xFF0B1120),
          alignment: Alignment.center,
          child: Container(
            width: 2,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVsCodeLayoutSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _layoutPresetButton(
            preset: _WorkbenchLayoutPreset.leftOnly,
            tooltip: '左侧栏 + 画布',
          ),
          _layoutPresetButton(
            preset: _WorkbenchLayoutPreset.centerOnly,
            tooltip: '仅画布',
          ),
          _layoutPresetButton(
            preset: _WorkbenchLayoutPreset.rightOnly,
            tooltip: '画布 + 右侧栏',
          ),
          _layoutPresetButton(
            preset: _WorkbenchLayoutPreset.both,
            tooltip: '左侧栏 + 画布 + 右侧栏',
          ),
        ],
      ),
    );
  }

  Widget _layoutPresetButton({
    required _WorkbenchLayoutPreset preset,
    required String tooltip,
  }) {
    final selected = _layoutPreset == preset;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _applyLayoutPreset(preset),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 28,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF334155) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: _layoutPresetGlyph(preset, selected: selected),
        ),
      ),
    );
  }

  Widget _layoutPresetGlyph(
    _WorkbenchLayoutPreset preset, {
    required bool selected,
  }) {
    final activeColor = selected ? Colors.white : Colors.white70;
    final mutedColor = const Color(0xFF475569);
    Color c(bool on) => on ? activeColor : mutedColor;
    final showLeft =
        preset == _WorkbenchLayoutPreset.leftOnly ||
        preset == _WorkbenchLayoutPreset.both;
    final showRight =
        preset == _WorkbenchLayoutPreset.rightOnly ||
        preset == _WorkbenchLayoutPreset.both;
    return SizedBox(
      width: 16,
      height: 12,
      child: Row(
        children: [
          _glyphBlock(width: 3, color: c(showLeft)),
          const SizedBox(width: 2),
          _glyphBlock(width: 6, color: c(true)),
          const SizedBox(width: 2),
          _glyphBlock(width: 3, color: c(showRight)),
        ],
      ),
    );
  }

  Widget _glyphBlock({required double width, required Color color}) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  void _applyLayoutPreset(_WorkbenchLayoutPreset preset) {
    setState(() {
      _layoutPreset = preset;
      switch (preset) {
        case _WorkbenchLayoutPreset.leftOnly:
          _showLeftPanel = true;
          _showRightPanel = false;
          break;
        case _WorkbenchLayoutPreset.centerOnly:
          _showLeftPanel = false;
          _showRightPanel = false;
          break;
        case _WorkbenchLayoutPreset.rightOnly:
          _showLeftPanel = false;
          _showRightPanel = true;
          break;
        case _WorkbenchLayoutPreset.both:
          _showLeftPanel = true;
          _showRightPanel = true;
          break;
      }
    });
  }

  Widget _buildLeftPanel() {
    return Container(
      width: _leftPanelWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(right: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGeneratorPanel(),
          if (_isCrossroadEditing) ...[
            const SizedBox(height: 20),
            _sectionTitle('画布样式', '颜色和路口基本设置'),
            const SizedBox(height: 12),
            _colorButton('背景色', _scene.backgroundColor, (c) {
              setState(() {
                _scene = _scene.copyWith(backgroundColor: c);
                _activeBoardColor = _colorNameFor(c);
                _syncBoards();
              });
            }),
            const SizedBox(height: 10),
            _colorButton('前景色', _scene.foregroundColor, (c) {
              setState(() {
                _scene = _scene.copyWith(foregroundColor: c);
                _syncBoards();
              });
            }),
            const SizedBox(height: 10),
            _colorButton('景区色', _scene.scenicColor, (c) {
              setState(() {
                _scene = _scene.copyWith(scenicColor: c);
                _syncBoards();
              });
            }),
            const SizedBox(height: 10),
            DropdownButtonFormField<IntersectionShape>(
              initialValue: _scene.intersectionShape,
              decoration: _inputDecoration('路口形状'),
              dropdownColor: const Color(0xFF0F172A),
              items: IntersectionShape.values
                  .map(
                    (shape) =>
                        DropdownMenuItem(value: shape, child: Text(shape.name)),
                  )
                  .toList(),
              onChanged: (shape) {
                if (shape == null) return;
                setState(() {
                  _scene = _scene.copyWith(intersectionShape: shape);
                  _syncBoards();
                });
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('路口信息', '全局名称和方向配置'),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _scene.name),
              decoration: _inputDecoration('路口名称'),
              onChanged: (value) =>
                  setState(() => _scene = _scene.copyWith(name: value)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _junctionNameEn),
              decoration: _inputDecoration('路口名称拼音'),
              onChanged: (value) => setState(() => _junctionNameEn = value),
            ),
            const SizedBox(height: 16),
            ..._dirs.map(_buildDirectionEditor),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneratorPanel() {
    final selectedNode = _selectedNode(_boards[_activeDirection]!);
    final selectedKind = selectedNode == null
        ? _selectedElementKind
        : (selectedNode.nodeType == NodeType.graphic
              ? '图形'
              : selectedNode.nodeType == NodeType.whiteBox
              ? '白底'
              : '文本');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '道路交通标志生成工具（GB 5768.2 约束）',
            style: TextStyle(
              color: Color(0xFF86EFAC),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '关联说明：十字路口画布是基础层，不同情景是参数化细化层（共享同一画布与标尺）。',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _topTabs
                .map(
                  (tab) => ChoiceChip(
                    label: Text(tab, style: const TextStyle(fontSize: 11)),
                    selected: _activeTopTab == tab,
                    onSelected: (_) => _onTopTabSelected(tab),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildScenarioEditor(),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _applyGbPreset,
            icon: const Icon(Icons.rule_folder, size: 16),
            label: const Text('应用 GB 标准预设'),
          ),
          const SizedBox(height: 12),
          const Text(
            '标志类型',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _signTypes
                .map(
                  (type) => ChoiceChip(
                    label: Text(type, style: const TextStyle(fontSize: 11)),
                    selected: _activeSignType == type,
                    onSelected: (_) => _onSignTypeSelected(type),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '背景颜色',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: _gbBoardColors.entries
                .map(
                  (entry) => ChoiceChip(
                    label: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: _activeBoardColor == entry.key,
                    onSelected: (_) => _applyBoardColor(entry.key, entry.value),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '不透明度',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Slider(
            value: _boardOpacity,
            min: 0.5,
            max: 1.0,
            divisions: 10,
            label: _boardOpacity.toStringAsFixed(2),
            onChanged: (v) => setState(() => _boardOpacity = v),
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: _showExitDistance,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('出口距离', style: TextStyle(fontSize: 12)),
                  onChanged: (v) => _toggleExitDistance(v ?? false),
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: _showTopInfoBar,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('顶部信息栏', style: TextStyle(fontSize: 12)),
                  onChanged: (v) => _toggleTopInfoBar(v ?? false),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 20),
          const Text(
            '正文信息栏',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _nudgeSelected(-12, 0),
                icon: const Icon(Icons.arrow_back, size: 14),
                label: const Text('左移', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton.icon(
                onPressed: () => _nudgeSelected(12, 0),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('右移', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton.icon(
                onPressed: _duplicateSelectedNode,
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('复制', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '类型',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedKind,
                  items: const [
                    DropdownMenuItem(value: '文本', child: Text('文本')),
                    DropdownMenuItem(value: '白底', child: Text('白底')),
                    DropdownMenuItem(value: '图形', child: Text('图形')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    _selectedElementKind = value;
                    _changeSelectedNodeType(value);
                  },
                  decoration: _inputDecoration('元素类型'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: selectedNode?.text ?? ''),
            decoration: _inputDecoration('主文本'),
            onChanged: (value) {
              final node = _selectedNode(_boards[_activeDirection]!);
              if (node == null || node.nodeType == NodeType.graphic) return;
              _updateSelected(node.copyWith(text: value));
            },
          ),
          CheckboxListTile(
            dense: true,
            value: _showEnglishLine,
            contentPadding: EdgeInsets.zero,
            title: const Text('添加英文字行', style: TextStyle(fontSize: 12)),
            onChanged: (v) {
              final enabled = v ?? false;
              setState(() => _showEnglishLine = enabled);
              final node = _selectedNode(_boards[_activeDirection]!);
              if (node == null || node.nodeType == NodeType.graphic) return;
              _updateSelected(
                node.copyWith(
                  textEn: enabled ? (node.textEn ?? 'English') : '',
                ),
              );
            },
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: _addTextRow,
                icon: const Icon(Icons.add_circle_outline, size: 14),
                label: const Text('添加行', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton.icon(
                onPressed: _addElementBlock,
                icon: const Icon(Icons.add_box_outlined, size: 14),
                label: const Text('添加元素', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton.icon(
                onPressed: _deleteSelectedNode,
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('删除行', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioEditor() {
    if (_activeTopTab == '地点距离') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '地点距离模板',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _placeName),
            decoration: _inputDecoration('主文本'),
            onChanged: (v) {
              setState(() {
                _placeName = v;
                _syncBoards();
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _placeDistanceKm),
                  decoration: _inputDecoration('距离(km)'),
                  onChanged: (v) {
                    setState(() {
                      _placeDistanceKm = v;
                      _syncBoards();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _placeIncludeEnglish,
                  title: const Text('添加英文字行', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _placeIncludeEnglish = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _placePrefixIcon,
                  title: const Text('前缀图标', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _placePrefixIcon = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _placeSuffixIcon,
                  title: const Text('后缀图标', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _placeSuffixIcon = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
    if (_activeTopTab == '服务区距离' || _activeTopTab == '服务区和停车区预告') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activeTopTab == '服务区距离' ? '服务区距离模板' : '服务区和停车区预告模板',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _serviceName),
            decoration: _inputDecoration('服务区名称'),
            onChanged: (v) {
              setState(() {
                _serviceName = v;
                _syncBoards();
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _serviceDistanceKm),
                  decoration: _inputDecoration('距离(km)'),
                  onChanged: (v) {
                    setState(() {
                      _serviceDistanceKm = v;
                      _syncBoards();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _serviceIncludeEnglish,
                  title: const Text('添加英文字行', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _serviceIncludeEnglish = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _serviceIconChip('P', '停车'),
              _serviceIconChip('Fuel', '加油'),
              _serviceIconChip('Food', '餐饮'),
              _serviceIconChip('Repair', '维修'),
            ],
          ),
        ],
      );
    }
    if (_activeTopTab == '道路编号和命名编号') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '道路编号模板',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: ['B型交通标志专用字体', 'A型交通标志专用字体']
                .map(
                  (font) => ChoiceChip(
                    label: Text(font, style: const TextStyle(fontSize: 11)),
                    selected: _routeFontType == font,
                    onSelected: (_) {
                      setState(() {
                        _routeFontType = font;
                        _syncBoards();
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: ['国家高速', '省级高速', '国道', '省道', '县道/乡道']
                .map(
                  (kind) => ChoiceChip(
                    label: Text(kind, style: const TextStyle(fontSize: 11)),
                    selected: _routeRoadClass == kind,
                    onSelected: (_) {
                      setState(() {
                        _routeRoadClass = kind;
                        _syncBoards();
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _routeMainCode),
            decoration: _inputDecoration('主线编号'),
            onChanged: (v) {
              setState(() {
                _routeMainCode = v;
                _syncBoards();
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _routeHasBranch,
                  title: const Text('支线编号', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _routeHasBranch = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _routeBranchCode),
                  decoration: _inputDecoration('支线'),
                  onChanged: (v) {
                    setState(() {
                      _routeBranchCode = v;
                      _syncBoards();
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _routeHasAlias,
                  title: const Text('道路简称', style: TextStyle(fontSize: 12)),
                  onChanged: (v) {
                    setState(() {
                      _routeHasAlias = v ?? false;
                      _syncBoards();
                    });
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _routeAlias),
                  decoration: _inputDecoration('简称文字'),
                  onChanged: (v) {
                    setState(() {
                      _routeAlias = v;
                      _syncBoards();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
    if (_activeTopTab == '自由编辑模式') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('十字路口编辑', style: TextStyle(fontSize: 12)),
            subtitle: const Text(
              '开启后显示东西南北切换、四向预览与路口参数设置',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
            value: _enableCrossroadMode,
            onChanged: (enabled) {
              setState(() {
                _enableCrossroadMode = enabled;
                _activeDirection = 'north';
                _selectedNodeId = 'item_center';
                _syncBoards();
              });
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _serviceIconChip(String key, String label) {
    final selected = _serviceIcons.contains(key);
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (enabled) {
        setState(() {
          if (enabled) {
            _serviceIcons.add(key);
          } else {
            _serviceIcons.remove(key);
          }
          _syncBoards();
        });
      },
    );
  }

  Widget _buildCanvasPanel(List<TextNode> nodes, TextNode? selected) {
    return Container(
      color: const Color(0xFF0B1120),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              children: [
                if (_isCrossroadEditing) ...[
                  ..._dirs.map(
                    (dir) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_dirCn(dir)),
                        selected: _activeDirection == dir,
                        onSelected: (_) => setState(() {
                          _activeDirection = dir;
                          _selectedNodeId = 'item_center';
                        }),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _activeTopTab,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: _resetCanvasView,
                  child: const Text('重置视图'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _verticalGuides.clear();
                    _horizontalGuides.clear();
                    _draftVerticalGuide = null;
                    _draftHorizontalGuide = null;
                  }),
                  child: const Text('清空参考线'),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.zoom_out_map,
                        color: Colors.white38,
                        size: 14,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _canvasZoom,
                            min: 0.45,
                            max: 1.2,
                            onChanged: (value) =>
                                setState(() => _canvasZoom = value),
                          ),
                        ),
                      ),
                      Text(
                        '${(_canvasZoom * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 36, height: 28),
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: _buildHorizontalRuler(),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 36, child: _buildVerticalRuler()),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _editorFocusNode.requestFocus();
                              if (_selectedNodeId != null) {
                                setState(() => _selectedNodeId = null);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                border: Border.all(
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              child: InteractiveViewer(
                                transformationController: _canvasViewController,
                                alignment: Alignment.topLeft,
                                constrained: false,
                                boundaryMargin: const EdgeInsets.all(240),
                                minScale: 1,
                                maxScale: 1,
                                panEnabled: true,
                                scaleEnabled: false,
                                child: RepaintBoundary(
                                  key: _boardKey,
                                  child: Transform.scale(
                                    scale: _canvasZoom,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: _template.canvasSize.width,
                                      height: _template.canvasSize.height,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: RoadSignCanvas(
                                              width: _template.canvasSize.width,
                                              height:
                                                  _template.canvasSize.height,
                                              backgroundColor: _scene
                                                  .backgroundColor
                                                  .withValues(
                                                    alpha: _boardOpacity,
                                                  ),
                                              headerColor:
                                                  _template.headerColor,
                                              headerRatio:
                                                  _template.headerRatio,
                                              borderColor:
                                                  _scene.foregroundColor,
                                              borderWidth: 2,
                                              nodes: nodes,
                                              selectedNodeId: _selectedNodeId,
                                              onNodeSelected: (id) {
                                                _editorFocusNode.requestFocus();
                                                setState(
                                                  () => _selectedNodeId = id,
                                                );
                                              },
                                              onNodeSecondaryTapDown:
                                                  _showNodeContextMenu,
                                              onNodesChanged: _onBoardChanged,
                                              interactionScale: _canvasZoom,
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: CustomPaint(
                                                painter: _GuideOverlayPainter(
                                                  verticalGuides:
                                                      List<double>.from(
                                                        _verticalGuides,
                                                      ),
                                                  horizontalGuides:
                                                      List<double>.from(
                                                        _horizontalGuides,
                                                      ),
                                                  draftVerticalGuide:
                                                      _draftVerticalGuide,
                                                  draftHorizontalGuide:
                                                      _draftHorizontalGuide,
                                                  contentInset:
                                                      _boardContentInset,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              border: Border(top: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _exportBoardPng,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('下载到本地'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _copyBoardPathToClipboard,
                  icon: const Icon(Icons.copy_all, size: 16),
                  label: const Text('复制到剪贴板'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalRuler() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) =>
          _startHorizontalGuideFromRuler(details.localPosition.dy),
      onVerticalDragUpdate: (details) =>
          _updateHorizontalGuideFromRuler(details.localPosition.dy),
      onVerticalDragEnd: (_) => _commitHorizontalGuide(),
      onVerticalDragCancel: _cancelDraftGuide,
      child: RoadRulerStrip(
        axis: RulerAxis.vertical,
        viewport: _viewportModel(),
      ),
    );
  }

  Widget _buildHorizontalRuler() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) =>
          _startVerticalGuideFromRuler(details.localPosition.dx),
      onHorizontalDragUpdate: (details) =>
          _updateVerticalGuideFromRuler(details.localPosition.dx),
      onHorizontalDragEnd: (_) => _commitVerticalGuide(),
      onHorizontalDragCancel: _cancelDraftGuide,
      child: RoadRulerStrip(
        axis: RulerAxis.horizontal,
        viewport: _viewportModel(),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: _rightPanelWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(left: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              children: [
                _rightTabButton('属性', 0),
                _rightTabButton('元素', 1),
                _rightTabButton('预览', 2),
              ],
            ),
          ),
          Expanded(
            child: _rightPanelSection == 0
                ? _buildPropertyPanel()
                : _rightPanelSection == 1
                ? _buildElementsPanel()
                : _buildPreviewPanel(),
          ),
        ],
      ),
    );
  }

  Widget _rightTabButton(String label, int index) {
    final selected = _rightPanelSection == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _rightPanelSection = index),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF3B82F6) : Colors.white54,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementsPanel() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionTitle('快捷操作', '快速添加元素'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ActionChip(
              label: const Text('白底子牌', style: TextStyle(fontSize: 11)),
              onPressed: _addWhitePlate,
            ),
            ActionChip(
              label: const Text('棕底子牌', style: TextStyle(fontSize: 11)),
              onPressed: _addScenicPlate,
            ),
            ActionChip(
              label: const Text('路口图形', style: TextStyle(fontSize: 11)),
              onPressed: _addGraphicNode,
            ),
            ActionChip(
              label: const Text('重置方向', style: TextStyle(fontSize: 11)),
              onPressed: () => setState(() {
                _boards[_activeDirection] = _buildBoard(_activeDirection);
                _selectedNodeId = 'item_center';
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('当前元素', '点击选择'),
        const SizedBox(height: 8),
        ..._boards[_activeDirection]!.map(_buildElementItem),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    if (!_isCrossroadEditing) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionTitle('模板预览', '当前情景单牌预览'),
          const SizedBox(height: 8),
          _buildSinglePreviewCard(),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionTitle('四向预览', '点击切换方向'),
        const SizedBox(height: 8),
        ..._dirs.map(_buildPreviewCard),
      ],
    );
  }

  Widget _buildSinglePreviewCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253046), width: 1),
      ),
      child: AspectRatio(
        aspectRatio: _template.canvasSize.width / _template.canvasSize.height,
        child: IgnorePointer(
          child: RoadSignCanvas(
            width: _template.canvasSize.width,
            height: _template.canvasSize.height,
            backgroundColor: _scene.backgroundColor.withValues(
              alpha: _boardOpacity,
            ),
            borderColor: _scene.foregroundColor,
            borderWidth: 2,
            nodes: _boards['north']!,
            onNodesChanged: (_) {},
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyPanel() {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) {
      return const Center(
        child: Text('请在画布上选择一个元素', style: TextStyle(color: Colors.white54)),
      );
    }
    final maxX = (_template.canvasSize.width - node.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_template.canvasSize.height - node.height).clamp(
      0.0,
      double.infinity,
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _propertySection('基本信息', [
          _propertyRow('编号', node.id),
          _propertyRow('类型', node.nodeType.name),
          _propertyRow('插槽', node.slotId ?? '-'),
        ]),
        const SizedBox(height: 12),
        _propertySection('文字内容', [
          _textField('中文', node, 'text', key: ValueKey('${node.id}_text')),
          const SizedBox(height: 8),
          _textField('英文', node, 'textEn', key: ValueKey('${node.id}_textEn')),
        ]),
        const SizedBox(height: 12),
        _propertySection('位置与尺寸', [
          _propertySlider(
            'X',
            node.x,
            0,
            maxX,
            (v) => _updateNodePosition(node, v, null),
          ),
          _propertySlider(
            'Y',
            node.y,
            0,
            maxY,
            (v) => _updateNodePosition(node, null, v),
          ),
          _propertySlider(
            '宽',
            node.width,
            20,
            _template.canvasSize.width,
            (v) => _updateNodeSize(node, v, null),
          ),
          _propertySlider(
            '高',
            node.height,
            20,
            _template.canvasSize.height,
            (v) => _updateNodeSize(node, null, v),
          ),
        ]),
        const SizedBox(height: 12),
        _propertySection('对齐', [
          Wrap(
            spacing: 6,
            children: [
              _alignChip(node, TextAlign.left, '左'),
              _alignChip(node, TextAlign.center, '中'),
              _alignChip(node, TextAlign.right, '右'),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        _propertySection('操作', [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                label: const Text('复制', style: TextStyle(fontSize: 11)),
                onPressed: _copySelectedNode,
              ),
              ActionChip(
                label: const Text('删除', style: TextStyle(fontSize: 11)),
                onPressed: _deleteSelectedNode,
              ),
              ActionChip(
                label: const Text('取消选中', style: TextStyle(fontSize: 11)),
                onPressed: _deselectNode,
              ),
            ],
          ),
        ]),
      ],
    );
  }

  final Map<String, TextEditingController> _textControllers = {};

  void _disposeControllers(String nodeId) {
    _textControllers.remove('${nodeId}_text')?.dispose();
    _textControllers.remove('${nodeId}_textEn')?.dispose();
  }

  TextEditingController _getController(
    String nodeId,
    String field,
    String initialValue,
  ) {
    final key = '${nodeId}_$field';
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController(text: initialValue);
    } else {
      final controller = _textControllers[key]!;
      if (controller.text != initialValue) {
        controller.text = initialValue;
      }
    }
    return _textControllers[key]!;
  }

  Widget _textField(String label, TextNode node, String field, {Key? key}) {
    final value = field == 'text' ? node.text : (node.textEn ?? '');
    final controller = _getController(node.id, field, value);
    return TextField(
      key: key,
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
      onChanged: (v) {
        if (field == 'text') {
          _updateSelected(node.copyWith(text: v));
        } else {
          _updateSelected(node.copyWith(textEn: v));
        }
      },
    );
  }

  Widget _propertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _propertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertySlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final current = value.clamp(min, max);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: current,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 58,
            child: TextField(
              controller: TextEditingController(
                text: current.round().toString(),
              ),
              style: const TextStyle(color: Colors.white60, fontSize: 11),
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (input) {
                final parsed = double.tryParse(input.trim());
                if (parsed == null) return;
                onChanged(parsed.clamp(min, max));
              },
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              current.round().toString(),
              style: const TextStyle(color: Colors.white60, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementItem(TextNode node) {
    final isSelected = node.id == _selectedNodeId;
    return InkWell(
      onTap: () => setState(() => _selectedNodeId = node.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF1F2937),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.slotId ?? node.id,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    node.nodeType.name,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (node.fillColor != null)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: node.fillColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateNodePosition(TextNode node, double? x, double? y) {
    final maxX = (_template.canvasSize.width - node.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_template.canvasSize.height - node.height).clamp(
      0.0,
      double.infinity,
    );
    _updateSelected(
      node.copyWith(
        x: (x ?? node.x).clamp(0, maxX),
        y: (y ?? node.y).clamp(0, maxY),
      ),
    );
  }

  void _updateNodeSize(TextNode node, double? w, double? h) {
    final newWidth = (w ?? node.width)
        .clamp(20.0, _template.canvasSize.width)
        .toDouble();
    final newHeight = (h ?? node.height)
        .clamp(20.0, _template.canvasSize.height)
        .toDouble();
    final maxX = (_template.canvasSize.width - newWidth).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_template.canvasSize.height - newHeight).clamp(
      0.0,
      double.infinity,
    );
    _updateSelected(
      node.copyWith(
        width: newWidth,
        height: newHeight,
        x: node.x.clamp(0.0, maxX).toDouble(),
        y: node.y.clamp(0.0, maxY).toDouble(),
      ),
    );
  }

  Widget _buildDirectionEditor(String dir) {
    final info = _scene.directionInfo(dir);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_dirCn(dir)}向',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: TextEditingController(text: info.roadName),
            decoration: _inputDecoration('道路名称'),
            onChanged: (value) =>
                _updateDirection(dir, (old) => old.copyWith(roadName: value)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: TextEditingController(text: info.destination),
            decoration: _inputDecoration('通往地点'),
            onChanged: (value) => _updateDirection(
              dir,
              (old) => old.copyWith(destination: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(String dir) {
    final selected = dir == _activeDirection;
    return InkWell(
      onTap: () => setState(() {
        _activeDirection = dir;
        _selectedNodeId = 'item_center';
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white70 : const Color(0xFF253046),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_dirCn(dir)}向预览',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio:
                  _template.canvasSize.width / _template.canvasSize.height,
              child: IgnorePointer(
                child: RoadSignCanvas(
                  width: _template.canvasSize.width,
                  height: _template.canvasSize.height,
                  backgroundColor: _scene.backgroundColor.withValues(
                    alpha: _boardOpacity,
                  ),
                  headerColor: _template.headerColor,
                  headerRatio: _template.headerRatio,
                  borderColor: _scene.foregroundColor,
                  borderWidth: 2,
                  nodes: _boards[dir]!,
                  onNodesChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alignChip(TextNode node, TextAlign align, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: node.textAlign == align,
      onSelected: (_) => _updateSelected(node.copyWith(textAlign: align)),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _colorButton(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return InkWell(
      onTap: () => _pickColor(label, color, onChanged),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFF0B1120),
    );
  }

  Future<void> _pickColor(
    String label,
    Color initial,
    ValueChanged<Color> onChanged,
  ) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) =>
          ColorPickerDialog(initialColor: initial, title: '选择$label'),
    );
    if (color != null) onChanged(color);
  }

  void _updateDirection(
    String dir,
    DirectionInfo Function(DirectionInfo info) update,
  ) {
    setState(() {
      switch (dir) {
        case 'north':
          _scene = _scene.copyWith(north: update(_scene.north));
          break;
        case 'east':
          _scene = _scene.copyWith(east: update(_scene.east));
          break;
        case 'south':
          _scene = _scene.copyWith(south: update(_scene.south));
          break;
        case 'west':
          _scene = _scene.copyWith(west: update(_scene.west));
          break;
      }
      _syncBoards();
    });
  }

  void _onBoardChanged(List<TextNode> nodes) {
    final fixed = nodes
        .map((node) => _normalizeTextBoundsIfNeeded(node))
        .map((node) => _clampNodeToBoard(node))
        .map(
          (node) => node.id == _selectedNodeId ? _snapNodeToGuides(node) : node,
        )
        .toList();
    setState(() {
      _boards[_activeDirection] = fixed;
    });
  }

  void _resetCanvasView() {
    _canvasViewController.value = Matrix4.identity();
    setState(() {
      _canvasZoom = 0.78;
      _canvasPanOffset = Offset.zero;
    });
  }

  void _updateSelected(TextNode updated) {
    final nodes = _boards[_activeDirection]!
        .map((node) => node.id == updated.id ? updated : node)
        .toList();
    _onBoardChanged(nodes);
  }

  void _onCanvasTransformChanged() {
    final matrix = _canvasViewController.value;
    final pan = Offset(matrix.storage[12], matrix.storage[13]);
    if (pan == _canvasPanOffset) return;
    setState(() {
      _canvasPanOffset = pan;
    });
  }

  bool _handleEditorShortcuts(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final focused = FocusManager.instance.primaryFocus?.context?.widget;
    if (focused is EditableText) return false;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final key = event.logicalKey;
    if (isCtrl && key == LogicalKeyboardKey.keyC) {
      _copySelectedNode();
      return true;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyV) {
      _pasteClipboardNode();
      return true;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyD) {
      _duplicateSelectedNode();
      return true;
    }
    if (key == LogicalKeyboardKey.delete) {
      _deleteSelectedNode();
      return true;
    }
    if (key == LogicalKeyboardKey.escape) {
      _deselectNode();
      return true;
    }
    return false;
  }

  void _applyGbPreset() {
    setState(() {
      _activeBoardColor = '蓝色';
      _boardOpacity = 1.0;
      _scene = _scene.copyWith(
        backgroundColor: _gbBoardColors['蓝色']!,
        foregroundColor: Colors.white,
        scenicColor: const Color(0xFF8B5A2B),
      );
      for (final dir in _dirs) {
        final normalized = _boards[dir]!.map((node) {
          if (node.nodeType == NodeType.graphic) {
            return node.copyWith(
              style: node.style.copyWith(color: Colors.white),
              width: node.width.clamp(120.0, 240.0),
              height: node.height.clamp(120.0, 240.0),
            );
          }
          final slot = node.slotId == null
              ? null
              : _template.slots[node.slotId!];
          final fontSize = slot?.fontSize ?? node.style.fontSize ?? 24;
          return node.copyWith(
            style: node.style.copyWith(
              color: node.nodeType == NodeType.whiteBox
                  ? (_scene.backgroundColor)
                  : Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
            borderWidth: node.nodeType == NodeType.whiteBox
                ? 2
                : node.borderWidth,
          );
        }).toList();
        _boards[dir] = normalized;
      }
    });
    _showMessage('已应用 GB 5768.2 预设');
  }

  void _onTopTabSelected(String tab) {
    _activeTopTab = tab;
    if (tab != '自由编辑模式') {
      _enableCrossroadMode = false;
      _activeDirection = 'north';
    }
    _activeTemplateId = _templateIdForTab(tab);
    _applyScenarioPreset(tab);
  }

  String _templateIdForTab(String tab) {
    return switch (tab) {
      '地点距离' => RoadBoardTemplates.placeDistanceId,
      '服务区距离' => RoadBoardTemplates.serviceDistanceId,
      '服务区和停车区预告' => RoadBoardTemplates.serviceAdvanceId,
      '道路编号和命名编号' => RoadBoardTemplates.routeNumberId,
      '自由编辑模式' => RoadBoardTemplates.freeComposeId,
      _ => RoadBoardTemplates.freeComposeId,
    };
  }

  String _tabForTemplateId(String templateId) {
    return switch (templateId) {
      RoadBoardTemplates.placeDistanceId => '地点距离',
      RoadBoardTemplates.serviceDistanceId => '服务区距离',
      RoadBoardTemplates.serviceAdvanceId => '服务区和停车区预告',
      RoadBoardTemplates.routeNumberId => '道路编号和命名编号',
      RoadBoardTemplates.freeComposeId => '自由编辑模式',
      RoadBoardTemplates.standardCrossroadId => '自由编辑模式',
      _ => '自由编辑模式',
    };
  }

  void _onSignTypeSelected(String type) {
    setState(() {
      _activeSignType = type;
      for (final dir in _dirs) {
        _boards[dir] = _applySignTypeToNodes(_boards[dir]!, type);
      }
    });
  }

  List<TextNode> _applySignTypeToNodes(List<TextNode> source, String type) {
    final nodes = [...source];
    final centerIndex = nodes.indexWhere((node) => node.id == 'item_center');
    if (centerIndex < 0) return nodes;
    final center = nodes[centerIndex];
    GraphicType targetGraphic = center.graphicType ?? GraphicType.crossroad;
    switch (type) {
      case '左出口↖':
      case '左出口↑':
        targetGraphic = GraphicType.skewLeft;
        break;
      case '右出口↗':
      case '右出口↑':
        targetGraphic = GraphicType.skewRight;
        break;
      case '直行↑':
      case '车道指引↓':
      case '自由模式':
        targetGraphic = GraphicType.crossroad;
        break;
    }
    nodes[centerIndex] = center.copyWith(
      nodeType: NodeType.graphic,
      graphicType: targetGraphic,
      style: center.style.copyWith(color: _scene.foregroundColor),
    );
    return nodes;
  }

  void _applyBoardColor(String name, Color color) {
    setState(() {
      _activeBoardColor = name;
      _scene = _scene.copyWith(backgroundColor: color);
      _syncBoards();
    });
    _applyScenarioPreset(_activeTopTab);
  }

  void _toggleExitDistance(bool enabled) {
    _showExitDistance = enabled;
    _upsertUtilityNodeAllDirections(
      enabled: enabled,
      nodeId: 'utility_exit_distance',
      create: (direction) => TextNode(
        id: 'utility_exit_distance',
        x: _template.canvasSize.width - 220,
        y: _template.canvasSize.height - 42,
        width: 190,
        height: 28,
        text: '出口 500m',
        textEn: 'Exit 500m',
        nodeType: NodeType.whiteBox,
        fillColor: Colors.white,
        backgroundColor: _scene.backgroundColor,
        style: TextStyle(
          color: _scene.backgroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _toggleTopInfoBar(bool enabled) {
    _showTopInfoBar = enabled;
    _upsertUtilityNodeAllDirections(
      enabled: enabled,
      nodeId: 'utility_top_info',
      create: (direction) => TextNode(
        id: 'utility_top_info',
        x: 220,
        y: 8,
        width: 560,
        height: 30,
        text: '道路编号 G2 · 京沪高速',
        textEn: 'G2 Beijing-Shanghai Expressway',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _upsertUtilityNodeAllDirections({
    required bool enabled,
    required String nodeId,
    required TextNode Function(String direction) create,
  }) {
    setState(() {
      for (final dir in _dirs) {
        _boards[dir] = _upsertUtilityNodeForList(
          _boards[dir]!,
          enabled: enabled,
          nodeId: nodeId,
          create: () => create(dir),
        );
      }
    });
  }

  List<TextNode> _upsertUtilityNodeForList(
    List<TextNode> source, {
    required bool enabled,
    required String nodeId,
    required TextNode Function() create,
  }) {
    final nodes = [...source];
    final index = nodes.indexWhere((node) => node.id == nodeId);
    if (enabled && index < 0) {
      nodes.add(create());
    }
    if (!enabled && index >= 0) {
      nodes.removeAt(index);
    }
    return nodes;
  }

  void _applyScenarioPreset(String tab) {
    setState(() {
      _boards = {for (final dir in _dirs) dir: _buildBoard(dir)};
      _selectedNodeId = 'item_center';
      switch (tab) {
        case '地点距离':
          _showExitDistance = true;
          _showTopInfoBar = false;
          _activeSignType = '直行↑';
          break;
        case '服务区距离':
          _showExitDistance = true;
          _showTopInfoBar = true;
          _activeSignType = '直行↑';
          break;
        case '服务区和停车区预告':
          _showExitDistance = false;
          _showTopInfoBar = true;
          _activeSignType = '直行↑';
          break;
        case '道路编号和命名编号':
          _showExitDistance = false;
          _showTopInfoBar = true;
          _activeSignType = '车道指引↓';
          break;
        case '自由编辑模式':
          _showExitDistance = false;
          _showTopInfoBar = false;
          _activeSignType = '自由模式';
          break;
        default:
          break;
      }

      for (final dir in _dirs) {
        _boards[dir] = _applySignTypeToNodes(_boards[dir]!, _activeSignType);
      }
    });
  }

  void _nudgeSelected(double dx, double dy) {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) return;
    _updateNodePosition(node, node.x + dx, node.y + dy);
  }

  void _changeSelectedNodeType(String kind) {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) return;
    if (kind == '图形') {
      _updateSelected(
        node.copyWith(
          nodeType: NodeType.graphic,
          text: '',
          textEn: '',
          fillColor: null,
          borderColor: null,
          borderWidth: null,
          width: node.width.clamp(120.0, 220.0),
          height: node.height.clamp(120.0, 220.0),
          graphicType: _graphicTypeForShape(_scene.intersectionShape),
          style: const TextStyle(color: Colors.white),
        ),
      );
      return;
    }
    if (kind == '白底') {
      _updateSelected(
        node.copyWith(
          nodeType: NodeType.whiteBox,
          fillColor: Colors.white,
          backgroundColor: _scene.backgroundColor,
          borderColor: Colors.transparent,
          borderWidth: 0,
          text: node.text.isEmpty ? '地名' : node.text,
          style: TextStyle(
            color: _scene.backgroundColor,
            fontSize: node.style.fontSize ?? 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      return;
    }
    _updateSelected(
      node.copyWith(
        nodeType: NodeType.text,
        fillColor: null,
        borderColor: null,
        borderWidth: null,
        text: node.text.isEmpty ? '道路名称' : node.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: node.style.fontSize ?? 30,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _addTextRow() {
    final rows = _boards[_activeDirection]!
        .where((node) => node.slotId == 'free_row')
        .length;
    final y = 70 + rows * 42;
    final node = TextNode(
      id: 'free_row_${DateTime.now().microsecondsSinceEpoch}',
      x: 80,
      y: y.toDouble(),
      slotId: 'free_row',
      width: 360,
      height: 42,
      text: '正文 ${rows + 1}',
      textEn: _showEnglishLine ? 'Line ${rows + 1}' : '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
    setState(() {
      _boards[_activeDirection] = [..._boards[_activeDirection]!, node];
      _selectedNodeId = node.id;
    });
  }

  void _addElementBlock() {
    final node = TextNode(
      id: 'free_element_${DateTime.now().microsecondsSinceEpoch}',
      x: 90,
      y: 120,
      slotId: 'free_element',
      width: 220,
      height: 64,
      text: '附加信息',
      textEn: _showEnglishLine ? 'Additional Info' : '',
      nodeType: NodeType.whiteBox,
      fillColor: Colors.white,
      backgroundColor: _scene.backgroundColor,
      borderColor: Colors.transparent,
      borderWidth: 0,
      style: TextStyle(
        color: _scene.backgroundColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
    setState(() {
      _boards[_activeDirection] = [..._boards[_activeDirection]!, node];
      _selectedNodeId = node.id;
    });
  }

  RoadCanvasViewport _viewportModel() {
    return RoadCanvasViewport(
      zoom: _canvasZoom,
      pan: _canvasPanOffset,
      canvasSize: _template.canvasSize,
      contentOriginX: _boardContentInset,
      contentOriginY: _boardContentInset,
    );
  }

  void _startVerticalGuideFromRuler(double localX) {
    setState(() {
      _draftVerticalGuide = _viewportModel().worldFromScreenX(localX);
    });
  }

  void _updateVerticalGuideFromRuler(double localX) {
    if (_draftVerticalGuide == null) return;
    setState(() {
      _draftVerticalGuide = _viewportModel().worldFromScreenX(localX);
    });
  }

  void _commitVerticalGuide() {
    final value = _draftVerticalGuide;
    if (value == null) return;
    final clamped = value.clamp(0.0, _template.canvasSize.width).toDouble();
    setState(() {
      _verticalGuides.add(clamped);
      _verticalGuides.sort();
      _draftVerticalGuide = null;
    });
  }

  void _startHorizontalGuideFromRuler(double localY) {
    setState(() {
      _draftHorizontalGuide = _viewportModel().worldFromScreenY(localY);
    });
  }

  void _updateHorizontalGuideFromRuler(double localY) {
    if (_draftHorizontalGuide == null) return;
    setState(() {
      _draftHorizontalGuide = _viewportModel().worldFromScreenY(localY);
    });
  }

  void _commitHorizontalGuide() {
    final value = _draftHorizontalGuide;
    if (value == null) return;
    final clamped = value.clamp(0.0, _template.canvasSize.height).toDouble();
    setState(() {
      _horizontalGuides.add(clamped);
      _horizontalGuides.sort();
      _draftHorizontalGuide = null;
    });
  }

  void _cancelDraftGuide() {
    setState(() {
      _draftVerticalGuide = null;
      _draftHorizontalGuide = null;
    });
  }

  TextNode _normalizeTextBoundsIfNeeded(TextNode node) {
    if (node.nodeType == NodeType.graphic) return node;
    final style = node.style;
    final textPainter = TextPainter(
      text: TextSpan(text: node.text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _template.canvasSize.width);
    double targetWidth = textPainter.width + 24;
    double targetHeight = textPainter.height + 16;
    if ((node.textEn ?? '').isNotEmpty) {
      final enStyle = style.copyWith(
        fontSize: (style.fontSize ?? 24) * 0.42,
        fontWeight: FontWeight.w500,
      );
      final enPainter = TextPainter(
        text: TextSpan(text: node.textEn!, style: enStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _template.canvasSize.width);
      targetWidth = targetWidth > enPainter.width + 24
          ? targetWidth
          : enPainter.width + 24;
      targetHeight += enPainter.height + 4;
    }
    targetWidth = targetWidth.clamp(20, _template.canvasSize.width);
    targetHeight = targetHeight.clamp(20, _template.canvasSize.height);
    final x = node.x
        .clamp(0.0, _template.canvasSize.width - targetWidth)
        .toDouble();
    final y = node.y
        .clamp(0.0, _template.canvasSize.height - targetHeight)
        .toDouble();
    return node.copyWith(width: targetWidth, height: targetHeight, x: x, y: y);
  }

  TextNode _clampNodeToBoard(TextNode node) {
    final maxX = (_template.canvasSize.width - node.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_template.canvasSize.height - node.height).clamp(
      0.0,
      double.infinity,
    );
    return node.copyWith(x: node.x.clamp(0, maxX), y: node.y.clamp(0, maxY));
  }

  TextNode _snapNodeToGuides(TextNode node) {
    if (node.nodeType == NodeType.graphic) return node;
    final threshold = 8 / _canvasZoom;
    var snappedX = node.x;
    var snappedY = node.y;
    final centerX = node.x + node.width / 2;
    final centerY = node.y + node.height / 2;
    for (final guide in _verticalGuides) {
      if ((node.x - guide).abs() <= threshold) {
        snappedX = guide;
        break;
      }
      if ((centerX - guide).abs() <= threshold) {
        snappedX = guide - node.width / 2;
        break;
      }
    }
    for (final guide in _horizontalGuides) {
      if ((node.y - guide).abs() <= threshold) {
        snappedY = guide;
        break;
      }
      if ((centerY - guide).abs() <= threshold) {
        snappedY = guide - node.height / 2;
        break;
      }
    }
    return _clampNodeToBoard(node.copyWith(x: snappedX, y: snappedY));
  }

  void _copySelectedNode() {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) return;
    setState(() {
      _clipboardNode = node.copyWith();
    });
    _showMessage('已复制当前元素');
  }

  void _pasteClipboardNode() {
    final clipboard = _clipboardNode;
    if (clipboard == null) {
      _showMessage('剪贴板里还没有元素');
      return;
    }
    final duplicate = _cloneNode(
      clipboard,
      xOffset: 24,
      yOffset: 24,
      forceFreeSlot: true,
    );
    setState(() {
      _boards[_activeDirection] = [..._boards[_activeDirection]!, duplicate];
      _selectedNodeId = duplicate.id;
    });
    _showMessage('已粘贴元素');
  }

  void _duplicateSelectedNode() {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) return;
    final duplicate = _cloneNode(
      node,
      xOffset: 24,
      yOffset: 24,
      forceFreeSlot: true,
    );
    setState(() {
      _boards[_activeDirection] = [..._boards[_activeDirection]!, duplicate];
      _selectedNodeId = duplicate.id;
    });
    _showMessage('已复制一个副本');
  }

  void _deselectNode() {
    if (_selectedNodeId != null) {
      _disposeControllers(_selectedNodeId!);
    }
    setState(() {
      _selectedNodeId = null;
    });
  }

  void _deleteSelectedNode() {
    final selectedId = _selectedNodeId;
    if (selectedId == null) return;
    final currentNodes = _boards[_activeDirection]!;
    if (!currentNodes.any((node) => node.id == selectedId)) return;
    setState(() {
      _boards[_activeDirection] = currentNodes
          .where((node) => node.id != selectedId)
          .toList();
      _selectedNodeId = _boards[_activeDirection]!.isEmpty
          ? null
          : _boards[_activeDirection]!.last.id;
    });
    _showMessage('已删除元素');
  }

  Future<void> _showNodeContextMenu(
    TextNode node,
    Offset globalPosition,
  ) async {
    if (!mounted) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: const [
        PopupMenuItem(value: 'copy', child: Text('复制')),
        PopupMenuItem(value: 'paste', child: Text('粘贴')),
        PopupMenuItem(value: 'duplicate', child: Text('复制副本')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'bringToFront', child: Text('置于顶层')),
        PopupMenuItem(value: 'sendToBack', child: Text('置于底层')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'alignLeft', child: Text('文字居左')),
        PopupMenuItem(value: 'alignCenter', child: Text('文字居中')),
        PopupMenuItem(value: 'alignRight', child: Text('文字居右')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Text('删除')),
      ],
    );
    if (selected == null) return;
    switch (selected) {
      case 'copy':
        setState(() {
          _selectedNodeId = node.id;
        });
        _copySelectedNode();
        break;
      case 'paste':
        setState(() {
          _selectedNodeId = node.id;
        });
        _pasteClipboardNode();
        break;
      case 'duplicate':
        setState(() {
          _selectedNodeId = node.id;
        });
        _duplicateSelectedNode();
        break;
      case 'bringToFront':
        _moveNodeLayer(node.id, bringToFront: true);
        break;
      case 'sendToBack':
        _moveNodeLayer(node.id, bringToFront: false);
        break;
      case 'alignLeft':
        _setNodeAlignment(node.id, TextAlign.left);
        break;
      case 'alignCenter':
        _setNodeAlignment(node.id, TextAlign.center);
        break;
      case 'alignRight':
        _setNodeAlignment(node.id, TextAlign.right);
        break;
      case 'delete':
        setState(() {
          _selectedNodeId = node.id;
        });
        _deleteSelectedNode();
        break;
    }
  }

  void _moveNodeLayer(String nodeId, {required bool bringToFront}) {
    final nodes = [..._boards[_activeDirection]!];
    final index = nodes.indexWhere((node) => node.id == nodeId);
    if (index == -1) return;
    final node = nodes.removeAt(index);
    if (bringToFront) {
      nodes.add(node);
    } else {
      nodes.insert(0, node);
    }
    setState(() {
      _boards[_activeDirection] = nodes;
      _selectedNodeId = nodeId;
    });
  }

  void _setNodeAlignment(String nodeId, TextAlign align) {
    TextNode? node;
    for (final item in _boards[_activeDirection]!) {
      if (item.id == nodeId) {
        node = item;
        break;
      }
    }
    if (node == null || node.nodeType == NodeType.graphic) return;
    _updateSelected(node.copyWith(textAlign: align));
  }

  TextNode _cloneNode(
    TextNode node, {
    double xOffset = 0,
    double yOffset = 0,
    bool forceFreeSlot = false,
  }) {
    final maxX = _template.canvasSize.width - node.width - 12;
    final maxY = _template.canvasSize.height - node.height - 12;
    return TextNode(
      id: 'free_${DateTime.now().microsecondsSinceEpoch}',
      x: (node.x + xOffset).clamp(0, maxX),
      y: (node.y + yOffset).clamp(0, maxY),
      slotId: forceFreeSlot ? 'free' : node.slotId,
      width: node.width,
      height: node.height,
      text: node.text,
      textEn: node.textEn,
      textAlign: node.textAlign,
      style: node.style,
      nodeType: node.nodeType,
      fillColor: node.fillColor,
      backgroundColor: node.backgroundColor,
      borderColor: node.borderColor,
      borderWidth: node.borderWidth,
      graphicType: node.graphicType,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _newProject() {
    setState(() {
      _activeTopTab = '自由编辑模式';
      _activeTemplateId = RoadBoardTemplates.freeComposeId;
      _scene = IntersectionScene(
        name: '张家井',
        intersectionShape: IntersectionShape.crossroad,
        backgroundColor: const Color(0xFF20308E),
        foregroundColor: Colors.white,
        scenicColor: const Color(0xFF8B5A2B),
        north: DirectionInfo(
          roadName: '甘城路',
          roadNameEn: 'Sladizevo:puto',
          destination: '光辉园(西门)',
          destinationEn: 'Posiploda (cine koke)',
          destinationType: DestinationType.scenic,
        ),
        east: DirectionInfo(
          roadName: '西先拂街',
          roadNameEn: 'kokiSeonPhourl:puto',
          destination: '先拂天阶',
          destinationEn: 'SeonPhourlnebibibore',
        ),
        south: DirectionInfo(
          roadName: '张家井大街',
          roadNameEn: 'Dcanqovilipivebe:putumo',
          destination: '中河湾',
          destinationEn: 'Tavaputifosahure',
        ),
        west: DirectionInfo(
          roadName: '西先拂街',
          roadNameEn: 'kokiSeonPhourl:puto',
          destination: '西麦仓',
          destinationEn: 'Kokimagipume',
        ),
      );
      _junctionNameEn = 'pleme a cafone';
      _activeDirection = 'north';
      _selectedNodeId = 'item_center';
      _projectFilePath = null;
      _boards = {for (final dir in _dirs) dir: _buildBoard(dir)};
    });
    _showMessage('已新建道路项目');
  }

  Future<void> _openProject() async {
    final path = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: '打开道路项目',
    );
    final selectedPath = path?.files.single.path;
    if (selectedPath == null) return;
    final file = File(selectedPath);
    if (!await file.exists()) return;
    final content = await file.readAsString();
    final doc = RoadBoardDocument.fromJson(
      Map<String, dynamic>.from(jsonDecode(content) as Map),
    );
    setState(() {
      _activeTemplateId = RoadBoardTemplates.byId(doc.templateId) != null
          ? doc.templateId
          : RoadBoardTemplates.standardCrossroadId;
      _activeTopTab = _tabForTemplateId(_activeTemplateId);
      _scene = doc.toScene();
      _junctionNameEn = doc.junctionNameEn;
      _activeDirection = _dirs.contains(doc.activeDirection)
          ? doc.activeDirection
          : 'north';
      _boards = {
        for (final dir in _dirs)
          dir:
              doc.boards[dir]?.map((node) => node.copyWith()).toList() ??
              _buildBoard(dir),
      };
      _selectedNodeId = _boards[_activeDirection]!.isEmpty
          ? null
          : _boards[_activeDirection]!.first.id;
      _projectFilePath = selectedPath;
    });
    _showMessage('已打开道路项目');
  }

  Future<void> _saveProject() async {
    if (_projectFilePath == null) {
      await _saveProjectAs();
      return;
    }
    await _writeProjectFile(_projectFilePath!);
  }

  Future<void> _saveProjectAs() async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: '保存道路项目',
      fileName: '${_safeName(_scene.name)}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (path == null) return;
    _projectFilePath = path;
    await _writeProjectFile(path);
  }

  Future<void> _writeProjectFile(String path) async {
    final doc = RoadBoardDocument.fromEditorState(
      templateId: _template.id,
      scene: _scene,
      junctionNameEn: _junctionNameEn,
      activeDirection: _activeDirection,
      boards: _boards,
    );
    final file = File(path);
    await file.writeAsString(doc.toPrettyJson());
    if (!mounted) return;
    setState(() => _projectFilePath = path);
    _showMessage('已保存项目');
  }

  TextNode? _selectedNode(List<TextNode> nodes) {
    if (_selectedNodeId == null) return null;
    for (final node in nodes) {
      if (node.id == _selectedNodeId) return node;
    }
    return null;
  }

  void _syncBoards() {
    _boards = {for (final dir in _dirs) dir: _buildBoard(dir)};
  }

  List<TextNode> _buildBoard(String direction) {
    if (_activeTemplateId == RoadBoardTemplates.placeDistanceId) {
      return _buildPlaceDistanceBoard(direction);
    }
    if (_activeTemplateId == RoadBoardTemplates.serviceDistanceId ||
        _activeTemplateId == RoadBoardTemplates.serviceAdvanceId) {
      return _buildServiceDistanceBoard(direction);
    }
    if (_activeTemplateId == RoadBoardTemplates.routeNumberId) {
      return _buildRouteNumberBoard(direction);
    }
    if (_activeTemplateId == RoadBoardTemplates.freeComposeId) {
      return _buildFreeComposeBoard(direction);
    }
    return _buildCrossroadBoard(direction);
  }

  List<TextNode> _buildCrossroadBoard(String direction) {
    final slots = _template.slots;
    final current = direction;
    final left = _leftOf(direction);
    final right = _rightOf(direction);
    final back = _oppositeOf(direction);
    return [
      _badgeNode(
        'item_top_left',
        'topLeft',
        current,
        _scene.directionInfo(current),
        slots['topLeft']!,
      ),
      _roadNode(
        'item_top_center',
        'topCenter',
        _scene.directionInfo(current),
        slots['topCenter']!,
      ),
      _plateNode(
        'item_top_right',
        'topRight',
        _scene.directionInfo(right),
        slots['topRight']!,
      ),
      _roadNode(
        'item_left',
        'centerLeft',
        _scene.directionInfo(left),
        slots['centerLeft']!,
      ),
      TextNode(
        id: 'item_center',
        x: slots['center']!.rect.left,
        y: slots['center']!.rect.top,
        slotId: 'center',
        width: slots['center']!.rect.width,
        height: slots['center']!.rect.height,
        text: '',
        nodeType: NodeType.graphic,
        graphicType: _graphicTypeForShape(_scene.intersectionShape),
        style: TextStyle(color: _scene.foregroundColor),
      ),
      _roadNode(
        'item_right',
        'centerRight',
        _scene.directionInfo(right),
        slots['centerRight']!,
      ),
      _plateNode(
        'item_bottom_left',
        'bottomLeft',
        _scene.directionInfo(left),
        slots['bottomLeft']!,
      ),
      _roadNode(
        'item_bottom_center',
        'bottomCenter',
        _scene.directionInfo(back),
        slots['bottomCenter']!,
      ),
      _plateNode(
        'item_bottom_right',
        'bottomRight',
        _scene.directionInfo(back),
        slots['bottomRight']!,
      ),
    ];
  }

  List<TextNode> _buildPlaceDistanceBoard(String direction) {
    final slots = _template.slots;
    final titleSlot = slots['topCenter']!;
    final valueSlot = slots['topRight']!;

    String finalPlaceName = _placeName;
    if (_placePrefixIcon) finalPlaceName = '📍 $finalPlaceName';
    if (_placeSuffixIcon) finalPlaceName = '$finalPlaceName ⛽';

    return [
      TextNode(
        id: 'item_place_name',
        x: titleSlot.rect.left,
        y: titleSlot.rect.top,
        slotId: 'topCenter',
        width: titleSlot.rect.width,
        height: titleSlot.rect.height,
        text: finalPlaceName,
        textEn: _placeIncludeEnglish ? 'Place Name' : '',
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.w700,
        ),
      ),
      TextNode(
        id: 'item_place_distance',
        x: valueSlot.rect.left,
        y: valueSlot.rect.top,
        slotId: 'topRight',
        width: valueSlot.rect.width,
        height: valueSlot.rect.height,
        text: '$_placeDistanceKm km',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }

  List<TextNode> _buildServiceDistanceBoard(String direction) {
    final slots = _template.slots;
    final iconText = _serviceIcons
        .map((item) {
          switch (item) {
            case 'P':
              return 'P';
            case 'Fuel':
              return '⛽';
            case 'Food':
              return '🍴';
            case 'Repair':
              return '🛠';
            default:
              return '';
          }
        })
        .join(' ');
    return [
      TextNode(
        id: 'item_service_icons',
        x: slots['topCenter']!.rect.left,
        y: slots['topCenter']!.rect.top,
        width: slots['topCenter']!.rect.width,
        height: slots['topCenter']!.rect.height,
        text: iconText.isEmpty ? 'P ⛽ 🍴 🛠' : iconText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 64,
          fontWeight: FontWeight.w700,
        ),
      ),
      TextNode(
        id: 'item_service_name',
        x: slots['centerLeft']!.rect.left,
        y: slots['centerLeft']!.rect.top,
        width: slots['centerLeft']!.rect.width,
        height: slots['centerLeft']!.rect.height,
        text: _serviceName,
        textEn: _serviceIncludeEnglish ? 'Service Area' : '',
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.w700,
        ),
      ),
      TextNode(
        id: 'item_service_distance',
        x: slots['centerRight']!.rect.left,
        y: slots['centerRight']!.rect.top,
        width: slots['centerRight']!.rect.width,
        height: slots['centerRight']!.rect.height,
        text: _activeTemplateId == RoadBoardTemplates.serviceAdvanceId
            ? '↗'
            : '$_serviceDistanceKm km',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }

  List<TextNode> _buildRouteNumberBoard(String direction) {
    final slots = _template.slots;

    // Fallbacks just in case headers are not defined
    final ratio = _template.headerRatio ?? 0.28;
    final dividerY = _template.canvasSize.height * ratio - 2;

    return [
      TextNode(
        id: 'item_route_header',
        x: slots['topCenter']!.rect.left,
        y: slots['topCenter']!.rect.top,
        width: slots['topCenter']!.rect.width,
        height: slots['topCenter']!.rect.height,
        text: _routeRoadClass,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: _routeFontType.contains('A型')
              ? FontWeight.w500
              : FontWeight.w700,
        ),
      ),
      TextNode(
        id: 'item_route_divider',
        x: 0,
        y: dividerY,
        width: _template.canvasSize.width,
        height: 6,
        text: '',
        nodeType: NodeType.whiteBox,
        fillColor: Colors.white,
        backgroundColor: Colors.white,
        borderColor: Colors.transparent,
        borderWidth: 0,
        style: const TextStyle(fontSize: 1),
      ),
      TextNode(
        id: 'item_route_code',
        x: slots['center']!.rect.left,
        y: slots['center']!.rect.top,
        width: slots['center']!.rect.width,
        height: slots['center']!.rect.height,
        text: _routeHasBranch
            ? '$_routeMainCode$_routeBranchCode'
            : _routeMainCode,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 100,
          fontWeight: _routeFontType.contains('A型')
              ? FontWeight.w500
              : FontWeight.w800,
        ),
      ),
      TextNode(
        id: 'item_route_alias',
        x: slots['bottomCenter']!.rect.left,
        y: slots['bottomCenter']!.rect.top,
        width: slots['bottomCenter']!.rect.width,
        height: slots['bottomCenter']!.rect.height,
        text: _routeHasAlias ? _routeAlias : '',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: _routeFontType.contains('A型')
              ? FontWeight.w500
              : FontWeight.w700,
        ),
      ),
    ];
  }

  List<TextNode> _buildFreeComposeBoard(String direction) {
    return _buildCrossroadBoard(direction);
  }

  TextNode _badgeNode(
    String id,
    String slotId,
    String direction,
    DirectionInfo info,
    RoadBoardSlotSpec slot,
  ) {
    return TextNode(
      id: id,
      x: slot.rect.left,
      y: slot.rect.top,
      slotId: slotId,
      width: slot.rect.width,
      height: slot.rect.height,
      text: _dirCn(direction),
      textEn: info.roadType == RoadType.highway ? 'R' : '',
      nodeType: NodeType.whiteBox,
      fillColor: Colors.white,
      backgroundColor: _scene.backgroundColor,
      style: TextStyle(
        color: _scene.backgroundColor,
        fontSize: slot.fontSize,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  TextNode _roadNode(
    String id,
    String slotId,
    DirectionInfo info,
    RoadBoardSlotSpec slot,
  ) {
    return TextNode(
      id: id,
      x: slot.rect.left,
      y: slot.rect.top,
      slotId: slotId,
      width: slot.rect.width,
      height: slot.rect.height,
      text: info.roadName.isEmpty ? '道路名称' : info.roadName,
      textEn: info.roadNameEn,
      style: TextStyle(
        color: _scene.foregroundColor,
        fontSize: slot.fontSize,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  TextNode _plateNode(
    String id,
    String slotId,
    DirectionInfo info,
    RoadBoardSlotSpec slot,
  ) {
    final scenic = info.destinationType == DestinationType.scenic;
    return TextNode(
      id: id,
      x: slot.rect.left,
      y: slot.rect.top,
      slotId: slotId,
      width: slot.rect.width,
      height: slot.rect.height,
      text: info.destination.isEmpty ? '地点名称' : info.destination,
      textEn: info.destinationEn,
      nodeType: NodeType.whiteBox,
      fillColor: scenic ? _scene.scenicColor : Colors.white,
      backgroundColor: scenic ? Colors.white : _scene.backgroundColor,
      borderColor: scenic ? Colors.white : Colors.transparent,
      borderWidth: scenic ? 2 : 0,
      style: TextStyle(
        color: scenic ? Colors.white : _scene.backgroundColor,
        fontSize: slot.fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _addWhitePlate() {
    setState(() {
      _boards[_activeDirection] = [
        ..._boards[_activeDirection]!,
        TextNode(
          id: 'free_${DateTime.now().millisecondsSinceEpoch}',
          x: 90,
          y: 90,
          slotId: 'free',
          width: 170,
          height: 70,
          text: '白底子牌',
          textEn: 'Subtitle',
          nodeType: NodeType.whiteBox,
          fillColor: Colors.white,
          backgroundColor: _scene.backgroundColor,
          style: TextStyle(
            color: _scene.backgroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ];
    });
  }

  void _addScenicPlate() {
    setState(() {
      _boards[_activeDirection] = [
        ..._boards[_activeDirection]!,
        TextNode(
          id: 'free_${DateTime.now().millisecondsSinceEpoch}',
          x: 120,
          y: 120,
          slotId: 'free',
          width: 200,
          height: 70,
          text: '棕底子牌',
          textEn: 'Scenic Place',
          nodeType: NodeType.whiteBox,
          fillColor: _scene.scenicColor,
          backgroundColor: Colors.white,
          borderColor: Colors.white,
          borderWidth: 2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ];
    });
  }

  void _addGraphicNode() {
    setState(() {
      _boards[_activeDirection] = [
        ..._boards[_activeDirection]!,
        TextNode(
          id: 'free_${DateTime.now().millisecondsSinceEpoch}',
          x: 400,
          y: 150,
          slotId: 'free',
          width: 180,
          height: 180,
          text: '',
          nodeType: NodeType.graphic,
          graphicType: _graphicTypeForShape(_scene.intersectionShape),
          style: TextStyle(color: _scene.foregroundColor),
        ),
      ];
    });
  }

  Future<void> _saveBoardJson() async {
    final doc = RoadBoardDocument.fromEditorState(
      templateId: _template.id,
      scene: _scene,
      junctionNameEn: _junctionNameEn,
      activeDirection: _activeDirection,
      boards: _boards,
    );
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}\\board_json');
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File(
      '${dir.path}\\${_safeName('${_scene.name}_$_activeDirection')}.json',
    );
    await file.writeAsString(doc.toPrettyJson());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已保存 JSON：${file.path}')));
  }

  Future<void> _exportBoardPng() async {
    final bytes = await ExportUtils.captureWidget(_boardKey);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('导出失败')));
      return;
    }
    final path = await ExportUtils.saveImage(
      bytes,
      '${_safeName('${_scene.name}_$_activeDirection')}.png',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? '导出失败' : '已保存 PNG：$path')),
    );
  }

  String _safeName(String raw) {
    final sanitized = raw.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_').trim();
    return sanitized.isEmpty ? 'road_board' : sanitized;
  }

  String _colorNameFor(Color color) {
    for (final entry in _gbBoardColors.entries) {
      if (entry.value.toARGB32() == color.toARGB32()) {
        return entry.key;
      }
    }
    return '蓝色';
  }

  Future<void> _copyBoardPathToClipboard() async {
    final bytes = await ExportUtils.captureWidget(_boardKey);
    if (bytes == null) {
      _showMessage('复制失败：未获取到画板图像');
      return;
    }
    final path = await ExportUtils.saveImage(
      bytes,
      '${_safeName('${_scene.name}_$_activeDirection')}.png',
    );
    if (path == null) {
      _showMessage('复制失败：保存图像失败');
      return;
    }
    await Clipboard.setData(ClipboardData(text: path));
    _showMessage('已复制图片路径到剪贴板');
  }

  GraphicType _graphicTypeForShape(IntersectionShape shape) {
    switch (shape) {
      case IntersectionShape.roundabout:
      case IntersectionShape.roundaboutBridgeTop:
      case IntersectionShape.roundaboutBridgeBottom:
        return GraphicType.roundabout;
      case IntersectionShape.tJunctionFrontLeft:
      case IntersectionShape.tJunctionFrontRight:
      case IntersectionShape.tJunctionLeftRight:
        return GraphicType.tJunction;
      case IntersectionShape.yJunction:
        return GraphicType.yJunction;
      case IntersectionShape.skewLeft:
      case IntersectionShape.skewForwardLeft:
        return GraphicType.skewLeft;
      case IntersectionShape.skewRight:
      case IntersectionShape.skewForwardRight:
        return GraphicType.skewRight;
      default:
        return GraphicType.crossroad;
    }
  }

  String _dirCn(String direction) {
    return switch (direction) {
      'north' => '北',
      'east' => '东',
      'south' => '南',
      'west' => '西',
      _ => '北',
    };
  }

  String _leftOf(String direction) {
    return switch (direction) {
      'north' => 'west',
      'east' => 'north',
      'south' => 'east',
      'west' => 'south',
      _ => 'west',
    };
  }

  String _rightOf(String direction) {
    return switch (direction) {
      'north' => 'east',
      'east' => 'south',
      'south' => 'west',
      'west' => 'north',
      _ => 'east',
    };
  }

  String _oppositeOf(String direction) {
    return switch (direction) {
      'north' => 'south',
      'east' => 'west',
      'south' => 'north',
      'west' => 'east',
      _ => 'south',
    };
  }
}

class _GuideOverlayPainter extends CustomPainter {
  const _GuideOverlayPainter({
    required this.verticalGuides,
    required this.horizontalGuides,
    required this.draftVerticalGuide,
    required this.draftHorizontalGuide,
    required this.contentInset,
  });

  final List<double> verticalGuides;
  final List<double> horizontalGuides;
  final double? draftVerticalGuide;
  final double? draftHorizontalGuide;
  final double contentInset;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = const Color(0xFFEAB308).withValues(alpha: 0.75)
      ..strokeWidth = 1;
    final draftPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.9)
      ..strokeWidth = 1;

    for (final x in verticalGuides) {
      final px = x + contentInset;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), guidePaint);
    }
    for (final y in horizontalGuides) {
      final py = y + contentInset;
      canvas.drawLine(Offset(0, py), Offset(size.width, py), guidePaint);
    }
    if (draftVerticalGuide != null) {
      final x = (draftVerticalGuide! + contentInset)
          .clamp(0.0, size.width)
          .toDouble();
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), draftPaint);
    }
    if (draftHorizontalGuide != null) {
      final y = (draftHorizontalGuide! + contentInset)
          .clamp(0.0, size.height)
          .toDouble();
      canvas.drawLine(Offset(0, y), Offset(size.width, y), draftPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GuideOverlayPainter oldDelegate) {
    return oldDelegate.verticalGuides != verticalGuides ||
        oldDelegate.horizontalGuides != horizontalGuides ||
        oldDelegate.draftVerticalGuide != draftVerticalGuide ||
        oldDelegate.draftHorizontalGuide != draftHorizontalGuide ||
        oldDelegate.contentInset != contentInset;
  }
}
