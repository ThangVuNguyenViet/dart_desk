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
    // Content hash (SHA-256) — runs on raw bytes, no decode needed.
    final digest = sha256.convert(bytes);
    final contentHash = digest.toString();

    // Decode image — needed for dimensions, alpha, and BlurHash.
    // For large images the `image` package (pure Dart) is slow, but it runs
    // in an isolate so it won't block the UI thread.
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final width = image.width;
    final height = image.height;
    final hasAlpha = image.hasAlpha;

    // BlurHash — downscale to a small thumbnail first since BlurHash is
    // inherently low-resolution (4x3 components). Computing on a full 4000x3000
    // image is ~100x slower than on a 64px thumbnail with identical results.
    final thumb = (width > 64 || height > 64)
        ? img.copyResize(image, width: 64, maintainAspect: true)
        : image;
    final blurHash = BlurHash.encode(thumb, numCompX: 4, numCompY: 3).hash;

    return QuickImageMetadata(
      width: width,
      height: height,
      hasAlpha: hasAlpha,
      blurHash: blurHash,
      contentHash: contentHash,
    );
  }
}
