import 'package:dart_desk_annotation/dart_desk_annotation.dart';
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

  final currentDocumentTypeSlug = Signal<String?>(
    null,
    debugLabel: 'currentDocumentTypeSlug',
  );
  final currentDocumentId = Signal<String?>(
    null,
    debugLabel: 'currentDocumentId',
  );
  final currentVersionId = Signal<String?>(
    null,
    debugLabel: 'currentVersionId',
  );

  /// Computed: resolves the slug to a CmsDocumentType object.
  late final currentDocumentType = Computed<CmsDocumentType?>(() {
    final slug = currentDocumentTypeSlug.value;
    if (slug == null) return null;
    try {
      return documentTypes.firstWhere((dt) => dt.name == slug);
    } catch (_) {
      return null;
    }
  }, debugLabel: 'currentDocumentType');

  // ============================================================
  // Pagination & Search Signals
  // ============================================================

  final page = Signal<int>(1, debugLabel: 'page');
  final pageSize = Signal<int>(20, debugLabel: 'pageSize');
  final searchQuery = Signal<String?>(null, debugLabel: 'searchQuery');

  // ============================================================
  // Operation State Signals
  // ============================================================

  final isSaving = Signal<bool>(false, debugLabel: 'isSaving');

  // ============================================================
  // UI State Signals
  // ============================================================

  final sidebarCollapsed = Signal<bool>(false, debugLabel: 'sidebarCollapsed');
  final documentListVisible = Signal<bool>(
    true,
    debugLabel: 'documentListVisible',
  );

  // ============================================================
  // Computed Signals
  // ============================================================

  late final queryParams = Computed(() {
    return _DocumentQueryParams(
      documentType: currentDocumentType.value?.name,
      page: page.value,
      pageSize: pageSize.value,
      search: searchQuery.value,
    );
  }, debugLabel: 'queryParams');

  // ============================================================
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  late final documentsContainer = SignalContainer(
    (_DocumentQueryParams params) => FutureSignal(
      () => _fetchDocumentsWithParams(params),
      debugLabel: 'documents',
    ),
    cache: true,
  );

  late final versionsContainer = SignalContainer(
    (int documentId) => FutureSignal(
      () => dataSource.getDocumentVersions(documentId),
      debugLabel: 'versions',
    ),
    cache: true,
  );

  late final documentDataContainer = SignalContainer(
    (int versionId) => FutureSignal(
      () => _fetchVersionWithData(versionId),
      debugLabel: 'documentData',
    ),
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

  /// Fetches a document version with its data.
  ///
  /// `getDocumentVersion` returns metadata only (no data field).
  /// This method also fetches the version data and combines them.
  Future<DocumentVersion?> _fetchVersionWithData(int versionId) async {
    final results = await Future.wait([
      dataSource.getDocumentVersion(versionId),
      dataSource.getDocumentVersionData(versionId),
    ]);
    final version = results[0] as DocumentVersion?;
    final data = results[1] as Map<String, dynamic>?;
    if (version == null) return null;
    return version.copyWith(data: data);
  }

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
    final docChanged = _documentViewModel.documentId.value != docIdInt;
    if (docChanged) {
      _documentViewModel.documentId.value = docIdInt;
      // Reset shared editedData when switching documents
      _documentViewModel.editedData.value = {};
    }
    currentDocumentId.value = documentId;

    // Update version ID
    currentVersionId.value = versionId;

    // If version ID changed, also set selectedVersionId for containers
    final versionIdInt = versionId != null ? int.tryParse(versionId) : null;
    selectedVersionId.value = versionIdInt;

    // Auto-select latest version when document is opened without a version
    if (docIdInt != null && versionIdInt == null) {
      _autoSelectLatestVersion(docIdInt);
    }
  }

  /// Fetches versions for a document and auto-selects the latest one.
  /// Pre-populates editedData so the preview and editor have data immediately.
  Future<void> _autoSelectLatestVersion(int docId) async {
    try {
      final versions = await dataSource.getDocumentVersions(docId);
      if (versions.versions.isNotEmpty) {
        final versionId = versions.versions.first.id!;

        // Use the document's activeVersionData which reflects the latest
        // CRDT-merged state, rather than getDocumentVersionData which only
        // reconstructs state up to the version's snapshot HLC.
        final doc = await dataSource.getDocument(docId);
        final docData = doc?.activeVersionData;
        if (docData != null && docData.isNotEmpty) {
          _documentViewModel.editedData.value = Map<String, dynamic>.from(
            docData,
          );
        }

        // Set version ID after editedData so the editor's early-return
        // path (editedData.isNotEmpty) prevents the loading→form transition.
        selectedVersionId.value = versionId;
      }
    } catch (_) {
      // Silently ignore — editor will show empty state
    }
  }

  final selectedVersionId = Signal<int?>(null, debugLabel: 'selectedVersionId');

  // ============================================================
  // Document Operations
  // ============================================================

  Future<String?> suggestSlug(String title) async {
    final docType = currentDocumentType.value;
    if (docType == null) return null;
    return await dataSource.suggestSlug(title, docType.name);
  }

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
        selectedVersionId.value = versions.versions.first.id;
      }

      documentsContainer(queryParams.value).reload();

      return document;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    final result = await dataSource.deleteDocument(documentId);
    if (result) {
      if (_documentViewModel.documentId.value == documentId) {
        _documentViewModel.documentId.value = null;
        selectedVersionId.value = null;
      }
      documentsContainer(queryParams.value).reload();
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
    final versionId = selectedVersionId.value;
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
    final versionId = selectedVersionId.value;
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
      if (selectedVersionId.value == versionId) {
        selectedVersionId.value = null;
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
    final versionId = selectedVersionId.value;
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
    selectedVersionId.dispose();
    _documentViewModel.dispose();
    page.dispose();
    pageSize.dispose();
    searchQuery.dispose();
    sidebarCollapsed.dispose();
    documentListVisible.dispose();
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
