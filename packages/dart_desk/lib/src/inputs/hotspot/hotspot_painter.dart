import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/image_types.dart';

class HotspotPainter extends CustomPainter {
  final Hotspot hotspot;

  HotspotPainter({required this.hotspot});

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

    // Subtle fill with a radial gradient — bright center fading out
    final gradient = ui.Gradient.radial(center, (rx + ry) / 2, [
      Colors.white.withValues(alpha: 0.15),
      Colors.white.withValues(alpha: 0.04),
    ]);
    canvas.drawOval(ellipseRect, Paint()..shader = gradient);

    // Ellipse border — white with slight shadow for contrast on any bg
    canvas.drawOval(
      ellipseRect.inflate(1),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );
    canvas.drawOval(
      ellipseRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Center crosshair — small and refined
    const crossSize = 5.0;
    final crossPaint = Paint()
      ..color = Colors.white
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
    // Center dot
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      2.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Cardinal resize handles — small circles with shadow
    const hs = 4.0;
    final cardinalPoints = [
      Offset(center.dx, center.dy - ry),
      Offset(center.dx, center.dy + ry),
      Offset(center.dx - rx, center.dy),
      Offset(center.dx + rx, center.dy),
    ];
    for (final offset in cardinalPoints) {
      // Shadow
      canvas.drawCircle(
        offset,
        hs + 0.5,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5),
      );
      // Fill
      canvas.drawCircle(offset, hs, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(HotspotPainter old) => hotspot != old.hotspot;
}
