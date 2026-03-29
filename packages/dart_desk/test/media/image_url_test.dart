import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/media/image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final resolvedJson = {
    '_type': 'imageReference',
    'assetId': 'image-abc-1920x1080-jpg',
    'publicUrl': 'https://cdn.example.com/image.jpg',
    'width': 1920,
    'height': 1080,
    'blurHash': 'LGF5?xYk^6#M',
    'hotspot': {'x': 0.5, 'y': 0.3, 'width': 0.8, 'height': 0.6},
    'crop': null,
    'altText': 'A hero image',
  };

  group('ImageUrl.fromJson', () {
    test('decodes publicUrl correctly', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.url(), equals('https://cdn.example.com/image.jpg'));
    });

    test('decodes blurHash', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.blurHash, equals('LGF5?xYk^6#M'));
    });

    test('decodes hotspot', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.imageRef.hotspot?.x, equals(0.5));
      expect(imageUrl.imageRef.hotspot?.y, equals(0.3));
    });

    test('decodes altText', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(imageUrl.imageRef.altText, equals('A hero image'));
    });

    test('url() returns raw publicUrl when no transform builder', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      expect(
        imageUrl.url(width: 800, fit: FitMode.crop),
        equals('https://cdn.example.com/image.jpg'),
      );
    });
  });

  group('ImageUrl.withTransform', () {
    test('applies transform builder to url()', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      final withTransform = imageUrl.withTransform(
        (publicUrl, params) => '$publicUrl?w=${params.width}',
      );
      expect(withTransform.url(width: 800), equals('https://cdn.example.com/image.jpg?w=800'));
    });

    test('original imageUrl is unchanged after withTransform', () {
      final imageUrl = ImageUrl.fromJson(resolvedJson);
      imageUrl.withTransform((url, _) => '$url?modified');
      expect(imageUrl.url(), equals('https://cdn.example.com/image.jpg'));
    });
  });
}
