import 'package:flutter/material.dart';

@immutable
class RoadCanvasViewport {
  const RoadCanvasViewport({
    required this.zoom,
    required this.pan,
    required this.canvasSize,
    this.contentOriginX = 0,
    this.contentOriginY = 0,
  });

  final double zoom;
  final Offset pan;
  final Size canvasSize;
  final double contentOriginX;
  final double contentOriginY;

  double get panX => pan.dx;
  double get panY => pan.dy;

  /// Pick a ruler step that stays readable at different zoom levels.
  double get majorStep {
    const candidates = <double>[10, 20, 50, 100, 200, 500, 1000];
    for (final step in candidates) {
      if (step * zoom >= 64) return step;
    }
    return candidates.last;
  }

  double get minorStep => majorStep / 5;

  double worldFromScreenX(double screenX) =>
      (screenX - panX) / zoom - contentOriginX;
  double worldFromScreenY(double screenY) =>
      (screenY - panY) / zoom - contentOriginY;

  double screenFromWorldX(double worldX) =>
      (worldX + contentOriginX) * zoom + panX;
  double screenFromWorldY(double worldY) =>
      (worldY + contentOriginY) * zoom + panY;
}
