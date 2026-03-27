import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/metro_guide_models.dart';
import '../models/metro_models.dart';
import '../theme/app_theme.dart';
import '../utils/metro_guide_spacing.dart';
import 'metro_guide_item.dart';

class MetroGuideCanvas extends StatefulWidget {
  final List<MetroGuideItem> items;
  final Function(List<MetroGuideItem>) onItemsChanged;
  final Function(String) onEditItem;
  final Function(bool) onHistoryChanged;
  final MetroCityStyle city;
  final Color backgroundColor;

  const MetroGuideCanvas({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onEditItem,
    required this.onHistoryChanged,
    required this.city,
    this.backgroundColor = const Color(0xFF001D31),
  });

  @override
  State<MetroGuideCanvas> createState() => MetroGuideCanvasState();
}

class MetroGuideCanvasState extends State<MetroGuideCanvas> {
  final List<List<MetroGuideItem>> _history = [];
  int _historyIndex = -1;
  String? _activeItemId;
  String _lastSnapshot = '';

  @override
  void initState() {
    super.initState();
    _syncHistory(widget.items, reset: true);
  }

  @override
  void didUpdateWidget(covariant MetroGuideCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameItems(oldWidget.items, widget.items)) {
      _syncHistory(widget.items);
    }
  }

  void undo() {
    if (_historyIndex <= 0) return;
    _historyIndex -= 1;
    final items = List<MetroGuideItem>.from(_history[_historyIndex]);
    _lastSnapshot = _snapshot(items);
    widget.onItemsChanged(items);
    _notifyHistoryChange();
  }

  void redo() {
    if (_historyIndex >= _history.length - 1) return;
    _historyIndex += 1;
    final items = List<MetroGuideItem>.from(_history[_historyIndex]);
    _lastSnapshot = _snapshot(items);
    widget.onItemsChanged(items);
    _notifyHistoryChange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBg,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.items.isEmpty ? _buildEmptyCanvas() : _buildCanvasRow(),
        ),
      ),
    );
  }

  Widget _buildEmptyCanvas() {
    return DragTarget<MetroGuideItem>(
      onAcceptWithDetails: (details) => _insertItem(0, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHovering
                      ? Icons.add_circle_outline
                      : Icons.swipe_right_alt_outlined,
                  size: 42,
                  color: isHovering ? AppTheme.primaryColor : Colors.white54,
                ),
                const SizedBox(height: 12),
                Text(
                  isHovering ? '松开即可添加到画布' : '拖拽左侧素材到这里，开始拼接导向牌',
                  style: TextStyle(
                    color: isHovering ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvasRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            _buildDropGap(0, 18),
            for (var index = 0; index < widget.items.length; index++) ...[
              _buildCanvasItem(widget.items[index], index),
              _buildDropGap(index + 1, _spacingAfter(index)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasItem(MetroGuideItem item, int index) {
    return LongPressDraggable<MetroGuideItem>(
      data: item,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: MetroGuideItemWidget(
            item: item,
            city: widget.city,
            isActive: _activeItemId == item.id,
            isDragging: true,
            onTap: () {},
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: MetroGuideItemWidget(
          item: item,
          city: widget.city,
          isActive: _activeItemId == item.id,
          onTap: () {},
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _activeItemId = item.id),
        onSecondaryTapDown: (details) =>
            _showContextMenu(details.globalPosition, item, index),
        child: MetroGuideItemWidget(
          item: item,
          city: widget.city,
          isActive: _activeItemId == item.id,
          onTap: () => setState(() => _activeItemId = item.id),
        ),
      ),
    );
  }

  Widget _buildDropGap(int targetIndex, double width) {
    final gapWidth = width <= 0 ? 10.0 : width;
    return DragTarget<MetroGuideItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => _insertItem(targetIndex, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: isHovering ? gapWidth + 18 : gapWidth,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isHovering
                ? Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.9),
                    width: 2,
                  )
                : null,
            color: isHovering
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
        );
      },
    );
  }

  void _insertItem(int index, MetroGuideItem payload) {
    final items = List<MetroGuideItem>.from(widget.items);
    final sourceIndex = items.indexWhere((item) => item.id == payload.id);
    if (sourceIndex != -1) {
      final movingItem = items.removeAt(sourceIndex);
      var insertIndex = index;
      if (sourceIndex < index) {
        insertIndex -= 1;
      }
      items.insert(insertIndex.clamp(0, items.length), movingItem);
    } else {
      final source = payload;
      items.insert(
        index.clamp(0, items.length),
        MetroGuideItem(
          fileName: source.fileName,
          type: source.type,
          customUrl: source.customUrl,
          customSvgContent: source.customSvgContent,
          customText: source.customText,
          customColor: source.customColor,
          hasColorBand: source.hasColorBand,
          colorBandColor: source.colorBandColor,
        ),
      );
    }
    _pushItems(items);
  }

  void _moveItem(int from, int to) {
    final items = List<MetroGuideItem>.from(widget.items);
    final item = items.removeAt(from);
    items.insert(to.clamp(0, items.length), item);
    _pushItems(items);
  }

  void _duplicateItem(int index) {
    final item = widget.items[index];
    final items = List<MetroGuideItem>.from(widget.items)
      ..insert(
        index + 1,
        MetroGuideItem(
          fileName: item.fileName,
          type: item.type,
          customUrl: item.customUrl,
          customSvgContent: item.customSvgContent,
          customText: item.customText,
          customColor: item.customColor,
          hasColorBand: item.hasColorBand,
          colorBandColor: item.colorBandColor,
        ),
      );
    _pushItems(items);
  }

  void _deleteItem(int index) {
    final items = List<MetroGuideItem>.from(widget.items)..removeAt(index);
    _pushItems(items);
  }

  Future<void> _showContextMenu(
    Offset position,
    MetroGuideItem item,
    int index,
  ) async {
    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: AppTheme.darkBgSecondary,
      items: [
        if (index > 0)
          const PopupMenuItem(
            value: 'left',
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 16),
                SizedBox(width: 8),
                Text('左移'),
              ],
            ),
          ),
        if (index < widget.items.length - 1)
          const PopupMenuItem(
            value: 'right',
            child: Row(
              children: [
                Icon(Icons.arrow_forward, size: 16),
                SizedBox(width: 8),
                Text('右移'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy, size: 16),
              SizedBox(width: 8),
              Text('复制'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    switch (value) {
      case 'left':
        _moveItem(index, index - 1);
        break;
      case 'right':
        _moveItem(index, index + 1);
        break;
      case 'duplicate':
        _duplicateItem(index);
        break;
      case 'edit':
        widget.onEditItem(item.id);
        break;
      case 'delete':
        _deleteItem(index);
        break;
    }
  }

  double _spacingAfter(int index) {
    if (index >= widget.items.length - 1) {
      return 18;
    }
    final current = widget.items[index];
    final next = widget.items[index + 1];
    return MetroGuideSpacing.getDynamicSpacing(
      current.fileName,
      next.fileName,
      current.type.name,
      next.type.name,
    );
  }

  void _pushItems(List<MetroGuideItem> items) {
    final snapshot = _snapshot(items);
    if (snapshot == _lastSnapshot) return;

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(List<MetroGuideItem>.from(items));
    _historyIndex = _history.length - 1;
    _lastSnapshot = snapshot;
    widget.onItemsChanged(items);
    _notifyHistoryChange();
  }

  void _syncHistory(List<MetroGuideItem> items, {bool reset = false}) {
    final snapshot = _snapshot(items);
    if (!reset && snapshot == _lastSnapshot) return;

    if (reset) {
      _history
        ..clear()
        ..add(List<MetroGuideItem>.from(items));
      _historyIndex = 0;
    } else {
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(List<MetroGuideItem>.from(items));
      _historyIndex = _history.length - 1;
    }

    _lastSnapshot = snapshot;
    _notifyHistoryChange();
  }

  void _notifyHistoryChange() {
    widget.onHistoryChanged(_historyIndex > 0);
  }

  bool _sameItems(List<MetroGuideItem> a, List<MetroGuideItem> b) {
    return _snapshot(a) == _snapshot(b);
  }

  String _snapshot(List<MetroGuideItem> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }
}
