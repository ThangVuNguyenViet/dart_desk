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

  /// Default resolver used by [url]. Set this once at app startup so that
  /// asset-ID-based refs resolve without passing a resolver every time.
  ///
  /// Example:
  /// ```dart
  /// ImageRef.defaultAssetResolver = (id) => '${serverUrl}files/$id';
  /// ```
  static String Function(String assetId)? defaultAssetResolver;

  /// Returns the URL for this image reference using [defaultAssetResolver]
  /// for asset-ID-based refs. Returns [externalUrl] directly if set.
  /// Returns `null` if neither field is set or no resolver is configured.
  String? get url {
    if (externalUrl != null) return externalUrl;
    if (assetId != null) return defaultAssetResolver?.call(assetId!);
    return null;
  }

  /// Resolves to a displayable URL using an explicit [assetResolver].
  ///
  /// Prefer [url] when [defaultAssetResolver] is configured. Use this when
  /// you need a one-off resolver different from the default.
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
