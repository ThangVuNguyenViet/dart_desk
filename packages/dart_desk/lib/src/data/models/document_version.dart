/// Status of a document version
enum DocumentVersionStatus {
  /// Version is being edited and not visible to public
  draft('draft'),

  /// Version is published and visible to public
  published('published'),

  /// Version is archived and hidden from public
  archived('archived'),

  /// Version is scheduled to be published at a future date
  scheduled('scheduled');

  const DocumentVersionStatus(this.value);

  final String value;

  /// Parse from string value
  static DocumentVersionStatus fromString(String value) {
    return DocumentVersionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentVersionStatus.draft,
    );
  }
}

/// Platform-agnostic document version model.
///
/// This model represents a version of a CMS document, supporting
/// version history, publishing workflows, and scheduling.
class DocumentVersion {
  /// Database ID (null for new versions not yet persisted)
  final int? id;

  /// The ID of the document this version belongs to
  final int documentId;

  /// The version number (1, 2, 3, etc.)
  final int versionNumber;

  /// The status of this version
  final DocumentVersionStatus status;

  /// The document data at this version (reconstructed from CRDT operations)
  final Map<String, dynamic>? data;

  /// Optional changelog describing what changed in this version
  final String? changeLog;

  /// When this version was published (null if not published)
  final DateTime? publishedAt;

  /// When this version is scheduled to be published (null if not scheduled)
  final DateTime? scheduledAt;

  /// When this version was archived (null if not archived)
  final DateTime? archivedAt;

  /// When the version was created
  final DateTime? createdAt;

  /// ID of the user who created this version
  final int? createdByUserId;

  const DocumentVersion({
    this.id,
    required this.documentId,
    required this.versionNumber,
    required this.status,
    this.data,
    this.changeLog,
    this.publishedAt,
    this.scheduledAt,
    this.archivedAt,
    this.createdAt,
    this.createdByUserId,
  });

  /// Whether this version is a draft
  bool get isDraft => status == DocumentVersionStatus.draft;

  /// Whether this version is published
  bool get isPublished => status == DocumentVersionStatus.published;

  /// Whether this version is archived
  bool get isArchived => status == DocumentVersionStatus.archived;

  /// Whether this version is scheduled for future publishing
  bool get isScheduled => status == DocumentVersionStatus.scheduled && scheduledAt != null;

  /// Creates a copy of this version with the given fields replaced.
  DocumentVersion copyWith({
    int? id,
    int? documentId,
    int? versionNumber,
    DocumentVersionStatus? status,
    Map<String, dynamic>? data,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    int? createdByUserId,
  }) {
    return DocumentVersion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      data: data ?? this.data,
      changeLog: changeLog ?? this.changeLog,
      publishedAt: publishedAt ?? this.publishedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  /// Creates a [DocumentVersion] from a JSON map.
  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'] as int?,
      documentId: json['documentId'] as int,
      versionNumber: json['versionNumber'] as int,
      status: DocumentVersionStatus.fromString(json['status'] as String),
      data: json['data'] as Map<String, dynamic>?,
      changeLog: json['changeLog'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      createdByUserId: json['createdByUserId'] as int?,
    );
  }

  /// Converts this version to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'documentId': documentId,
      'versionNumber': versionNumber,
      'status': status.value,
      if (data != null) 'data': data,
      if (changeLog != null) 'changeLog': changeLog,
      if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
    };
  }

  @override
  String toString() {
    return 'DocumentVersion(id: $id, documentId: $documentId, v$versionNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentVersion &&
        other.id == id &&
        other.documentId == documentId &&
        other.versionNumber == versionNumber;
  }

  @override
  int get hashCode => Object.hash(id, documentId, versionNumber);
}

/// Paginated list of document versions.
class DocumentVersionList {
  /// The list of versions
  final List<DocumentVersion> versions;

  /// Total number of versions available
  final int total;

  /// Current page number (1-based)
  final int page;

  /// Number of items per page
  final int pageSize;

  const DocumentVersionList({
    required this.versions,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// Whether there is a next page
  bool get hasNextPage => page * pageSize < total;

  /// Whether there is a previous page
  bool get hasPreviousPage => page > 1;

  /// Total number of pages
  int get totalPages => (total / pageSize).ceil();

  /// Creates an empty list
  factory DocumentVersionList.empty() {
    return const DocumentVersionList(
      versions: [],
      total: 0,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  String toString() {
    return 'DocumentVersionList(versions: ${versions.length}, total: $total, page: $page)';
  }
}
