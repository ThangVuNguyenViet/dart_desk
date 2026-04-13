import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:dart_desk/src/media/quick_metadata_extractor.dart';

void main() {
  // Generate a valid 1x1 PNG using the image package itself,
  // ensuring the IDAT checksum and all chunks are correct.
  late Uint8List testPngBytes;

  setUpAll(() {
    final image = img.Image(width: 1, height: 1);
    image.setPixelRgb(0, 0, 255, 0, 0); // red pixel
    testPngBytes = Uint8List.fromList(img.encodePng(image));
  });

  group('QuickMetadataExtractor (large image)', () {
    late Uint8List largePngBytes;

    setUpAll(() {
      // Simulate a 4000x3000 photo (12 MP) — typical phone camera output.
      final large = img.Image(width: 4000, height: 3000);
      // Fill with a gradient so BlurHash has real data to process.
      for (var y = 0; y < large.height; y++) {
        for (var x = 0; x < large.width; x++) {
          large.setPixelRgb(
            x,
            y,
            (x * 255 ~/ large.width),
            (y * 255 ~/ large.height),
            128,
          );
        }
      }
      largePngBytes = Uint8List.fromList(img.encodePng(large));
    });

    test('extracts correct dimensions from large image', () async {
      final metadata = await QuickMetadataExtractor.extract(largePngBytes);
      expect(metadata.width, 4000);
      expect(metadata.height, 3000);
    });

    test('completes within 10 seconds for a 12MP image', () async {
      final sw = Stopwatch()..start();
      final metadata = await QuickMetadataExtractor.extract(largePngBytes);
      sw.stop();
      // With the thumbnail optimization, BlurHash on a 64px thumbnail should
      // be fast. The bulk of time is the image decode (pure Dart).
      expect(sw.elapsedMilliseconds, lessThan(10000));
      expect(metadata.blurHash, isNotEmpty);
      expect(metadata.contentHash.length, 64);
    });

    test('produces valid blurHash from large image', () async {
      final metadata = await QuickMetadataExtractor.extract(largePngBytes);
      // BlurHash should be non-trivial (not all same chars)
      expect(metadata.blurHash.length, greaterThan(6));
      expect(metadata.blurHash.split('').toSet().length, greaterThan(1));
    });
  });

  group('QuickMetadataExtractor', () {
    test('extracts width and height from PNG', () async {
      final metadata = await QuickMetadataExtractor.extract(testPngBytes);
      expect(metadata.width, equals(1));
      expect(metadata.height, equals(1));
    });

    test('extracts hasAlpha', () async {
      final metadata = await QuickMetadataExtractor.extract(testPngBytes);
      // 1x1 PNG encoded by img.encodePng from a default Image
      expect(metadata.hasAlpha, isFalse);
    });

    test('extracts a non-empty blurHash', () async {
      final metadata = await QuickMetadataExtractor.extract(testPngBytes);
      expect(metadata.blurHash, isNotEmpty);
    });

    test('extracts a 64-character SHA-256 contentHash', () async {
      final metadata = await QuickMetadataExtractor.extract(testPngBytes);
      expect(metadata.contentHash, isNotEmpty);
      expect(metadata.contentHash.length, equals(64));
    });

    test('throws for corrupt bytes', () async {
      await expectLater(
        () => QuickMetadataExtractor.extract(Uint8List.fromList([0, 1, 2, 3])),
        throwsA(anything),
      );
    });
  });
}
