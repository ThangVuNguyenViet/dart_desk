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
