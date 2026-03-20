/// Result of a media file upload operation.
///
/// Contains the essential information about the uploaded file.
class MediaUploadResult {
  /// The ID of the uploaded file (as string for flexibility)
  final String id;

  /// Public URL to access the uploaded file
  final String url;

  /// Original filename (if preserved)
  final String? fileName;

  const MediaUploadResult({
    required this.id,
    required this.url,
    this.fileName,
  });

  /// Creates a copy of this result with the given fields replaced.
  MediaUploadResult copyWith({
    String? id,
    String? url,
    String? fileName,
  }) {
    return MediaUploadResult(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
    );
  }

  /// Creates a [MediaUploadResult] from a JSON map.
  factory MediaUploadResult.fromJson(Map<String, dynamic> json) {
    return MediaUploadResult(
      id: json['id'] as String,
      url: json['url'] as String,
      fileName: json['fileName'] as String?,
    );
  }

  /// Converts this result to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      if (fileName != null) 'fileName': fileName,
    };
  }

  @override
  String toString() {
    return 'MediaUploadResult(id: $id, url: $url, fileName: $fileName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaUploadResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
