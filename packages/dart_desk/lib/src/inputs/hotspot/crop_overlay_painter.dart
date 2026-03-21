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

    // IMPORTANT: saveLayer is required for BlendMode.clear to work correctly
    canvas.saveLayer(Offset.zero & size, Paint());

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(Offset.zero & size, overlayPaint);

    // Clear the crop region
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    // Border
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rule-of-thirds grid lines inside crop
    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (var i = 1; i < 3; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(cropRect.left + thirdW * i, cropRect.top),
        Offset(cropRect.left + thirdW * i, cropRect.bottom),
        gridPaint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(cropRect.left, cropRect.top + thirdH * i),
        Offset(cropRect.right, cropRect.top + thirdH * i),
        gridPaint,
      );
    }

    // Drag handles (small squares at corners and midpoints)
    final handlePaint = Paint()..color = Colors.white;
    const handleSize = 8.0;
    final handles = [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
      cropRect.topCenter,
      cropRect.bottomCenter,
      cropRect.centerLeft,
      cropRect.centerRight,
    ];
    for (final point in handles) {
      canvas.drawRect(
        Rect.fromCenter(center: point, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) =>
      crop != oldDelegate.crop || imageSize != oldDelegate.imageSize;
}
