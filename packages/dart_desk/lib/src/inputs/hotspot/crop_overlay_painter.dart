import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/image_types.dart';

class CropOverlayPainter extends CustomPainter {
  final CropRect crop;
  final Size imageSize;

  CropOverlayPainter({required this.crop, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTRB(
      crop.left * size.width,
      crop.top * size.height,
      size.width - crop.right * size.width,
      size.height - crop.bottom * size.height,
    );

    // Dim overlay outside crop region
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0x99000000),
    );
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Crop border — crisp white line
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Rule-of-thirds grid — very subtle
    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.5;

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cropRect.left + thirdW * i, cropRect.top),
        Offset(cropRect.left + thirdW * i, cropRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left, cropRect.top + thirdH * i),
        Offset(cropRect.right, cropRect.top + thirdH * i),
        gridPaint,
      );
    }

    // Corner bracket handles (Sanity-style)
    _drawCornerBrackets(canvas, cropRect);

    // Edge midpoint handles — small bars
    _drawEdgeMidpoints(canvas, cropRect);
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect) {
    const bracketLen = 16.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = ui.StrokeCap.square;

    final corners = [
      (rect.topLeft, const Offset(1, 0), const Offset(0, 1)),
      (rect.topRight, const Offset(-1, 0), const Offset(0, 1)),
      (rect.bottomLeft, const Offset(1, 0), const Offset(0, -1)),
      (rect.bottomRight, const Offset(-1, 0), const Offset(0, -1)),
    ];

    for (final (corner, hDir, vDir) in corners) {
      canvas.drawLine(corner, corner + hDir * bracketLen, paint);
      canvas.drawLine(corner, corner + vDir * bracketLen, paint);
    }
  }

  void _drawEdgeMidpoints(Canvas canvas, Rect rect) {
    const barLen = 12.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = ui.StrokeCap.round;

    // Top/bottom midpoints — horizontal bars
    canvas.drawLine(
      Offset(rect.center.dx - barLen / 2, rect.top),
      Offset(rect.center.dx + barLen / 2, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.center.dx - barLen / 2, rect.bottom),
      Offset(rect.center.dx + barLen / 2, rect.bottom),
      paint,
    );
    // Left/right midpoints — vertical bars
    canvas.drawLine(
      Offset(rect.left, rect.center.dy - barLen / 2),
      Offset(rect.left, rect.center.dy + barLen / 2),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.center.dy - barLen / 2),
      Offset(rect.right, rect.center.dy + barLen / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) =>
      crop != oldDelegate.crop || imageSize != oldDelegate.imageSize;
}
