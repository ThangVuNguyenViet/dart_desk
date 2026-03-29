import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaAsset.fromInlineJson', () {
    test('decodes required fields', () {
      final json = {
        'assetId': 'image-abc-100x200-jpg',
        'publicUrl': 'https://cdn.example.com/image.jpg',
        'width': 100,
        'height': 200,
        'blurHash': 'LGF5?xYk^6#M',
      };

      final asset = MediaAsset.fromInlineJson(json);

      expect(asset.assetId, equals('image-abc-100x200-jpg'));
      expect(asset.publicUrl, equals('https://cdn.example.com/image.jpg'));
      expect(asset.width, equals(100));
      expect(asset.height, equals(200));
      expect(asset.blurHash, equals('LGF5?xYk^6#M'));
      expect(asset.lqip, isNull);
    });

    test('decodes optional lqip when present', () {
      final json = {
        'assetId': 'image-abc-100x200-jpg',
        'publicUrl': 'https://cdn.example.com/image.jpg',
        'width': 100,
        'height': 200,
        'blurHash': 'LGF5?xYk^6#M',
        'lqip': 'data:image/jpeg;base64,abc123',
      };

      final asset = MediaAsset.fromInlineJson(json);

      expect(asset.lqip, equals('data:image/jpeg;base64,abc123'));
    });
  });
}
