import 'package:dart_mappable/dart_mappable.dart';

import 'image_url.dart';

/// A [dart_mappable] custom mapper for [ImageUrl].
///
/// Decodes a stored or resolved imageReference JSON map → [ImageUrl].
/// Encodes [ImageUrl] → stored format (assetId + framing, no publicUrl).
class ImageUrlMapper extends SimpleMapper<ImageUrl> {
  const ImageUrlMapper();

  @override
  ImageUrl decode(Object value) =>
      ImageUrl.fromMap(value as Map<String, dynamic>);

  @override
  Object encode(ImageUrl self) => self.toMap();
}
