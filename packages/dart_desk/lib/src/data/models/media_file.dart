/// Platform-agnostic media file data model.
///
/// This model represents a media file (image, document, etc.) independent
/// of any specific backend implementation.
class MediaFile {
  /// Database ID (null for new files not yet persisted)
  final int? id;

  /// Original filename
  final String fileName;

  /// File type/extension (e.g., 'jpg', 'pdf', 'png')
  final String fileType;

  /// File size in bytes
  final int fileSize;

  /// Public URL to access the file
  final String publicUrl;

  /// Optional alt text for accessibility
  final String? altText;

  /// Optional metadata as JSON string
  final String? metadata;

  /// When the file was uploaded
  final DateTime? createdAt;

  /// ID of the user who uploaded this file
  final int? uploadedByUserId;

  const MediaFile({
    this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.publicUrl,
    this.altText,
    this.metadata,
    this.createdAt,
    this.uploadedByUserId,
  });

  /// Creates a copy of this media file with the given fields replaced.
  MediaFile copyWith({
    int? id,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? publicUrl,
    String? altText,
    String? metadata,
    DateTime? createdAt,
    int? uploadedByUserId,
  }) {
    return MediaFile(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      publicUrl: publicUrl ?? this.publicUrl,
      altText: altText ?? this.altText,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
    );
  }

  /// Creates a [MediaFile] from a JSON map.
  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as int?,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      publicUrl: json['publicUrl'] as String,
      altText: json['altText'] as String?,
      metadata: json['metadata'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      uploadedByUserId: json['uploadedByUserId'] as int?,
    );
  }

  /// Converts this media file to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'publicUrl': publicUrl,
      if (altText != null) 'altText': altText,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
    };
  }

  /// Returns a human-readable file size string.
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Returns true if this is an image file.
  bool get isImage {
    const imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'];
    return imageTypes.contains(fileType.toLowerCase());
  }

  @override
  String toString() {
    return 'MediaFile(id: $id, fileName: $fileName, fileType: $fileType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
