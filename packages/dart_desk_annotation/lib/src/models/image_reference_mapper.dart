import 'package:dart_mappable/dart_mappable.dart';

import 'image_ref.dart';

/// A [dart_mappable] custom mapper for [ImageReference].
///
/// Decodes both stored and resolved imageReference JSON → [ImageReference].
/// Encodes [ImageReference] → stored format (assetId + framing, no publicUrl).
///
/// Usage:
/// ```dart
/// @MappableClass(includeCustomMappers: [ImageReferenceMapper()])
/// class MyConfig with MyConfigMappable { ... }
/// ```
class ImageReferenceMapper extends SimpleMapper<ImageReference> {
  const ImageReferenceMapper();

  @override
  ImageReference decode(Object value) =>
      ImageReference.fromMap(value as Map<String, dynamic>);

  @override
  Object encode(ImageReference self) => self.toMap();
}
