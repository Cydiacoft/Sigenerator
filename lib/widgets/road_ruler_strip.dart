import 'package:flutter/material.dart';

import '../models/road_canvas_viewport.dart';

enum RulerAxis { horizontal, vertical }

class RoadRulerStrip extends StatelessWidget {
  const RoadRulerStrip({
    super.key,
    required this.axis,
    required this.viewport,
    this.backgroundColor = const Color(0xFF0F172A),
    this.tickColor = const Color(0xFF64748B),
    this.majorTickColor = const Color(0xFF94A3B8),
    this.textColor = const Color(0xFFE2E8F0),
  });

  final RulerAxis axis;
  final RoadCanvasViewport viewport;
  final Color backgroundColor;
  final Color tickColor;
  final Color majorTickColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoadRulerPainter(
        axis: axis,
        viewport: viewport,
        backgroundColor: backgroundColor,
        tickColor: tickColor,
        majorTickColor: majorTickColor,
        textColor: textColor,
      ),
    );
  }
}

class _RoadRulerPainter extends CustomPainter {
  const _RoadRulerPainter({
    required this.axis,
    required this.viewport,
    required this.backgroundColor,
    required this.tickColor,
    required this.majorTickColor,
    required this.textColor,
  });

  final RulerAxis axis;
  final RoadCanvasViewport viewport;
  final Color backgroundColor;
  final Color tickColor;
  final Color majorTickColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = majorTickColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.55)
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    final major = viewport.majorStep;
    final minor = viewport.minorStep;
    if (major <= 0 || minor <= 0) return;

    if (axis == RulerAxis.horizontal) {
      _paintHorizontal(
        canvas,
        size,
        major,
        minor,
        tickPaint,
        majorPaint,
        axisPaint,
        textStyle,
      );
    } else {
      _paintVertical(
        canvas,
        size,
        major,
        minor,
        tickPaint,
        majorPaint,
        axisPaint,
        textStyle,
      );
    }
  }

  void _paintHorizontal(
    Canvas canvas,
    Size size,
    double major,
    double minor,
    Paint tickPaint,
    Paint majorPaint,
    Paint axisPaint,
    TextStyle textStyle,
  ) {
    final startWorld = viewport.worldFromScreenX(0) - major;
    final endWorld = viewport.worldFromScreenX(size.width) + major;
    var value = (startWorld / minor).floorToDouble() * minor;
    while (value <= endWorld) {
      final x = viewport.screenFromWorldX(value);
      final isMajor = _isMajor(value, major);
      canvas.drawLine(
        Offset(x, isMajor ? 0 : size.height * 0.45),
        Offset(x, size.height),
        isMajor ? majorPaint : tickPaint,
      );
      if (isMajor) {
        final label = value.round().toString();
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 1));
      }
      value += minor;
    }

    final zeroX = viewport.screenFromWorldX(0);
    canvas.drawLine(Offset(zeroX, 0), Offset(zeroX, size.height), axisPaint);
  }

  void _paintVertical(
    Canvas canvas,
    Size size,
    double major,
    double minor,
    Paint tickPaint,
    Paint majorPaint,
    Paint axisPaint,
    TextStyle textStyle,
  ) {
    final startWorld = viewport.worldFromScreenY(0) - major;
    final endWorld = viewport.worldFromScreenY(size.height) + major;
    var value = (startWorld / minor).floorToDouble() * minor;
    while (value <= endWorld) {
      final y = viewport.screenFromWorldY(value);
      final isMajor = _isMajor(value, major);
      canvas.drawLine(
        Offset(0, y),
        Offset(isMajor ? size.width : size.width * 0.6, y),
        isMajor ? majorPaint : tickPaint,
      );
      if (isMajor) {
        final label = value.round().toString();
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(2, y - tp.height / 2));
      }
      value += minor;
    }

    final zeroY = viewport.screenFromWorldY(0);
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), axisPaint);
  }

  bool _isMajor(double value, double major) {
    final ratio = value / major;
    return (ratio - ratio.round()).abs() < 0.0001;
  }

  @override
  bool shouldRepaint(covariant _RoadRulerPainter oldDelegate) {
    return oldDelegate.axis != axis ||
        oldDelegate.viewport.zoom != viewport.zoom ||
        oldDelegate.viewport.pan != viewport.pan ||
        oldDelegate.viewport.canvasSize != viewport.canvasSize ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.majorTickColor != majorTickColor ||
        oldDelegate.textColor != textColor;
  }
}
