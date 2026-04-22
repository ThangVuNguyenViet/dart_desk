import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/image_types.dart';

/// Colors the hotspot painter draws with. Provided by the caller so the
/// painter stays theme-aware without reaching into `BuildContext`.
@immutable
class HotspotColors {
  const HotspotColors({required this.fill, required this.shadow});

  final Color fill;
  final Color shadow;
}

class HotspotPainter extends CustomPainter {
  HotspotPainter({required this.hotspot, required this.colors});

  final Hotspot hotspot;
  final HotspotColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(hotspot.x * size.width, hotspot.y * size.height);
    final rx = hotspot.width * size.width / 2;
    final ry = hotspot.height * size.height / 2;

    final ellipseRect = Rect.fromCenter(
      center: center,
      width: rx * 2,
      height: ry * 2,
    );

    final gradient = ui.Gradient.radial(center, (rx + ry) / 2, [
      colors.fill.withValues(alpha: 0.15),
      colors.fill.withValues(alpha: 0.04),
    ]);
    canvas.drawOval(ellipseRect, Paint()..shader = gradient);

    canvas.drawOval(
      ellipseRect.inflate(1),
      Paint()
        ..color = colors.shadow.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );
    canvas.drawOval(
      ellipseRect,
      Paint()
        ..color = colors.fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    const crossSize = 5.0;
    final crossPaint = Paint()
      ..color = colors.fill
      ..strokeWidth = 1.0
      ..strokeCap = ui.StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy),
      Offset(center.dx + crossSize, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crossSize),
      Offset(center.dx, center.dy + crossSize),
      crossPaint,
    );
    canvas.drawCircle(center, 2.5, Paint()..color = colors.fill);
    canvas.drawCircle(
      center,
      2.5,
      Paint()
        ..color = colors.shadow.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    const hs = 4.0;
    final cardinalPoints = [
      Offset(center.dx, center.dy - ry),
      Offset(center.dx, center.dy + ry),
      Offset(center.dx - rx, center.dy),
      Offset(center.dx + rx, center.dy),
    ];
    for (final offset in cardinalPoints) {
      canvas.drawCircle(
        offset,
        hs + 0.5,
        Paint()
          ..color = colors.shadow.withValues(alpha: 0.3)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5),
      );
      canvas.drawCircle(offset, hs, Paint()..color = colors.fill);
    }
  }

  @override
  bool shouldRepaint(HotspotPainter old) =>
      hotspot != old.hotspot || colors != old.colors;
}
