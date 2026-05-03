import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk_widgets/dart_desk_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FramingMath.frameGeometry', () {
    const noCrop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
    const centerHotspot = Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);

    test('contain, square box, square source: child fills box exactly', () {
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 200),
        crop: noCrop,
        hotspot: centerHotspot,
        fit: BoxFit.contain,
      );
      expect(geom.childRect, const Rect.fromLTWH(0, 0, 100, 100));
    });

    test('cover, wide source: child wider than box, centered', () {
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 100),
        crop: noCrop,
        hotspot: centerHotspot,
        fit: BoxFit.cover,
      );
      expect(geom.childRect.size, const Size(200, 100));
      expect(geom.childRect.left, -50);
      expect(geom.childRect.top, 0);
    });

    test('cover, off-center hotspot: child shifted, hotspot kept in view', () {
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 100),
        crop: noCrop,
        hotspot: const Hotspot(x: 0.9, y: 0.5, width: 0.1, height: 0.1),
        fit: BoxFit.cover,
      );
      expect(geom.childRect.left, -100);
    });

    test('crop trims source: child rect reflects only the cropped region', () {
      final geom = FramingMath.frameGeometry(
        boxSize: const Size(100, 100),
        sourceSize: const Size(200, 200),
        crop: const CropRect(top: 0.25, bottom: 0.25, left: 0, right: 0),
        hotspot: centerHotspot,
        fit: BoxFit.cover,
      );
      expect(geom.childRect, const Rect.fromLTWH(-50, -50, 200, 200));
    });
  });
}
