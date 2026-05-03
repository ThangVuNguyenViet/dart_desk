import 'dart:ui';

import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageReference scale/offset', () {
    test('absent fields deserialize to null (identity)', () {
      final ref = ImageReference.fromMap({
        '_type': 'imageReference',
        'publicUrl': 'fake://x',
      });
      expect(ref.scale, isNull);
      expect(ref.offset, isNull);
    });

    test('scale + offset round-trip through toMap/fromMap', () {
      const original = ImageReference(
        publicUrl: 'fake://x',
        scale: 0.85,
        offset: Offset(0.1, -0.2),
      );
      final restored = ImageReference.fromMap(original.toMap());
      expect(restored.scale, 0.85);
      expect(restored.offset, const Offset(0.1, -0.2));
    });

    test('identity transform omits keys from toMap', () {
      const ref = ImageReference(publicUrl: 'fake://x');
      final map = ref.toMap();
      expect(map.containsKey('scale'), isFalse);
      expect(map.containsKey('offset'), isFalse);
    });

    test('copyWith preserves transform when not overridden', () {
      const a = ImageReference(
        publicUrl: 'fake://x',
        scale: 1.5,
        offset: Offset(0.2, 0),
      );
      final b = a.copyWith(altText: 'new alt');
      expect(b.scale, 1.5);
      expect(b.offset, const Offset(0.2, 0));
    });

    test('copyWith(scale: null) clears scale', () {
      const a = ImageReference(
        publicUrl: 'fake://x',
        scale: 1.5,
        offset: Offset(0.2, 0),
      );
      final b = a.copyWith(scale: null);
      expect(b.scale, isNull);
      expect(b.offset, const Offset(0.2, 0));
    });

    test('copyWith(offset: null) clears offset', () {
      const a = ImageReference(
        publicUrl: 'fake://x',
        scale: 1.5,
        offset: Offset(0.2, 0),
      );
      final b = a.copyWith(offset: null);
      expect(b.offset, isNull);
      expect(b.scale, 1.5);
    });

    test('copyWith(hotspot: null) clears hotspot', () {
      const a = ImageReference(
        publicUrl: 'fake://x',
        hotspot: Hotspot(x: 0.3, y: 0.3, width: 0.2, height: 0.2),
      );
      final b = a.copyWith(hotspot: null);
      expect(b.hotspot, isNull);
    });

    test('equality includes scale + offset', () {
      const a = ImageReference(publicUrl: 'x', scale: 1.2);
      const b = ImageReference(publicUrl: 'x', scale: 1.3);
      expect(a == b, isFalse);
    });
  });
}
