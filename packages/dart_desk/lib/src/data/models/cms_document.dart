import 'dart:convert';

/// Platform-agnostic CMS document model.
///
/// This represents document metadata without the actual content data.
/// The content is stored in DocumentVersion objects.
class CmsDocument {
  /// Database ID (null for new documents not yet persisted)
  final int? id;

  /// Client ID (multi-tenant support)
  final int clientId;

  /// The document type identifier (e.g., 'article', 'page', 'product')
  final String documentType;

  /// The document title
  final String title;

  /// URL-friendly slug
  final String? slug;

  /// Whether this is the default document for this type
  final bool isDefault;

  /// Cached data from the active (published) version
  final Map<String, dynamic>? activeVersionData;

  /// When the document was created
  final DateTime? createdAt;

  /// When the document was last updated
  final DateTime? updatedAt;

  /// ID of the user who created this document
  final int? createdByUserId;

  /// ID of the user who last updated this document
  final int? updatedByUserId;

  const CmsDocument({
    this.id,
    required this.clientId,
    required this.documentType,
    required this.title,
    this.slug,
    this.isDefault = false,
    this.activeVersionData,
    this.createdAt,
    this.updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  });

  /// Creates a copy of this document with the given fields replaced.
  CmsDocument copyWith({
    int? id,
    int? clientId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Map<String, dynamic>? activeVersionData,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) {
    return CmsDocument(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      activeVersionData: activeVersionData ??
          (this.activeVersionData != null
              ? Map<String, dynamic>.from(this.activeVersionData!)
              : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
    );
  }

  /// Creates a [CmsDocument] from a JSON map.
  factory CmsDocument.fromJson(Map<String, dynamic> json) {
    final rawData = json['activeVersionData'];
    Map<String, dynamic>? parsedData;

    if (rawData is String && rawData.isNotEmpty) {
      try {
        parsedData = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        parsedData = null;
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    }

    return CmsDocument(
      id: json['id'] as int?,
      clientId: json['clientId'] as int,
      documentType: json['documentType'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      activeVersionData: parsedData,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdByUserId: json['createdByUserId'] as int?,
      updatedByUserId: json['updatedByUserId'] as int?,
    );
  }

  /// Converts this document to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (activeVersionData != null) 'activeVersionData': activeVersionData,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  String toString() {
    return 'CmsDocument(id: $id, type: $documentType, title: $title, slug: $slug, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CmsDocument &&
        other.id == id &&
        other.documentType == documentType &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, documentType, slug);
}
