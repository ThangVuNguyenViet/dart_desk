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

  group('FramingMath scale + offset', () {
    test('identity transform produces same result as absent transform', () {
      final base = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
      );
      final identity = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
        scale: 1.0,
        offset: Offset.zero,
      );
      expect(identity.childRect, base.childRect);
    });

    test('scale 0.5 halves the rendered child size', () {
      final base = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
      );
      final scaled = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
        scale: 0.5,
      );
      expect(scaled.childRect.width, closeTo(base.childRect.width * 0.5, 0.01));
      expect(scaled.childRect.height, closeTo(base.childRect.height * 0.5, 0.01));
    });

    test('offset(0.1, 0) shifts child rect right by 10% of box width', () {
      final base = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
      );
      final shifted = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
        offset: const Offset(0.1, 0),
      );
      expect(shifted.childRect.left - base.childRect.left, closeTo(20.0, 0.01));
    });

    test('non-identity transform skips cover-clamp (allows exposed edges)', () {
      final clamped = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: const Hotspot(x: 0.99, y: 0.5, width: 0.1, height: 0.1),
        fit: BoxFit.cover,
      );
      final unclamped = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: const Hotspot(x: 0.99, y: 0.5, width: 0.1, height: 0.1),
        fit: BoxFit.cover,
        scale: 0.9,
      );
      expect(unclamped.childRect.left, lessThan(clamped.childRect.left));
    });

    test('scale clamps to [0.1, 10]', () {
      final tooSmall = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
        scale: 0.0001,
      );
      final atMin = FramingMath.frameGeometry(
        boxSize: const Size(200, 200),
        sourceSize: const Size(800, 400),
        crop: FramingDefaults.defaultCrop,
        hotspot: FramingDefaults.defaultHotspot,
        fit: BoxFit.cover,
        scale: 0.1,
      );
      expect(tooSmall.childRect.width, closeTo(atMin.childRect.width, 0.01));
    });
  });
}
