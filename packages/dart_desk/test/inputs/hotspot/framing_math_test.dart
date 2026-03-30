import 'package:dart_desk/src/data/models/image_types.dart';
import 'package:dart_desk/src/inputs/hotspot/framing_math.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FramingMath.clampHotspotToCrop', () {
    test('keeps centered hotspot inside zero crop', () {
      const crop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
      const hotspot = Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);

      final clamped = FramingMath.clampHotspotToCrop(hotspot, crop);

      expect(clamped.x, 0.5);
      expect(clamped.y, 0.5);
    });

    test('moves hotspot back inside cropped bounds', () {
      const crop = CropRect(top: 0.2, bottom: 0.1, left: 0.15, right: 0.25);
      const hotspot = Hotspot(x: 0.95, y: 0.05, width: 0.3, height: 0.3);

      final clamped = FramingMath.clampHotspotToCrop(hotspot, crop);

      expect(clamped.x, lessThanOrEqualTo(0.75));
      expect(clamped.y, greaterThanOrEqualTo(0.2));
    });
  });

  group('FramingMath.previewAlignment', () {
    test('returns centered alignment for default framing', () {
      const crop = CropRect(top: 0, bottom: 0, left: 0, right: 0);
      const hotspot = Hotspot(x: 0.5, y: 0.5, width: 0.3, height: 0.3);

      final alignment = FramingMath.previewAlignment(
        crop: crop,
        hotspot: hotspot,
      );

      expect(alignment, Alignment.center);
    });

    test('biases alignment using both crop and hotspot', () {
      const crop = CropRect(top: 0.1, bottom: 0.2, left: 0.05, right: 0.35);
      const hotspot = Hotspot(x: 0.7, y: 0.35, width: 0.25, height: 0.25);

      final alignment = FramingMath.previewAlignment(
        crop: crop,
        hotspot: hotspot,
      );

      expect(alignment.x, greaterThan(0));
      expect(alignment.y, lessThan(0));
    });
  });
}
