import 'package:dart_desk_annotation/dart_desk_annotation.dart';

import '../data/models/image_types.dart' show FitMode;
import 'image_transform_params.dart';

typedef TransformUrlBuilder =
    String Function(String publicUrl, ImageTransformParams params);

/// CDN transform wrapper around [ImageReference].
///
/// Adds `url()` method with width/height/format/quality params that delegates
/// to a pluggable [TransformUrlBuilder]. Without a transform, returns the
/// raw URL from the underlying [ImageReference].
///
/// Both [ImageUrl] and [ImageReference] serialize to the same wire format.
/// You can switch between them without data migration.
class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({required this.imageRef, TransformUrlBuilder? transformUrl})
    : _transformUrl = transformUrl;

  /// Decodes a stored or resolved imageReference JSON node into an [ImageUrl].
  factory ImageUrl.fromMap(Map<String, dynamic> map) =>
      ImageUrl(imageRef: ImageReference.fromMap(map));

  /// Returns a new [ImageUrl] with the given [builder] applied to [url].
  ImageUrl withTransform(TransformUrlBuilder builder) =>
      ImageUrl(imageRef: imageRef, transformUrl: builder);

  /// Returns a (optionally transformed) URL for this image.
  ///
  /// If a [TransformUrlBuilder] is set, builds transform params from the
  /// arguments and the image's hotspot/crop data, then delegates to the builder.
  /// Otherwise returns the raw URL from [imageRef].
  String? url({
    int? width,
    int? height,
    FitMode? fit,
    String? format,
    int? quality,
  }) {
    final baseUrl = imageRef.url;
    if (baseUrl == null) return null;
    if (_transformUrl == null) return baseUrl;
    final params = ImageTransformParams(
      width: width,
      height: height,
      fit: fit,
      format: format,
      quality: quality,
      fpX: imageRef.hotspot?.x,
      fpY: imageRef.hotspot?.y,
      crop: imageRef.crop,
    );
    return _transformUrl(baseUrl, params);
  }

  /// Outputs stored format — identical to [imageRef.toMap()].
  Map<String, dynamic> toMap() => imageRef.toMap();

  String? get blurHash => imageRef.blurHash;
  String? get lqip => imageRef.lqip;
  int? get width => imageRef.width;
  int? get height => imageRef.height;
}
