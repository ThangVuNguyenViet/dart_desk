import 'package:dart_mappable/dart_mappable.dart';

import 'image_url.dart';

/// A [dart_mappable] custom mapper for [ImageUrl].
///
/// Decodes a resolved imageReference JSON map → [ImageUrl].
/// Encodes [ImageUrl] → assetId-only map (the stored document format).
///
/// Add to your @MappableClass annotation:
/// ```dart
/// @MappableClass(includeCustomMappers: [ImageUrlMapper()])
/// class MyConfig ...
/// ```
class ImageUrlMapper extends SimpleMapper<ImageUrl> {
  const ImageUrlMapper();

  @override
  ImageUrl decode(Object value) =>
      ImageUrl.fromJson(value as Map<String, dynamic>);

  @override
  Object encode(ImageUrl self) => self.imageRef.toDocumentJson();
}
