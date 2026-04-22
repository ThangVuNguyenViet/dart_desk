import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/image_types.dart';

/// Colors the crop overlay painter draws with. Supplied by the caller so the
/// painter stays theme-aware without reaching into `BuildContext`.
@immutable
class CropOverlayColors {
  const CropOverlayColors({required this.line, required this.scrim});

  /// The bracket/grid line color (typically `theme.foreground`).
  final Color line;

  /// The dimming scrim over areas outside the crop (typically
  /// `theme.background`). Alpha is applied inside the painter.
  final Color scrim;
}

class CropOverlayPainter extends CustomPainter {
  final CropRect crop;
  final Size imageSize;
  final CropOverlayColors colors;

  CropOverlayPainter({
    required this.crop,
    required this.imageSize,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Rect.fromLTRB(
      crop.left * size.width,
      crop.top * size.height,
      size.width - crop.right * size.width,
      size.height - crop.bottom * size.height,
    );

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.scrim.withValues(alpha: 0.6),
    );
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    canvas.drawRect(
      cropRect,
      Paint()
        ..color = colors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;
    final gridPaint = Paint()
      ..color = colors.line.withValues(alpha: 0.18)
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

    _drawCornerBrackets(canvas, cropRect);
    _drawEdgeMidpoints(canvas, cropRect);
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect) {
    const bracketLen = 16.0;
    final paint = Paint()
      ..color = colors.line
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
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = ui.StrokeCap.round;

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
      crop != oldDelegate.crop ||
      imageSize != oldDelegate.imageSize ||
      colors != oldDelegate.colors;
}
