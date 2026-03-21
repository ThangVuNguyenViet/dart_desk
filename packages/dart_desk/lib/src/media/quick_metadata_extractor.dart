import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash_dart/blurhash_dart.dart';
import '../data/models/image_types.dart';

class QuickMetadataExtractor {
  /// Extract quick metadata from image bytes.
  /// Runs in a separate isolate to avoid UI jank.
  static Future<QuickImageMetadata> extract(Uint8List bytes) async {
    return compute(_extractInIsolate, bytes);
  }

  static QuickImageMetadata _extractInIsolate(Uint8List bytes) {
    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final width = image.width;
    final height = image.height;
    final hasAlpha = image.hasAlpha;

    // BlurHash — encode using blurhash_dart (uses package:image Image type)
    final blurHash = BlurHash.encode(image, numCompX: 4, numCompY: 3).hash;

    // Content hash (full SHA-256)
    final digest = sha256.convert(bytes);
    final contentHash = digest.toString();

    return QuickImageMetadata(
      width: width,
      height: height,
      hasAlpha: hasAlpha,
      blurHash: blurHash,
      contentHash: contentHash,
    );
  }
}
