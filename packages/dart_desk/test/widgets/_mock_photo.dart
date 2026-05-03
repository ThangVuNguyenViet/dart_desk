import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A stylized "photo" used in DeskFrame goldens so the framing story is
/// readable: sky/ground, a sun in the upper-right (primary subject), a
/// person on the lower-left (secondary subject), and a watermark band
/// across the bottom that an editor would want to crop out.
///
/// Subject coordinates (normalized 0..1):
///   sun:    (0.82, 0.22)
///   person: (0.22, 0.62)
///   watermark band: y >= 0.88
class MockPhoto extends StatelessWidget {
  const MockPhoto({super.key});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MockPhotoPainter(), size: Size.infinite);
}

class _MockPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.65),
      Paint()..color = const Color(0xFF87C8F0),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.35),
      Paint()..color = const Color(0xFF6FAE5A),
    );

    final sunCenter = Offset(w * 0.82, h * 0.22);
    final sunR = h * 0.10;
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()..color = const Color(0xFFFFC83D),
    );
    final ray = Paint()
      ..color = const Color(0xFFFFC83D)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        sunCenter + Offset(sunR * 1.3 * math.cos(a), sunR * 1.3 * math.sin(a)),
        sunCenter + Offset(sunR * 1.9 * math.cos(a), sunR * 1.9 * math.sin(a)),
        ray,
      );
    }

    final headC = Offset(w * 0.22, h * 0.62);
    final headR = h * 0.06;
    canvas.drawCircle(
      headC,
      headR,
      Paint()..color = const Color(0xFFE8B98A),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: headC.translate(0, headR + h * 0.08),
        width: w * 0.08,
        height: h * 0.16,
      ),
      Paint()..color = const Color(0xFFB6483C),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
      Paint()..color = const Color(0xCC202020),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '© SAMPLE WATERMARK',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, h * 0.92));

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0x66000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
