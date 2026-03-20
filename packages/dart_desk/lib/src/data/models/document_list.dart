import 'cms_document.dart';

/// Paginated list of CMS documents.
///
/// Contains the documents for the current page along with pagination metadata.
class DocumentList {
  /// The documents in the current page
  final List<CmsDocument> documents;

  /// Total number of documents matching the query (across all pages)
  final int total;

  /// Current page number (1-indexed)
  final int page;

  /// Number of documents per page
  final int pageSize;

  const DocumentList({
    required this.documents,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// Total number of pages
  int get totalPages => (total / pageSize).ceil();

  /// Whether there is a next page
  bool get hasNextPage => page < totalPages;

  /// Whether there is a previous page
  bool get hasPreviousPage => page > 1;

  /// Whether the list is empty
  bool get isEmpty => documents.isEmpty;

  /// Whether the list is not empty
  bool get isNotEmpty => documents.isNotEmpty;

  /// Creates an empty list
  factory DocumentList.empty() {
    return const DocumentList(
      documents: [],
      total: 0,
      page: 1,
      pageSize: 20,
    );
  }

  /// Creates a copy of this list with the given fields replaced.
  DocumentList copyWith({
    List<CmsDocument>? documents,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return DocumentList(
      documents: documents ?? this.documents,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Creates a [DocumentList] from a JSON map.
  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      documents: (json['documents'] as List<dynamic>)
          .map((e) => CmsDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  /// Converts this list to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'documents': documents.map((d) => d.toJson()).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  String toString() {
    return 'DocumentList(documents: ${documents.length}, total: $total, page: $page/$totalPages)';
  }
}
