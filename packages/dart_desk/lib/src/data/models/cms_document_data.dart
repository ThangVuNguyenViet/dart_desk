import 'dart:convert';

/// Platform-agnostic document data model.
///
/// This model represents a CMS document independent of any specific
/// backend implementation (Serverpod, local database, etc.).
class CmsDocumentData {
  /// Database ID (null for new documents not yet persisted)
  final int? id;

  /// The document type identifier (e.g., 'article', 'page', 'product')
  final String documentType;

  /// The document's data as a flexible map structure
  final Map<String, dynamic> data;

  /// When the document was created
  final DateTime? createdAt;

  /// When the document was last updated
  final DateTime? updatedAt;

  /// ID of the user who created this document
  final int? createdByUserId;

  /// ID of the user who last updated this document
  final int? updatedByUserId;

  const CmsDocumentData({
    this.id,
    required this.documentType,
    required this.data,
    this.createdAt,
    this.updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  });

  /// Creates a copy of this document with the given fields replaced.
  CmsDocumentData copyWith({
    int? id,
    String? documentType,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) {
    return CmsDocumentData(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      data: data ?? Map<String, dynamic>.from(this.data),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
    );
  }

  /// Creates a [CmsDocumentData] from a JSON map.
  factory CmsDocumentData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Map<String, dynamic> parsedData;

    if (rawData is String) {
      parsedData = jsonDecode(rawData) as Map<String, dynamic>;
    } else if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    } else {
      parsedData = {};
    }

    return CmsDocumentData(
      id: json['id'] as int?,
      documentType: json['documentType'] as String,
      data: parsedData,
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
      'documentType': documentType,
      'data': data,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  String toString() {
    return 'CmsDocumentData(id: $id, documentType: $documentType, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CmsDocumentData &&
        other.id == id &&
        other.documentType == documentType;
  }

  @override
  int get hashCode => Object.hash(id, documentType);
}
