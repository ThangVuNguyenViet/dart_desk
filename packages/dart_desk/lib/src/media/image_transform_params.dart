import '../data/models/image_types.dart';

class ImageTransformParams {
  final int? width;
  final int? height;
  final FitMode? fit;
  final String? format;
  final int? quality;
  final double? fpX;
  final double? fpY;
  final CropRect? crop;

  const ImageTransformParams({
    this.width,
    this.height,
    this.fit,
    this.format,
    this.quality,
    this.fpX,
    this.fpY,
    this.crop,
  });
}
