import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/metro_models.dart';
import '../models/metro_guide_models.dart';
import '../painters/metro_painter.dart';
import '../theme/app_theme.dart';
import '../widgets/metro_guide_canvas.dart';
import '../widgets/metro_guide_toolbar.dart';

class MetroEditorPage extends StatefulWidget {
  const MetroEditorPage({super.key});

  @override
  State<MetroEditorPage> createState() => _MetroEditorPageState();
}

class _MetroEditorPageState extends State<MetroEditorPage>
    with SingleTickerProviderStateMixin {
  String? _currentFilePath;
  String _projectName = '新项目';
  bool _hasUnsavedChanges = false;

  MetroCityStyle _selectedCity = MetroCityStyle.shanghai;
  MetroCityConfig _cityConfig = MetroCityConfig.shanghai;
  MetroTemplate? _selectedMetroTemplate;
  Map<String, dynamic> _metroSlotValues = {};
  String? _selectedMetroSlotId;

  List<MetroGuideItem> _guideItems = [];

  late TabController _leftTabController;

  @override
  void initState() {
    super.initState();
    _leftTabController = TabController(length: 2, vsync: this);
    _leftTabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _selectedMetroTemplate = MetroTemplatePresets.getByCity(
      _selectedCity,
    ).first;
    _initMetroSlotValues();
  }

  @override
  void dispose() {
    _leftTabController.dispose();
    super.dispose();
  }

  void _initMetroSlotValues() {
    _metroSlotValues = {};
    for (final slot in _selectedMetroTemplate?.slots ?? []) {
      _metroSlotValues[slot.id] = slot.type == 'line_badge'
          ? MetroLine.shanghaiLines.first
          : '';
    }
  }

  bool get _isGuideMode => _leftTabController.index == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildLeftPanel(),
          Expanded(child: _buildMainArea()),
          _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 280,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          _buildCitySelector(),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: TabBar(
              controller: _leftTabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryDark,
              indicatorColor: AppTheme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '模板库'),
                Tab(text: '素材库'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _leftTabController,
              children: [_buildMetroTemplateList(), _buildGuideToolbar()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择城市',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: MetroCityConfig.all.map((city) {
              final isSelected = _selectedCity == city.style;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCity = city.style;
                    _cityConfig = city;
                    _selectedMetroTemplate = MetroTemplatePresets.getByCity(
                      _selectedCity,
                    ).first;
                    _initMetroSlotValues();
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.darkBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.darkBorder,
                    ),
                  ),
                  child: Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textPrimaryDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetroTemplateList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Text(
            '选择模板',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: MetroTemplatePresets.getByCity(_selectedCity).length,
            itemBuilder: (context, index) {
              final template = MetroTemplatePresets.getByCity(
                _selectedCity,
              )[index];
              return _buildMetroTemplateItem(template);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetroTemplateItem(MetroTemplate template) {
    final isSelected = _selectedMetroTemplate?.id == template.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMetroTemplate = template;
            _initMetroSlotValues();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildMetroTemplatePreview(template),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${template.canvasSize.width.toInt()}x${template.canvasSize.height.toInt()}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetroTemplatePreview(MetroTemplate template) {
    final previewSize = Size(
      template.canvasSize.width * 0.22,
      template.canvasSize.height * 0.22,
    );
    return Container(
      width: 78,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2234),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: CustomPaint(
            size: previewSize,
            painter: MetroTemplatePainter(
              template: template,
              slotValues: _buildTemplatePreviewValues(template),
              cityConfig: _cityConfig,
              selectedSlotId: null,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildTemplatePreviewValues(MetroTemplate template) {
    final line = MetroLine.getLines(_selectedCity).first;
    final values = <String, dynamic>{};
    for (final slot in template.slots) {
      switch (slot.type) {
        case 'line':
          values[slot.id] = line;
          break;
        case 'exit_badge':
          values[slot.id] = 'A1';
          break;
        case 'text':
          values[slot.id] = _templatePreviewText(slot.id);
          break;
      }
    }
    return values;
  }

  String _templatePreviewText(String slotId) {
    switch (slotId) {
      case 'name_cn':
        return '人民广场';
      case 'name_en':
        return 'People\'s Square';
      case 'dest_cn':
        return '虹桥火车站';
      case 'dest_en':
        return 'Hongqiao Railway Station';
      case 'next_cn':
        return '下一站';
      case 'next_en':
        return 'Next';
      case 'dist':
        return '2站 / 5 min';
      case 'info_cn':
        return '1号口 站厅 / 商业 / 换乘';
      case 'info_en':
        return 'Concourse / Shops / Transfer';
      case 'transfer_label':
        return '换乘 Transfer';
      case 'line1_name':
        return '1号线';
      case 'line2_name':
        return '2号线';
      case 'transfer_info':
        return '站厅换乘';
      case 'line_name_cn':
        return '1号线';
      case 'line_name_en':
        return 'Line 1';
      case 'direction':
        return '往莘庄方向';
      default:
        return '示例';
    }
  }

  // ignore: unused_element
  IconData _getMetroIcon(MetroTemplate template) {
    if (template.name.contains('站名')) return Icons.subway;
    if (template.name.contains('方向')) return Icons.signpost;
    if (template.name.contains('出口')) return Icons.exit_to_app;
    if (template.name.contains('换乘')) return Icons.sync_alt;
    if (template.name.contains('线路')) return Icons.route;
    return Icons.signpost;
  }

  Widget _buildGuideToolbar() {
    return MetroGuideToolbar(
      onAddItem: _addGuideItem,
      onEditItem: _editGuideItem,
      onAddText: _showTextDialog,
      onAddColorBand: _showColorBandDialog,
      city: _selectedCity,
    );
  }

  void _addGuideItem(MetroGuideItem item) {
    setState(() {
      _guideItems = [..._guideItems, item];
      _hasUnsavedChanges = true;
    });
  }

  void _editGuideItem(String itemId) {
    _showEditDialog(itemId);
  }

  Widget _buildMainArea() {
    return Container(
      color: AppTheme.darkBg,
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildCanvas()),
          _buildStatusBar(),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildElementsBar() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Text(
                  '已添加元素',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_guideItems.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<MetroGuideItem>(
              onAcceptWithDetails: (details) {
                final item = details.data;
                final newItem = MetroGuideItem(
                  fileName: item.fileName,
                  type: item.type,
                  customText: item.customText,
                  customColor: item.customColor,
                  hasColorBand: item.hasColorBand,
                  colorBandColor: item.colorBandColor,
                );
                setState(() {
                  _guideItems = [..._guideItems, newItem];
                  _hasUnsavedChanges = true;
                });
              },
              builder: (context, candidateData, rejectedData) {
                if (_guideItems.isEmpty) {
                  return Center(
                    child: Text(
                      candidateData.isNotEmpty ? '松开添加' : '拖拽左侧素材到这里',
                      style: TextStyle(
                        color: candidateData.isNotEmpty
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _guideItems.length,
                  itemBuilder: (context, index) {
                    final item = _guideItems[index];
                    return _buildElementChip(item, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip(MetroGuideItem item, int index) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getGuideItemIcon(item.type),
            size: 20,
            color: AppTheme.textPrimaryDark,
          ),
          const SizedBox(height: 4),
          Text(
            _getGuideItemName(item),
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textSecondaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: () {
              setState(() {
                _guideItems = List.from(_guideItems)..removeAt(index);
                _hasUnsavedChanges = true;
              });
            },
            child: const Icon(
              Icons.close,
              size: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGuideItemIcon(GuideItemType type) {
    switch (type) {
      case GuideItemType.line:
        return Icons.circle;
      case GuideItemType.cls:
        return Icons.palette;
      case GuideItemType.clss:
        return Icons.view_column;
      case GuideItemType.sub:
        return Icons.horizontal_rule;
      case GuideItemType.text:
        return Icons.text_fields;
      case GuideItemType.way:
        return Icons.route;
      case GuideItemType.stn:
        return Icons.subway;
      case GuideItemType.oth:
        return Icons.more_horiz;
    }
  }

  String _getGuideItemName(MetroGuideItem item) {
    switch (item.type) {
      case GuideItemType.line:
        return '线路标识';
      case GuideItemType.cls:
        return '颜色块';
      case GuideItemType.clss:
        return '双线';
      case GuideItemType.sub:
        return '色带';
      case GuideItemType.text:
        return item.customText?.cn ?? '文本';
      case GuideItemType.way:
        return '路径';
      case GuideItemType.stn:
        return '站点';
      case GuideItemType.oth:
        return '其他';
    }
  }

  Widget _buildToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            tooltip: '返回',
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      '$_projectName${_hasUnsavedChanges ? ' *' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 12),
                    Text('新建项目'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 18),
                    SizedBox(width: 12),
                    Text('打开项目'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 18),
                    SizedBox(width: 12),
                    Text('保存'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'saveas',
                child: Row(
                  children: [
                    Icon(Icons.save_as, size: 18),
                    SizedBox(width: 12),
                    Text('另存为...'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 12),
                    Text('项目设置'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'new':
                  _newProject();
                  break;
                case 'open':
                  _openProject();
                  break;
                case 'save':
                  _saveProject();
                  break;
                case 'saveas':
                  _saveProjectAs();
                  break;
                case 'settings':
                  _showProjectSettings();
                  break;
              }
            },
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _cityConfig.defaultBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _cityConfig.name,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Text(
              _selectedMetroTemplate?.name ?? '未选择模板',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimaryDark,
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _exportImage,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('导出PNG'),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    if (_isGuideMode) {
      return MetroGuideCanvas(
        items: _guideItems,
        onItemsChanged: (items) {
          setState(() {
            _guideItems = items;
            _hasUnsavedChanges = true;
          });
        },
        onEditItem: _editGuideItem,
        onHistoryChanged: (_) {},
        city: _selectedCity,
        backgroundColor: const Color(0xFF001D31),
      );
    }

    if (_selectedMetroTemplate == null) {
      return const Center(
        child: Text(
          '请选择模板',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2234),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            scrollDirection: Axis.horizontal,
            child: CustomPaint(
              size: Size(
                _selectedMetroTemplate!.canvasSize.width,
                _selectedMetroTemplate!.canvasSize.height,
              ),
              painter: MetroTemplatePainter(
                template: _selectedMetroTemplate!,
                slotValues: _metroSlotValues,
                cityConfig: _cityConfig,
                selectedSlotId: _selectedMetroSlotId,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentFilePath ?? '新建项目 - 点击左上角菜单保存',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _selectedMetroTemplate != null
                ? '${_selectedMetroTemplate!.name} ${_selectedMetroTemplate!.canvasSize.width.toInt()}x${_selectedMetroTemplate!.canvasSize.height.toInt()}'
                : '未选择模板',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_guideItems.length} 个元素',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          if (_hasUnsavedChanges) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '未保存',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: const Row(
              children: [
                Text(
                  '编辑内容',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColorPresets(),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.darkBorder),
                  const SizedBox(height: 16),
                  const Text(
                    '模板内容',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedMetroTemplate != null)
                    ..._selectedMetroTemplate!.slots
                        .where((s) => s.editable)
                        .map((slot) => _buildSlotEditor(slot))
                  else
                    const Text(
                      '请在左侧选择模板',
                      style: TextStyle(color: AppTheme.textSecondaryDark),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '城市风格',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MetroCityConfig.all.map((city) {
            final isSelected = _selectedCity == city.style;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCity = city.style;
                  _cityConfig = city;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? city.defaultBgColor : AppTheme.darkBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.darkBorder,
                  ),
                ),
                child: Text(
                  city.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlotEditor(MetroSlot slot) {
    final isSelected = _selectedMetroSlotId == slot.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedMetroSlotId = slot.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSlotIcon(slot.type),
                    size: 14,
                    color: AppTheme.textSecondaryDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slot.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (slot.type == 'line')
                _buildLineSelector()
              else if (slot.type == 'arrow_right' ||
                  slot.type == 'arrow_left' ||
                  slot.type == 'arrow_up' ||
                  slot.type == 'arrow_down')
                _buildArrowSelector()
              else
                _buildTextInput(slot),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSlotIcon(String type) {
    switch (type) {
      case 'line':
        return Icons.circle;
      case 'arrow_right':
        return Icons.arrow_forward;
      case 'arrow_left':
        return Icons.arrow_back;
      case 'arrow_up':
        return Icons.arrow_upward;
      case 'arrow_down':
        return Icons.arrow_downward;
      default:
        return Icons.text_fields;
    }
  }

  Widget _buildLineSelector() {
    final lines = MetroLine.getLines(_selectedCity);
    final selectedLine = _metroSlotValues[_selectedMetroSlotId] as MetroLine?;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: lines.take(10).map((line) {
        final isSelected = selectedLine?.number == line.number;
        return InkWell(
          onTap: () =>
              setState(() => _metroSlotValues[_selectedMetroSlotId!] = line),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: line.lineColor,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${line.number}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArrowSelector() {
    final directions = ['up', 'down', 'left', 'right'];
    final labels = ['↑', '↓', '←', '→'];
    return Row(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => setState(
              () => _metroSlotValues[_selectedMetroSlotId!] = directions[i],
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.darkBgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Center(
                child: Text(labels[i], style: const TextStyle(fontSize: 16)),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput(MetroSlot slot) {
    return TextField(
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimaryDark),
      decoration: InputDecoration(
        hintText: '输入${slot.label}...',
        hintStyle: const TextStyle(color: AppTheme.textSecondaryDark),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppTheme.darkBgSecondary,
      ),
      controller: TextEditingController(
        text: _metroSlotValues[slot.id]?.toString() ?? '',
      ),
      onChanged: (v) => setState(() => _metroSlotValues[slot.id] = v),
    );
  }

  void _showTextDialog() {
    final cnController = TextEditingController();
    final enController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('添加文本框', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cnController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '中文文本',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: enController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '英文文本',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _addGuideItem(
                MetroGuideItem(
                  fileName: 'text@custom.svg',
                  type: GuideItemType.text,
                  customText: CustomText(
                    cn: cnController.text,
                    en: enController.text,
                  ),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showColorBandDialog() {
    String selectedColor = '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('添加色带', style: TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  '#E4002B',
                  '#A09A39',
                  '#FAC000',
                  '#008C44',
                  '#823130',
                  '#AA7F3E',
                  '#E60085',
                  '#00A1DE',
                  '#8FC2E3',
                  '#98C5A3',
                ].map((color) {
                  return InkWell(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(8),
                        border: selectedColor == color
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                _addGuideItem(
                  MetroGuideItem(
                    fileName: 'sub@custom.svg',
                    type: GuideItemType.sub,
                    hasColorBand: true,
                    colorBandColor: selectedColor,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String itemId) {
    final item = _guideItems.firstWhere((i) => i.id == itemId);

    if (item.type == GuideItemType.line ||
        item.type == GuideItemType.cls ||
        item.type == GuideItemType.clss) {
      _showColorEditDialog(item);
    } else if (item.type == GuideItemType.text) {
      _showTextEditDialog(item);
    } else if (item.type == GuideItemType.sub) {
      _showColorBandEditDialog(item);
    }
  }

  void _showTextEditDialog(MetroGuideItem item) {
    final cnController = TextEditingController(text: item.customText?.cn ?? '');
    final enController = TextEditingController(text: item.customText?.en ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('编辑文本', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cnController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '中文',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: enController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '英文',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final index = _guideItems.indexWhere((i) => i.id == item.id);
              if (index != -1) {
                final updated = item.copyWith(
                  customText: CustomText(
                    cn: cnController.text,
                    en: enController.text,
                  ),
                );
                setState(() {
                  _guideItems = List.from(_guideItems)..[index] = updated;
                  _hasUnsavedChanges = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showColorEditDialog(MetroGuideItem item) {
    String selectedColor = item.customColor ?? '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('更改颜色', style: TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  '#E4002B',
                  '#A09A39',
                  '#FAC000',
                  '#008C44',
                  '#823130',
                  '#AA7F3E',
                  '#E60085',
                  '#00A1DE',
                  '#8FC2E3',
                  '#98C5A3',
                  '#DA81A6',
                  '#5F6D3F',
                  '#8E3700',
                  '#4D3700',
                  '#BF83BC',
                  '#7D8B2F',
                  '#6D4C7D',
                  '#B75700',
                ].map((color) {
                  return InkWell(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _guideItems.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final updated = item.copyWith(customColor: selectedColor);
                  setState(() {
                    _guideItems = List.from(_guideItems)..[index] = updated;
                    _hasUnsavedChanges = true;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorBandEditDialog(MetroGuideItem item) {
    String selectedColor = item.colorBandColor ?? '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('编辑色带', style: TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  '#E4002B',
                  '#A09A39',
                  '#FAC000',
                  '#008C44',
                  '#823130',
                  '#AA7F3E',
                  '#E60085',
                  '#00A1DE',
                  '#8FC2E3',
                  '#98C5A3',
                ].map((color) {
                  return InkWell(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(8),
                        border: selectedColor == color
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _guideItems.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final updated = item.copyWith(colorBandColor: selectedColor);
                  setState(() {
                    _guideItems = List.from(_guideItems)..[index] = updated;
                    _hasUnsavedChanges = true;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.substring(1);
        if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      }
      return const Color(0xFF001D31);
    } catch (e) {
      return const Color(0xFF001D31);
    }
  }

  void _exportImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导出功能开发中...')));
  }

  void _newProject() {
    setState(() {
      _projectName = '新项目';
      _currentFilePath = null;
      _guideItems = [];
      _selectedMetroTemplate = MetroTemplatePresets.getByCity(
        _selectedCity,
      ).first;
      _initMetroSlotValues();
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _openProject() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['vgp', 'json', 'ved'],
        dialogTitle: '打开项目',
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        setState(() {
          _projectName = json['name'] as String? ?? '新项目';
          _currentFilePath = file.path;
          _hasUnsavedChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('项目已打开')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProject() async {
    try {
      String? filePath = _currentFilePath;
      if (filePath == null) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '保存项目',
          fileName: '$_projectName.vgp',
          allowedExtensions: ['vgp'],
          type: FileType.custom,
        );
        if (result == null) return;
        filePath = result.endsWith('.vgp') ? result : '$result.vgp';
      }

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'city': _selectedCity.name,
        'templateId': _selectedMetroTemplate?.id,
        'slotValues': _metroSlotValues,
        'items': _guideItems.map((e) => e.toJson()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };

      await File(
        filePath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已保存到: $filePath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProjectAs() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '另存为',
        fileName: '$_projectName.vgp',
        allowedExtensions: ['vgp'],
        type: FileType.custom,
      );
      if (result == null) return;

      String filePath = result.endsWith('.vgp') ? result : '$result.vgp';

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'city': _selectedCity.name,
        'templateId': _selectedMetroTemplate?.id,
        'slotValues': _metroSlotValues,
        'items': _guideItems.map((e) => e.toJson()).toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };

      await File(
        filePath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已保存到: $filePath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showProjectSettings() {
    final nameController = TextEditingController(text: _projectName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('项目设置', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: '项目名称',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _projectName = nameController.text.trim();
                  _hasUnsavedChanges = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
