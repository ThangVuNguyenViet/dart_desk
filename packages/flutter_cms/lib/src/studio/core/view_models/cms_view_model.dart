import 'package:flutter_cms_annotation/flutter_cms_annotation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../data/models/document_list.dart';
import '../../../data/models/document_version.dart';
import 'cms_document_view_model.dart';

class CmsViewModel {
  /// The data source for backend communication.
  final CmsDataSource dataSource;

  /// Document-specific view model
  final CmsDocumentViewModel _documentViewModel;

  // ============================================================
  // Selection Signals
  // ============================================================

  /// Signal for the currently selected document type
  final selectedDocumentType = Signal<CmsDocumentType?>(null);

  /// Signal for the currently selected version ID
  final selectedVersionId = Signal<int?>(null);

  // ============================================================
  // Pagination & Search Signals
  // ============================================================

  /// Signal for pagination - current page
  final page = Signal<int>(1);

  /// Signal for pagination - page size
  final pageSize = Signal<int>(20);

  /// Signal for search query
  final searchQuery = Signal<String?>(null);

  // ============================================================
  // Operation State Signals
  // ============================================================

  /// Signal indicating a save operation is in progress
  final isSaving = Signal<bool>(false);

  // ============================================================
  // Computed Signals
  // ============================================================

  /// Computed signal that combines all document query parameters.
  late final queryParams = Computed(
    () => _DocumentQueryParams(
      documentType: selectedDocumentType.value?.name,
      page: page.value,
      pageSize: pageSize.value,
      search: searchQuery.value,
    ),
  );

  // ============================================================
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  /// Container for fetching documents list based on query parameters.
  /// Automatically creates and caches signals per parameter combination.
  late final documentsContainer = SignalContainer(
    (_DocumentQueryParams params) =>
        FutureSignal(() => _fetchDocumentsWithParams(params)),
    cache: true,
  );

  /// Container for fetching versions of a document by document ID.
  /// Automatically creates and caches signals per document ID.
  late final versionsContainer = SignalContainer(
    (int documentId) =>
        FutureSignal(() => dataSource.getDocumentVersions(documentId)),
    cache: true,
  );

  /// Container for fetching version data by version ID.
  /// Automatically creates and caches signals per version ID.
  late final documentDataContainer = SignalContainer(
    (int versionId) =>
        FutureSignal(() => dataSource.getDocumentVersion(versionId)),
    cache: true,
  );

  // ============================================================
  // Constructor
  // ============================================================

  /// Creates a new CmsViewModel.
  ///
  /// [dataSource] - The data source for backend communication.
  CmsViewModel({
    required this.dataSource,
    required CmsDocumentViewModel documentViewModel,
  }) : _documentViewModel = documentViewModel;

  // ============================================================
  // Internal Fetch Methods
  // ============================================================

  /// Internal method to fetch documents based on query params.
  Future<DocumentList> _fetchDocumentsWithParams(
    _DocumentQueryParams params,
  ) async {
    final documentType = params.documentType;

    if (documentType == null) {
      return DocumentList.empty();
    }

    final offset = (params.page - 1) * params.pageSize;
    return await dataSource.getDocuments(
      documentType,
      search: params.search,
      limit: params.pageSize,
      offset: offset,
    );
  }

  // ============================================================
  // Document Type Selection
  // ============================================================

  /// Selects a document type and clears any current selection.
  void selectDocumentType(CmsDocumentType? documentType) {
    selectedDocumentType.value = documentType;
    _documentViewModel.documentId.value = null;
    selectedVersionId.value = null;
  }

  /// Clears the selected document type and all selections.
  void clearSelection() {
    selectedDocumentType.value = null;
    _documentViewModel.documentId.value = null;
    selectedVersionId.value = null;
  }

  // ============================================================
  // Document Selection
  // ============================================================

  /// Selects a document by ID, which will trigger fetching its versions.
  void selectDocument(int documentId) {
    _documentViewModel.documentId.value = documentId;
    selectedVersionId.value = null;
  }

  // ============================================================
  // Version Selection
  // ============================================================

  /// Selects a version by ID, which will trigger fetching its data.
  void selectVersion(int versionId) {
    selectedVersionId.value = versionId;
  }

  /// Clears the selected version.
  void clearVersionSelection() {
    selectedVersionId.value = null;
  }

  // ============================================================
  // Document Operations
  // ============================================================

  /// Creates a new document with initial version.
  ///
  /// [title] - The document title
  /// [data] - The initial document data
  /// [slug] - Optional URL slug
  /// [isDefault] - Whether this is the default document for this type
  ///
  /// Returns the created document.
  Future<CmsDocument?> createDocument(
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    final docType = selectedDocumentType.value;
    if (docType == null) return null;

    isSaving.value = true;
    try {
      // Create the document (backend creates initial version automatically)
      final document = await dataSource.createDocument(
        docType.name,
        title,
        data,
        slug: slug,
        isDefault: isDefault,
      );

      // Select the new document
      _documentViewModel.documentId.value = document.id;

      // Refresh by clearing the container caches (they will refetch on next access)
      // Note: In Signals, changing the signal values will automatically trigger recomputation

      // Select the first version (which was just created)
      final versions = await dataSource.getDocumentVersions(document.id!);
      if (versions.versions.isNotEmpty) {
        selectedVersionId.value = versions.versions.first.id;
      }

      return document;
    } finally {
      isSaving.value = false;
    }
  }

  /// Deletes a document by ID.
  ///
  /// Returns true if the document was deleted, false otherwise.
  Future<bool> deleteDocument(int documentId) async {
    final result = await dataSource.deleteDocument(documentId);
    if (result && _documentViewModel.documentId.value == documentId) {
      _documentViewModel.documentId.value = null;
      selectedVersionId.value = null;
    }
    // Changing signals will automatically trigger recomputation
    return result;
  }

  // ============================================================
  // Document Data Operations
  // ============================================================

  /// Updates the current document data using CRDT operations (partial updates).
  /// Only changed fields need to be provided - they will be merged automatically.
  ///
  /// [data] - Map of field updates (only changed fields)
  ///
  /// Returns the updated document.
  Future<CmsDocument?> updateDocumentData(Map<String, dynamic> data) async {
    final documentId = _documentViewModel.documentId.value;
    if (documentId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocumentData(documentId, data);

      // Refresh the documents list to show updated data
      final params = _DocumentQueryParams(
        documentType: selectedDocumentType.value?.name,
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

  /// Publishes the currently selected version.
  ///
  /// Returns the updated version data with published status.
  Future<DocumentVersion?> publishVersion() async {
    final versionId = selectedVersionId.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.publishDocumentVersion(versionId);

      // Refresh the document data and versions to get the updated data
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

  /// Archives the currently selected version.
  ///
  /// Returns the updated version data with archived status.
  Future<DocumentVersion?> archiveVersion() async {
    final versionId = selectedVersionId.value;
    if (versionId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.archiveDocumentVersion(versionId);

      // Refresh the document data and versions to get the updated data
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

  /// Deletes a version by ID.
  ///
  /// Returns true if the version was deleted, false otherwise.
  Future<bool> deleteVersion(int versionId) async {
    final result = await dataSource.deleteDocumentVersion(versionId);
    if (result) {
      if (selectedVersionId.value == versionId) {
        selectedVersionId.value = null;
      }

      // Refresh the versions list to reflect the deletion
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

  /// Sets the search query.
  void setSearchQuery(String? query) {
    searchQuery.value = query;
  }

  /// Sets the current page.
  void setPage(int value) {
    page.value = value;
  }

  /// Sets the page size.
  void setPageSize(int value) {
    pageSize.value = value;
  }

  // ============================================================
  // Refresh Methods
  // ============================================================

  /// Manually refreshes the documents list by refreshing the container signal.
  void refreshDocuments() {
    final params = queryParams.value;
    if (params.documentType != null) {
      documentsContainer(params).reload();
    }
  }

  /// Manually refreshes the versions list by refreshing the container signal.
  void refreshVersions() {
    final docId = _documentViewModel.documentId.value;
    if (docId != null) {
      versionsContainer(docId).reload();
    }
  }

  /// Manually refreshes the selected document data by refreshing the container signal.
  void refreshSelectedData() {
    final versionId = selectedVersionId.value;
    if (versionId != null) {
      documentDataContainer(versionId).reload();
    }
  }

  // ============================================================
  // Disposal
  // ============================================================

  /// Disposes all resources and signals.
  void dispose() {
    queryParams.dispose();
    selectedDocumentType.dispose();
    _documentViewModel.dispose();
    selectedVersionId.dispose();
    page.dispose();
    pageSize.dispose();
    searchQuery.dispose();
    isSaving.dispose();
    // Note: SignalContainers and their cached signals will be
    // automatically disposed when they have no listeners
  }
}

/// Internal class to hold document query parameters.
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
