import 'package:flutter/material.dart';

enum NodeType { text, whiteBox, graphic }

enum GraphicType {
  crossroad,
  tJunction,
  roundabout,
  yJunction,
  skewLeft,
  skewRight,
}

class TextNode {
  const TextNode({
    required this.id,
    required this.x,
    required this.y,
    this.slotId,
    this.width = 180,
    this.height = 80,
    required this.text,
    this.textEn,
    this.textAlign = TextAlign.left,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    this.nodeType = NodeType.text,
    this.fillColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.graphicType,
  });

  final String id;
  final double x;
  final double y;
  final String? slotId;
  final double width;
  final double height;
  final String text;
  final String? textEn;
  final TextAlign textAlign;
  final TextStyle style;
  final NodeType nodeType;
  final Color? fillColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final GraphicType? graphicType;

  TextNode copyWith({
    double? x,
    double? y,
    String? slotId,
    double? width,
    double? height,
    String? text,
    String? textEn,
    TextAlign? textAlign,
    TextStyle? style,
    NodeType? nodeType,
    Color? fillColor,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    GraphicType? graphicType,
  }) {
    return TextNode(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      slotId: slotId ?? this.slotId,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      textEn: textEn ?? this.textEn,
      textAlign: textAlign ?? this.textAlign,
      style: style ?? this.style,
      nodeType: nodeType ?? this.nodeType,
      fillColor: fillColor ?? this.fillColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      graphicType: graphicType ?? this.graphicType,
    );
  }
}

class EditableTextNode extends StatefulWidget {
  const EditableTextNode({
    super.key,
    required this.node,
    required this.onChanged,
    this.showEnField = true,
  });

  final TextNode node;
  final ValueChanged<TextNode> onChanged;
  final bool showEnField;

  @override
  State<EditableTextNode> createState() => _EditableTextNodeState();
}

class _EditableTextNodeState extends State<EditableTextNode> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  late final TextEditingController _enController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.text);
    _enController = TextEditingController(text: widget.node.textEn ?? '');
  }

  @override
  void didUpdateWidget(covariant EditableTextNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _controller.text = widget.node.text;
      _enController.text = widget.node.textEn ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _enController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onChanged(
      widget.node.copyWith(
        text: _controller.text,
        textEn: _enController.text.trim().isEmpty ? null : _enController.text,
      ),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isWhiteBox = widget.node.nodeType == NodeType.whiteBox;
    final boardBlue = const Color(0xFF20308E);
    final textColor = isWhiteBox
        ? (widget.node.backgroundColor ?? boardBlue)
        : (widget.node.style.color ?? Colors.white);
    final boxColor = widget.node.fillColor ?? Colors.white;
    final textColumnAlign = switch (widget.node.textAlign) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };

    if (_isEditing) {
      return Container(
        width: widget.node.width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWhiteBox ? boxColor : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white54),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: widget.node.textAlign,
              decoration: InputDecoration(
                hintText: '中文',
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.45)),
                isDense: true,
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.showEnField) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _enController,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: widget.node.textAlign,
                decoration: InputDecoration(
                  hintText: '英文',
                  hintStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.35),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _submit, child: const Text('应用')),
              ],
            ),
          ],
        ),
      );
    }

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textColumnAlign,
      children: [
        Text(
          widget.node.text,
          style: widget.node.style.copyWith(color: textColor),
          textAlign: widget.node.textAlign,
        ),
        if (widget.node.textEn != null && widget.node.textEn!.isNotEmpty)
          Text(
            widget.node.textEn!,
            style: widget.node.style.copyWith(
              color: textColor.withValues(alpha: 0.8),
              fontSize: (widget.node.style.fontSize ?? 24) * 0.42,
              fontWeight: FontWeight.w500,
            ),
            textAlign: widget.node.textAlign,
          ),
      ],
    );

    Widget content = SizedBox(width: widget.node.width, child: textWidget);
    if (isWhiteBox) {
      content = Container(
        width: widget.node.width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: widget.node.borderColor ?? Colors.transparent,
            width: widget.node.borderWidth ?? 0,
          ),
        ),
        child: textWidget,
      );
    }

    return GestureDetector(
      onDoubleTap: () => setState(() => _isEditing = true),
      child: content,
    );
  }
}

class GraphicNode extends StatelessWidget {
  const GraphicNode({super.key, required this.node});

  final TextNode node;

  @override
  Widget build(BuildContext context) {
    final strokeColor = node.style.color ?? Colors.white;
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = node.width * 0.048
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    return SizedBox(
      width: node.width,
      height: node.height,
      child: CustomPaint(
        painter: _IntersectionPainter(
          node.graphicType ?? GraphicType.crossroad,
          paint,
        ),
      ),
    );
  }
}

class _IntersectionPainter extends CustomPainter {
  const _IntersectionPainter(this.type, this.linePaint);

  final GraphicType type;
  final Paint linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width * 0.34;
    final halfH = size.height * 0.34;

    switch (type) {
      case GraphicType.crossroad:
        canvas.drawLine(
          Offset(center.dx, center.dy - halfH),
          Offset(center.dx, center.dy + halfH),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx - halfW, center.dy),
          Offset(center.dx + halfW, center.dy),
          linePaint,
        );
      case GraphicType.tJunction:
        canvas.drawLine(
          Offset(center.dx, center.dy + halfH),
          Offset(center.dx, center.dy - halfH * 0.2),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx - halfW * 0.85, center.dy - halfH * 0.55),
          Offset(center.dx + halfW * 0.85, center.dy - halfH * 0.55),
          linePaint,
        );
      case GraphicType.roundabout:
        canvas.drawCircle(center, size.width * 0.18, linePaint);
        canvas.drawLine(
          Offset(center.dx, center.dy - halfH),
          Offset(center.dx, center.dy - size.width * 0.18),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx + size.width * 0.18, center.dy),
          Offset(center.dx + halfW, center.dy),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy + size.width * 0.18),
          Offset(center.dx, center.dy + halfH),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx - size.width * 0.18, center.dy),
          Offset(center.dx - halfW, center.dy),
          linePaint,
        );
      case GraphicType.yJunction:
        canvas.drawLine(
          Offset(center.dx, center.dy + halfH),
          center,
          linePaint,
        );
        canvas.drawLine(
          center,
          Offset(center.dx - halfW * 0.8, center.dy - halfH),
          linePaint,
        );
        canvas.drawLine(
          center,
          Offset(center.dx + halfW * 0.8, center.dy - halfH),
          linePaint,
        );
      case GraphicType.skewLeft:
        canvas.drawLine(
          Offset(center.dx, center.dy - halfH),
          Offset(center.dx, center.dy + halfH),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx - halfW * 0.8, center.dy + halfH * 0.35),
          Offset(center.dx + halfW * 0.8, center.dy - halfH * 0.35),
          linePaint,
        );
      case GraphicType.skewRight:
        canvas.drawLine(
          Offset(center.dx, center.dy - halfH),
          Offset(center.dx, center.dy + halfH),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx - halfW * 0.8, center.dy - halfH * 0.35),
          Offset(center.dx + halfW * 0.8, center.dy + halfH * 0.35),
          linePaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _IntersectionPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.linePaint.color != linePaint.color;
  }
}

class RoadSignCanvas extends StatelessWidget {
  const RoadSignCanvas({
    super.key,
    this.width = 620,
    this.height = 760,
    this.backgroundColor = const Color(0xFF20308E),
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.interactionScale = 1,
    required this.nodes,
    required this.onNodesChanged,
    this.selectedNodeId,
    this.onNodeSelected,
    this.onNodeSecondaryTapDown,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double interactionScale;
  final List<TextNode> nodes;
  final ValueChanged<List<TextNode>> onNodesChanged;
  final String? selectedNodeId;
  final ValueChanged<String>? onNodeSelected;
  final void Function(TextNode node, Offset globalPosition)?
  onNodeSecondaryTapDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth * 0.75),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: nodes.map((node) {
                final isSelected = selectedNodeId == node.id;
                final widget = node.nodeType == NodeType.graphic
                    ? GraphicNode(node: node)
                    : EditableTextNode(
                        node: node,
                        onChanged: (updated) => _replaceNode(updated),
                      );
                final hitWidth = node.width + 28;
                final hitHeight = node.height + 24;
                return Positioned(
                  left: (node.x - 14).clamp(0.0, width - hitWidth),
                  top: (node.y - 12).clamp(0.0, height - hitHeight),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onNodeSelected?.call(node.id),
                    onSecondaryTapDown: (details) {
                      onNodeSelected?.call(node.id);
                      onNodeSecondaryTapDown?.call(
                        node,
                        details.globalPosition,
                      );
                    },
                    onPanUpdate: (details) {
                      final maxX = width - node.width - 12;
                      final maxY = height - node.height - 12;
                      final dx = details.delta.dx;
                      final dy = details.delta.dy;
                      _replaceNode(
                        node.copyWith(
                          x: (node.x + dx).clamp(0.0, maxX),
                          y: (node.y + dy).clamp(0.0, maxY),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: hitWidth,
                      height: hitHeight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.yellowAccent,
                                    width: 2,
                                  ),
                                )
                              : null,
                          child: widget,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _replaceNode(TextNode updated) {
    onNodesChanged(
      nodes.map((node) => node.id == updated.id ? updated : node).toList(),
    );
  }
}
