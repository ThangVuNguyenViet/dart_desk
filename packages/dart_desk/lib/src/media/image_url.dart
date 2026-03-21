import '../data/models/image_reference.dart';
import '../data/models/image_types.dart';
import 'image_transform_params.dart';

typedef TransformUrlBuilder = String? Function(
    String publicUrl, ImageTransformParams params);

class ImageUrl {
  final ImageReference imageRef;
  final TransformUrlBuilder? _transformUrl;

  const ImageUrl({required this.imageRef, TransformUrlBuilder? transformUrl})
      : _transformUrl = transformUrl;

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
