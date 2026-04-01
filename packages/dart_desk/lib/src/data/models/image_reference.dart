import '../../../dart_desk.dart';

class ImageReference implements Serializable {
  final MediaAsset asset;
  final Hotspot? hotspot;
  final CropRect? crop;
  final String? altText;

  const ImageReference({
    required this.asset,
    this.hotspot,
    this.crop,
    this.altText,
  });

  Map<String, dynamic> toDocumentJson() => {
    '_type': 'imageReference',
    'assetId': asset.assetId,
    if (hotspot != null) 'hotspot': hotspot!.toJson(),
    if (crop != null) 'crop': crop!.toJson(),
    if (altText != null) 'altText': altText,
  };

  factory ImageReference.fromDocumentJson(
    Map<String, dynamic> json,
    MediaAsset asset,
  ) {
    return ImageReference(
      asset: asset,
      hotspot: json['hotspot'] != null
          ? Hotspot.fromJson(json['hotspot'] as Map<String, dynamic>)
          : null,
      crop: json['crop'] != null
          ? CropRect.fromJson(json['crop'] as Map<String, dynamic>)
          : null,
      altText: json['altText'] as String?,
    );
  }

  static bool isImageReference(Map<String, dynamic> json) {
    return json['_type'] == 'imageReference';
  }

  ImageReference copyWith({
    MediaAsset? asset,
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) {
    return ImageReference(
      asset: asset ?? this.asset,
      hotspot: hotspot ?? this.hotspot,
      crop: crop ?? this.crop,
      altText: altText ?? this.altText,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return toDocumentJson();
  }
}
