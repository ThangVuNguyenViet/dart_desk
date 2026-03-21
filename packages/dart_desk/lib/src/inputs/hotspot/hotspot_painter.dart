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

    final ellipseRect =
        Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);

    // Ellipse fill
    canvas.drawOval(
      ellipseRect,
      Paint()..color = Colors.blue.withValues(alpha: 0.2),
    );

    // Ellipse border
    canvas.drawOval(
      ellipseRect,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Center crosshair
    const crossSize = 6.0;
    final crossPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5;
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
    canvas.drawCircle(center, 3, Paint()..color = Colors.blue);

    // Resize handles at cardinal points
    final handlePaint = Paint()..color = Colors.blue;
    const hs = 5.0;
    final cardinalPoints = [
      Offset(center.dx, center.dy - ry), // top
      Offset(center.dx, center.dy + ry), // bottom
      Offset(center.dx - rx, center.dy), // left
      Offset(center.dx + rx, center.dy), // right
    ];
    for (final offset in cardinalPoints) {
      canvas.drawCircle(offset, hs, handlePaint);
      canvas.drawCircle(
        offset,
        hs,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(HotspotPainter old) => hotspot != old.hotspot;
}
