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

  /// Multiplier on the BoxFit-derived auto-scale. null or 1.0 = identity.
  /// Range clamps to [0.1, 10] on render.
  final double? scale;

  /// Translation in box-relative fractions. null or `ImageOffset.zero` = identity.
  /// Range clamps to [-2.0, 2.0] per axis on render.
  final ImageOffset? offset;

  // TODO(transform-d): rotation (degrees, pivot = hotspot)
  // TODO(transform-d): skewX, skewY (radians)
  // TODO(transform-d): flipX, flipY (booleans)

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
    this.scale,
    this.offset,
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
    scale: (map['scale'] as num?)?.toDouble(),
    offset: map['offset'] != null
        ? ImageOffset.fromJson(map['offset'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toMap() => {
    '_type': 'imageReference',
    if (assetId != null) 'assetId': assetId,
    if (publicUrl != null) 'publicUrl': publicUrl,
    if (externalUrl != null) 'externalUrl': externalUrl,
    if (hotspot != null) 'hotspot': hotspot!.toJson(),
    if (crop != null) 'crop': crop!.toJson(),
    if (altText != null) 'altText': altText,
    if (scale != null) 'scale': scale,
    if (offset != null) 'offset': {'dx': offset!.dx, 'dy': offset!.dy},
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

  static const Object _unset = Object();

  /// Every parameter accepts an explicit `null` to clear the field — passing
  /// `null` clears, omitting preserves. The `_unset` sentinel distinguishes
  /// "caller omitted" from "caller wants null."
  ImageReference copyWith({
    Object? assetId = _unset,
    Object? externalUrl = _unset,
    Object? publicUrl = _unset,
    Object? width = _unset,
    Object? height = _unset,
    Object? blurHash = _unset,
    Object? lqip = _unset,
    Object? hotspot = _unset,
    Object? crop = _unset,
    Object? altText = _unset,
    Object? scale = _unset,
    Object? offset = _unset,
  }) => ImageReference(
    assetId: identical(assetId, _unset) ? this.assetId : assetId as String?,
    externalUrl:
        identical(externalUrl, _unset) ? this.externalUrl : externalUrl as String?,
    publicUrl:
        identical(publicUrl, _unset) ? this.publicUrl : publicUrl as String?,
    width: identical(width, _unset) ? this.width : width as int?,
    height: identical(height, _unset) ? this.height : height as int?,
    blurHash:
        identical(blurHash, _unset) ? this.blurHash : blurHash as String?,
    lqip: identical(lqip, _unset) ? this.lqip : lqip as String?,
    hotspot: identical(hotspot, _unset) ? this.hotspot : hotspot as Hotspot?,
    crop: identical(crop, _unset) ? this.crop : crop as CropRect?,
    altText: identical(altText, _unset) ? this.altText : altText as String?,
    scale: identical(scale, _unset) ? this.scale : scale as double?,
    offset: identical(offset, _unset) ? this.offset : offset as ImageOffset?,
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
          altText == other.altText &&
          scale == other.scale &&
          offset == other.offset;

  @override
  int get hashCode =>
      Object.hash(assetId, externalUrl, publicUrl, hotspot, crop, altText, scale, offset);

  @override
  String toString() =>
      'ImageReference(assetId: $assetId, externalUrl: $externalUrl, publicUrl: $publicUrl)';
}
