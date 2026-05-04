import 'package:flutter/widgets.dart';

/// A child for [DeskFrame] tests that paints a recognizable pattern so the
/// framing rect is visible in goldens — solid background, diagonal stripes,
/// and a centered marker. Fills its allocated box.
class FramingPattern extends StatelessWidget {
  const FramingPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FramingPainter(), size: Size.infinite);
  }
}

class _FramingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF1F4FE0);
    canvas.drawRect(Offset.zero & size, bg);

    final stripe = Paint()
      ..color = const Color(0xFFFFD400)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final step = 40.0;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        stripe,
      );
    }

    // Center crosshair so hotspot shifts are obvious.
    final mark = Paint()
      ..color = const Color(0xFFFF2D55)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 18, mark);
    canvas.drawLine(c.translate(-28, 0), c.translate(28, 0), mark);
    canvas.drawLine(c.translate(0, -28), c.translate(0, 28), mark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
