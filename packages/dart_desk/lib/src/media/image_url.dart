import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import '../data/models/media_asset.dart';
import 'image_transform_params.dart';

typedef TransformUrlBuilder = String Function(
    String publicUrl, ImageTransformParams params);

class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({required this.imageRef, TransformUrlBuilder? transformUrl})
      : _transformUrl = transformUrl;

  /// Decodes a resolved imageReference JSON node into an [ImageUrl].
  ///
  /// The JSON must contain: assetId, publicUrl, width, height, blurHash.
  /// Optional: lqip, hotspot, crop, altText.
  /// [transformUrl] is null until the consumer calls [withTransform].
  factory ImageUrl.fromJson(Map<String, dynamic> json) {
    final asset = MediaAsset.fromInlineJson(json);
    final ref = ImageReference.fromDocumentJson(json, asset);
    return ImageUrl(imageRef: ref);
  }

  /// Returns a new [ImageUrl] with the given [builder] applied to [url].
  ///
  /// The original [ImageUrl] is not mutated.
  ImageUrl withTransform(TransformUrlBuilder builder) =>
      ImageUrl(imageRef: imageRef, transformUrl: builder);

  String url({
    int? width,
    int? height,
    FitMode? fit,
    String? format,
    int? quality,
  }) {
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
    return _transformUrl?.call(imageRef.asset.publicUrl, params) ??
        imageRef.asset.publicUrl;
  }

  String get blurHash => imageRef.asset.blurHash;
  String? get lqip => imageRef.asset.lqip;
}
