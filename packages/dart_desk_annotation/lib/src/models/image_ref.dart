import 'image_types.dart';

/// Unified image reference for dart_desk.
///
/// Handles both stored format (assetId only) and server-resolved format
/// (assetId + publicUrl + dimensions + blurHash). Auto-detects which format
/// when deserializing via [fromMap].
///
/// Serialised as `{ '_type': 'imageReference', 'assetId': '...' }` (stored)
/// or with additional resolved fields (publicUrl, width, height, blurHash, lqip).
///
/// For CDN transform support, wrap in [ImageUrl] from `package:dart_desk`.
class ImageReference {
  final String? assetId;
  final String? externalUrl;
  final String? publicUrl;
  final int? width;
  final int? height;
  final String? blurHash;
  final String? lqip;
  final Hotspot? hotspot;
  final CropRect? crop;
  final String? altText;

  const ImageReference({
    this.assetId,
    this.externalUrl,
    this.publicUrl,
    this.width,
    this.height,
    this.blurHash,
    this.lqip,
    this.hotspot,
    this.crop,
    this.altText,
  });

  factory ImageReference.fromMap(Map<String, dynamic> map) => ImageReference(
    assetId: map['assetId'] as String?,
    externalUrl: map['externalUrl'] as String?,
    publicUrl: map['publicUrl'] as String?,
    width: map['width'] as int?,
    height: map['height'] as int?,
    blurHash: map['blurHash'] as String?,
    lqip: map['lqip'] as String?,
    hotspot: map['hotspot'] != null
        ? Hotspot.fromJson(map['hotspot'] as Map<String, dynamic>)
        : null,
    crop: map['crop'] != null
        ? CropRect.fromJson(map['crop'] as Map<String, dynamic>)
        : null,
    altText: map['altText'] as String?,
  );

  Map<String, dynamic> toMap() => {
    '_type': 'imageReference',
    if (assetId != null) 'assetId': assetId,
    if (publicUrl != null) 'publicUrl': publicUrl,
    if (externalUrl != null) 'externalUrl': externalUrl,
    if (hotspot != null) 'hotspot': hotspot!.toJson(),
    if (crop != null) 'crop': crop!.toJson(),
    if (altText != null) 'altText': altText,
  };

  static bool isImageReference(Map<String, dynamic> map) =>
      map['_type'] == 'imageReference';

  static String Function(String assetId)? defaultAssetResolver;

  String? get url {
    if (publicUrl != null) return publicUrl;
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return defaultAssetResolver?.call(assetId!);
    return null;
  }

  String? resolveUrl(String Function(String assetId) assetResolver) {
    if (publicUrl != null) return publicUrl;
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return assetResolver(assetId!);
    return null;
  }

  ImageReference copyWith({
    String? assetId,
    String? externalUrl,
    String? publicUrl,
    int? width,
    int? height,
    String? blurHash,
    String? lqip,
    Hotspot? hotspot,
    CropRect? crop,
    String? altText,
  }) => ImageReference(
    assetId: assetId ?? this.assetId,
    externalUrl: externalUrl ?? this.externalUrl,
    publicUrl: publicUrl ?? this.publicUrl,
    width: width ?? this.width,
    height: height ?? this.height,
    blurHash: blurHash ?? this.blurHash,
    lqip: lqip ?? this.lqip,
    hotspot: hotspot ?? this.hotspot,
    crop: crop ?? this.crop,
    altText: altText ?? this.altText,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageReference &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          externalUrl == other.externalUrl &&
          publicUrl == other.publicUrl &&
          hotspot == other.hotspot &&
          crop == other.crop &&
          altText == other.altText;

  @override
  int get hashCode =>
      Object.hash(assetId, externalUrl, publicUrl, hotspot, crop, altText);

  @override
  String toString() =>
      'ImageReference(assetId: $assetId, externalUrl: $externalUrl, publicUrl: $publicUrl)';
}
