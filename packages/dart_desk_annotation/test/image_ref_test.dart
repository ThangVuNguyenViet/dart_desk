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

    test('equality includes scale + offset', () {
      const a = ImageReference(publicUrl: 'x', scale: 1.2);
      const b = ImageReference(publicUrl: 'x', scale: 1.3);
      expect(a == b, isFalse);
    });
  });
}
