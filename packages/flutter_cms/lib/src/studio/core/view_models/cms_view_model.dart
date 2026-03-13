import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../data/models/document_list.dart';
import '../../../data/models/document_version.dart';
import 'cms_document_view_model.dart';

class CmsViewModel {
  final CmsDataSource dataSource;
  final CmsDocumentViewModel _documentViewModel;

  /// The registered document types (injected from coordinator/app config).
  final List<CmsDocumentType> documentTypes;

  // ============================================================
  // Route Param Signals (set by coordinator via setRouteParams)
  // ============================================================

  final currentDocumentTypeSlug = Signal<String?>(null);
  final currentDocumentId = Signal<String?>(null);
  final currentVersionId = Signal<String?>(null);

  /// Computed: resolves the slug to a CmsDocumentType object.
  late final currentDocumentType = Computed<CmsDocumentType?>(() {
    final slug = currentDocumentTypeSlug.value;
    if (slug == null) return null;
    try {
      return documentTypes.firstWhere((dt) => dt.name == slug);
    } catch (_) {
      return null;
    }
  });

  // ============================================================
  // Pagination & Search Signals
  // ============================================================

  final page = Signal<int>(1);
  final pageSize = Signal<int>(20);
  final searchQuery = Signal<String?>(null);

  // ============================================================
  // Operation State Signals
  // ============================================================

  final isSaving = Signal<bool>(false);

  // ============================================================
  // Computed Signals
  // ============================================================

  late final queryParams = Computed(
    () => _DocumentQueryParams(
      documentType: currentDocumentType.value?.name,
      page: page.value,
      pageSize: pageSize.value,
      search: searchQuery.value,
    ),
  );

  // ============================================================
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  late final documentsContainer = SignalContainer(
    (_DocumentQueryParams params) =>
        FutureSignal(() => _fetchDocumentsWithParams(params)),
    cache: true,
  );

  late final versionsContainer = SignalContainer(
    (int documentId) =>
        FutureSignal(() => dataSource.getDocumentVersions(documentId)),
    cache: true,
  );

  late final documentDataContainer = SignalContainer(
    (int versionId) =>
        FutureSignal(() => dataSource.getDocumentVersion(versionId)),
    cache: true,
  );

  // ============================================================
  // Constructor
  // ============================================================

  CmsViewModel({
    required this.dataSource,
    required CmsDocumentViewModel documentViewModel,
    required this.documentTypes,
  }) : _documentViewModel = documentViewModel;

  // ============================================================
  // Internal Fetch Methods
  // ============================================================

  Future<DocumentList> _fetchDocumentsWithParams(
    _DocumentQueryParams params,
  ) async {
    final documentType = params.documentType;
    if (documentType == null) return DocumentList.empty();

    final offset = (params.page - 1) * params.pageSize;
    return await dataSource.getDocuments(
      documentType,
      search: params.search,
      limit: params.pageSize,
      offset: offset,
    );
  }

  // ============================================================
  // Route Params (called by coordinator on route change)
  // ============================================================

  /// Called by the coordinator when the URL changes.
  /// Sets all route param signals and updates the document view model.
  void setRouteParams({
    String? documentTypeSlug,
    String? documentId,
    String? versionId,
  }) {
    currentDocumentTypeSlug.value = documentTypeSlug;

    // Update document ID (and document view model)
    final docIdInt = documentId != null ? int.tryParse(documentId) : null;
    if (_documentViewModel.documentId.value != docIdInt) {
      _documentViewModel.documentId.value = docIdInt;
    }
    currentDocumentId.value = documentId;

    // Update version ID
    currentVersionId.value = versionId;

    // If version ID changed, also set selectedVersionId for containers
    final versionIdInt = versionId != null ? int.tryParse(versionId) : null;
    _selectedVersionIdInt.value = versionIdInt;
  }

  /// Internal int version of selectedVersionId for containers.
  final _selectedVersionIdInt = Signal<int?>(null);

  /// Public getter for the int version ID (used by panels).
  int? get selectedVersionIdInt => _selectedVersionIdInt.value;

  // ============================================================
  // Document Operations
  // ============================================================

  Future<CmsDocument?> createDocument(
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docType = currentDocumentType.value;
    if (docType == null) return null;

    isSaving.value = true;
    try {
      final document = await dataSource.createDocument(
        docType.name,
        title,
        data,
        slug: slug,
        isDefault: isDefault,
      );

      _documentViewModel.documentId.value = document.id;

      final versions = await dataSource.getDocumentVersions(document.id!);
      if (versions.versions.isNotEmpty) {
        _selectedVersionIdInt.value = versions.versions.first.id;
      }

      return document;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    final result = await dataSource.deleteDocument(documentId);
    if (result && _documentViewModel.documentId.value == documentId) {
      _documentViewModel.documentId.value = null;
      _selectedVersionIdInt.value = null;
    }
    return result;
  }

  Future<CmsDocument?> updateDocumentData(Map<String, dynamic> data) async {
    final documentId = _documentViewModel.documentId.value;
    if (documentId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocumentData(documentId, data);

      final params = _DocumentQueryParams(
        documentType: currentDocumentType.value?.name,
        page: page.value,
        pageSize: pageSize.value,
      );
      documentsContainer(params).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // Version Status Operations
  // ============================================================

  Future<DocumentVersion?> publishVersion() async {
    final versionId = _selectedVersionIdInt.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.publishDocumentVersion(versionId);

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
      documentDataContainer(versionId).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  Future<DocumentVersion?> archiveVersion() async {
    final versionId = _selectedVersionIdInt.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.archiveDocumentVersion(versionId);

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
      documentDataContainer(versionId).reload();

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteVersion(int versionId) async {
    final result = await dataSource.deleteDocumentVersion(versionId);
    if (result) {
      if (_selectedVersionIdInt.value == versionId) {
        _selectedVersionIdInt.value = null;
      }

      final docId = _documentViewModel.documentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
    }
    return result;
  }

  // ============================================================
  // Pagination & Search
  // ============================================================

  void setSearchQuery(String? query) {
    searchQuery.value = query;
  }

  void setPage(int value) {
    page.value = value;
  }

  void setPageSize(int value) {
    pageSize.value = value;
  }

  // ============================================================
  // Refresh Methods
  // ============================================================

  void refreshDocuments() {
    final params = queryParams.value;
    if (params.documentType != null) {
      documentsContainer(params).reload();
    }
  }

  void refreshVersions() {
    final docId = _documentViewModel.documentId.value;
    if (docId != null) {
      versionsContainer(docId).reload();
    }
  }

  void refreshSelectedData() {
    final versionId = _selectedVersionIdInt.value;
    if (versionId != null) {
      documentDataContainer(versionId).reload();
    }
  }

  // ============================================================
  // Disposal
  // ============================================================

  void dispose() {
    queryParams.dispose();
    currentDocumentType.dispose();
    currentDocumentTypeSlug.dispose();
    currentDocumentId.dispose();
    currentVersionId.dispose();
    _selectedVersionIdInt.dispose();
    _documentViewModel.dispose();
    page.dispose();
    pageSize.dispose();
    searchQuery.dispose();
    isSaving.dispose();
  }
}

class _DocumentQueryParams {
  final String? documentType;
  final int page;
  final int pageSize;
  final String? search;

  const _DocumentQueryParams({
    this.documentType,
    required this.page,
    required this.pageSize,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DocumentQueryParams &&
          documentType == other.documentType &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search;

  @override
  int get hashCode => Object.hash(documentType, page, pageSize, search);
}
