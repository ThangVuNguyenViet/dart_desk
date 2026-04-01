/// Lightweight image reference that can hold either an uploaded asset ID
/// or an external URL (e.g. a Lottie animation URL, CDN image).
///
/// Serialised as `{ '_type': 'imageReference', 'assetId': '...' }` or
/// `{ '_type': 'imageReference', 'externalUrl': '...' }`.
class ImageRef {
  final String? assetId;
  final String? externalUrl;

  const ImageRef({this.assetId, this.externalUrl});

  factory ImageRef.fromMap(Map<String, dynamic> map) => ImageRef(
    assetId: map['assetId'] as String?,
    externalUrl: map['externalUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    '_type': 'imageReference',
    if (assetId != null) 'assetId': assetId,
    if (externalUrl != null) 'externalUrl': externalUrl,
  };

  static bool isImageRef(Map<String, dynamic> map) =>
      map['_type'] == 'imageReference';

  /// Resolves to a displayable URL.
  ///
  /// Pass an [assetResolver] that converts an asset ID to an absolute URL
  /// (e.g. `'${serverUrl}files/$id'`). Returns `null` if neither field is set.
  String? resolveUrl(String Function(String assetId) assetResolver) {
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return assetResolver(assetId!);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageRef &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          externalUrl == other.externalUrl;

  @override
  int get hashCode => Object.hash(assetId, externalUrl);

  @override
  String toString() =>
      'ImageRef(assetId: $assetId, externalUrl: $externalUrl)';
}
