import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/intersection_scene.dart';
import '../models/road_board_document.dart';
import '../models/road_board_template.dart';
import '../utils/export_utils.dart';
import '../widgets/road_sign_canvas.dart';

class RoadEditorPage extends StatefulWidget {
  const RoadEditorPage({super.key});

  @override
  State<RoadEditorPage> createState() => _RoadEditorPageState();
}

class _RoadEditorPageState extends State<RoadEditorPage> {
  static const RoadBoardTemplateSpec _template =
      RoadBoardTemplates.standardCrossroad;
  static const List<String> _dirs = ['north', 'east', 'south', 'west'];

  final GlobalKey _boardKey = GlobalKey();
  final TransformationController _canvasViewController =
      TransformationController();

  late IntersectionScene _scene;
  late Map<String, List<TextNode>> _boards;
  String _junctionNameEn = 'pleme a cafone';
  String _activeDirection = 'north';
  String? _selectedNodeId = 'item_center';
  TextNode? _clipboardNode;
  String? _projectFilePath;
  double _leftPanelWidth = 260;
  double _rightPanelWidth = 260;
  double _canvasZoom = 0.78;
  int _rightPanelSection = 0;

  @override
  void initState() {
    super.initState();
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
    _boards = {for (final dir in _dirs) dir: _buildBoard(dir)};
  }

  @override
  void dispose() {
    _canvasViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _boards[_activeDirection]!;
    final selected = _selectedNode(nodes);
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyC, control: true):
              _copySelectedNode,
          const SingleActivator(LogicalKeyboardKey.keyV, control: true):
              _pasteClipboardNode,
          const SingleActivator(LogicalKeyboardKey.keyD, control: true):
              _duplicateSelectedNode,
          const SingleActivator(LogicalKeyboardKey.delete): _deleteSelectedNode,
          const SingleActivator(LogicalKeyboardKey.escape): _deselectNode,
        },
        child: Focus(
          autofocus: true,
          child: SafeArea(
            child: Column(
              children: [
                _buildToolbar(context),
                Expanded(
                  child: Row(
                    children: [
                      _buildLeftPanel(),
                      _buildPanelResizer(
                        onDrag: (delta) => setState(() {
                          _leftPanelWidth = (_leftPanelWidth + delta).clamp(
                            260.0,
                            520.0,
                          );
                        }),
                      ),
                      Expanded(child: _buildCanvasPanel(nodes, selected)),
                      _buildPanelResizer(
                        onDrag: (delta) => setState(() {
                          _rightPanelWidth = (_rightPanelWidth - delta).clamp(
                            260.0,
                            520.0,
                          );
                        }),
                      ),
                      _buildRightPanel(),
                    ],
                  ),
                ),
              ],
            ),
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
          _sectionTitle('画布样式', '颜色和路口基本设置'),
          const SizedBox(height: 12),
          _colorButton('背景色', _scene.backgroundColor, (c) {
            setState(() {
              _scene = _scene.copyWith(backgroundColor: c);
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
      ),
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
                const Spacer(),
                TextButton(
                  onPressed: _resetCanvasView,
                  child: const Text('重置视图'),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    height: _template.canvasSize.height * _canvasZoom + 28,
                    child: _buildVerticalRuler(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 28,
                          child: _buildHorizontalRuler(),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedNodeId != null) {
                                setState(() => _selectedNodeId = null);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                border: Border.all(color: const Color(0xFF475569)),
                              ),
                              child: InteractiveViewer(
                                transformationController: _canvasViewController,
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
                                    child: RoadSignCanvas(
                                      width: _template.canvasSize.width,
                                      height: _template.canvasSize.height,
                                      backgroundColor: _scene.backgroundColor,
                                      borderColor: _scene.foregroundColor,
                                      borderWidth: 2,
                                      nodes: nodes,
                                      selectedNodeId: _selectedNodeId,
                                      onNodeSelected: (id) =>
                                          setState(() => _selectedNodeId = id),
                                      onNodeSecondaryTapDown: _showNodeContextMenu,
                                      onNodesChanged: _onBoardChanged,
                                      interactionScale: _canvasZoom,
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
        ],
      ),
    );
  }

  Widget _buildRuler() {
    return const SizedBox.shrink();
  }

  Widget _buildVerticalRuler() {
    return Container(
      width: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF334155).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: CustomPaint(
        painter: _VerticalRulerPainter(
          canvasHeight: _template.canvasSize.height,
          zoom: _canvasZoom,
        ),
      ),
    );
  }

  Widget _buildHorizontalRuler() {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF334155).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: CustomPaint(
        painter: _HorizontalRulerPainter(
          canvasWidth: _template.canvasSize.width,
          zoom: _canvasZoom,
        ),
      ),
    );
  }

  Widget _buildBottomPosition(TextNode? node) {
    if (node == null) {
      return const Center(
        child: Text('请先选择一个元素', style: TextStyle(color: Colors.white38)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _positionInput('X', node.x, (v) => _updateNodePosition(node, v, null)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _positionInput('Y', node.y, (v) => _updateNodePosition(node, null, v)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _positionInput('宽', node.width, (v) => _updateNodeSize(node, v, null)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _positionInput('高', node.height, (v) => _updateNodeSize(node, null, v)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('对齐: ', style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('左', style: TextStyle(fontSize: 10)),
                selected: node.textAlign == TextAlign.left,
                onSelected: (_) => _updateSelected(node.copyWith(textAlign: TextAlign.left)),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('中', style: TextStyle(fontSize: 10)),
                selected: node.textAlign == TextAlign.center,
                onSelected: (_) => _updateSelected(node.copyWith(textAlign: TextAlign.center)),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('右', style: TextStyle(fontSize: 10)),
                selected: node.textAlign == TextAlign.right,
                onSelected: (_) => _updateSelected(node.copyWith(textAlign: TextAlign.right)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _positionInput(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ),
        Expanded(
          child: SizedBox(
            height: 32,
            child: TextField(
              controller: TextEditingController(text: value.round().toString()),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF475569)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
              onSubmitted: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) onChanged(parsed);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStyle(TextNode? node) {
    if (node == null) {
      return const Center(
        child: Text('请先选择一个元素', style: TextStyle(color: Colors.white38)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('填充颜色', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _colorSwatch(Colors.white, node.fillColor, (c) => _updateSelected(node.copyWith(fillColor: c))),
                    _colorSwatch(const Color(0xFF20308E), node.fillColor, (c) => _updateSelected(node.copyWith(fillColor: c))),
                    _colorSwatch(const Color(0xFF8B5A2B), node.fillColor, (c) => _updateSelected(node.copyWith(fillColor: c))),
                    _colorSwatch(Colors.black, node.fillColor, (c) => _updateSelected(node.copyWith(fillColor: c))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('边框颜色', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _colorSwatch(Colors.transparent, node.borderColor, (c) => _updateSelected(node.copyWith(borderColor: c))),
                    _colorSwatch(Colors.white, node.borderColor, (c) => _updateSelected(node.copyWith(borderColor: c))),
                    _colorSwatch(const Color(0xFF20308E), node.borderColor, (c) => _updateSelected(node.copyWith(borderColor: c))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('边框宽度', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: (node.borderWidth ?? 0).toDouble(),
                        min: 0,
                        max: 8,
                        onChanged: (v) => _updateSelected(node.copyWith(borderWidth: v)),
                      ),
                    ),
                    Text('${node.borderWidth ?? 0}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSwatch(Color color, Color? current, ValueChanged<Color> onSelected) {
    final isSelected = current?.toARGB32() == color.toARGB32();
    return InkWell(
      onTap: () => onSelected(color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomText(TextNode? node) {
    if (node == null) {
      return const Center(
        child: Text('请先选择一个元素', style: TextStyle(color: Colors.white38)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('中文内容', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: TextEditingController(text: node.text),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    onSubmitted: (v) => _updateSelected(node.copyWith(text: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('英文内容', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: TextEditingController(text: node.textEn ?? ''),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    onSubmitted: (v) => _updateSelected(node.copyWith(textEn: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('字号', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: TextEditingController(text: node.style.fontSize?.round().toString() ?? '24'),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    onSubmitted: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null) {
                        _updateSelected(node.copyWith(style: node.style.copyWith(fontSize: parsed)));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLayer(TextNode? node) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('图层操作', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.flip_to_front, size: 14),
                label: const Text('置于顶层', style: TextStyle(fontSize: 11)),
                onPressed: node != null ? () => _moveNodeLayer(node.id, bringToFront: true) : null,
              ),
              ActionChip(
                avatar: const Icon(Icons.flip_to_back, size: 14),
                label: const Text('置于底层', style: TextStyle(fontSize: 11)),
                onPressed: node != null ? () => _moveNodeLayer(node.id, bringToFront: false) : null,
              ),
              ActionChip(
                avatar: const Icon(Icons.content_copy, size: 14),
                label: const Text('复制副本', style: TextStyle(fontSize: 11)),
                onPressed: _duplicateSelectedNode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '当前方向元素数量: ${_boards[_activeDirection]!.length}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
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
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionTitle('四向预览', '点击切换方向'),
        const SizedBox(height: 8),
        ..._dirs.map(_buildPreviewCard),
      ],
    );
  }

  Widget _buildPropertyPanel() {
    final node = _selectedNode(_boards[_activeDirection]!);
    if (node == null) {
      return const Center(
        child: Text(
          '请在画布上选择一个元素',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
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
          _propertySlider('X', node.x, 0, 600, (v) => _updateNodePosition(node, v, null)),
          _propertySlider('Y', node.y, 0, 400, (v) => _updateNodePosition(node, null, v)),
          _propertySlider('宽', node.width, 50, 400, (v) => _updateNodeSize(node, v, null)),
          _propertySlider('高', node.height, 30, 300, (v) => _updateNodeSize(node, null, v)),
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
    _textControllers.remove('$nodeId\_text')?.dispose();
    _textControllers.remove('$nodeId\_textEn')?.dispose();
  }

  TextEditingController _getController(String nodeId, String field, String initialValue) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  Widget _propertySlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
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
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.round().toString(),
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
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1F2937),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
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
    _updateSelected(node.copyWith(
      x: x ?? node.x,
      y: y ?? node.y,
    ));
  }

  void _updateNodeSize(TextNode node, double? w, double? h) {
    _updateSelected(node.copyWith(
      width: w ?? node.width,
      height: h ?? node.height,
    ));
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
                  backgroundColor: _scene.backgroundColor,
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
    setState(() {
      _boards[_activeDirection] = nodes;
    });
  }

  void _resetCanvasView() {
    _canvasViewController.value = Matrix4.identity();
    setState(() {
      _canvasZoom = 0.78;
    });
  }

  void _updateSelected(TextNode updated) {
    final nodes = _boards[_activeDirection]!
        .map((node) => node.id == updated.id ? updated : node)
        .toList();
    _onBoardChanged(nodes);
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
          text: '鐧藉簳瀛愮墝',
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
          text: '妫曞簳瀛愮墝',
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
    ).showSnackBar(SnackBar(content: Text('宸蹭繚瀛?JSON锛?{file.path}')));
  }

  Future<void> _exportBoardPng() async {
    final bytes = await ExportUtils.captureWidget(_boardKey);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('瀵煎嚭澶辫触')));
      return;
    }
    final path = await ExportUtils.saveImage(
      bytes,
      '${_safeName('${_scene.name}_$_activeDirection')}.png',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? '瀵煎嚭澶辫触' : '宸蹭繚瀛?PNG锛?path')),
    );
  }

  String _safeName(String raw) {
    final sanitized = raw.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_').trim();
    return sanitized.isEmpty ? 'road_board' : sanitized;
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

class _HorizontalRulerPainter extends CustomPainter {
  final double canvasWidth;
  final double zoom;

  _HorizontalRulerPainter({required this.canvasWidth, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    const step = 50;

    for (double x = 0; x <= canvasWidth; x += step) {
      final dx = x * zoom;
      final isMajor = x % 100 == 0;
      
      canvas.drawLine(
        Offset(dx, isMajor ? 0 : size.height * 0.4),
        Offset(dx, size.height),
        isMajor ? majorTickPaint : tickPaint,
      );
      
      if (isMajor && x > 0) {
        final textSpan = TextSpan(text: x.toInt().toString(), style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(dx - textPainter.width / 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalRulerPainter oldDelegate) {
    return oldDelegate.canvasWidth != canvasWidth || oldDelegate.zoom != zoom;
  }
}

class _VerticalRulerPainter extends CustomPainter {
  final double canvasHeight;
  final double zoom;

  _VerticalRulerPainter({required this.canvasHeight, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    const step = 50;

    for (double y = 0; y <= canvasHeight; y += step) {
      final dy = y * zoom;
      final isMajor = y % 100 == 0;
      
      canvas.drawLine(
        Offset(0, dy),
        Offset(isMajor ? size.width : size.width * 0.6, dy),
        isMajor ? majorTickPaint : tickPaint,
      );
      
        if (isMajor && y > 0) {
        final textSpan = TextSpan(text: y.toInt().toString(), style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(2, dy - textPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_VerticalRulerPainter oldDelegate) {
    return oldDelegate.canvasHeight != canvasHeight || oldDelegate.zoom != zoom;
  }
}
