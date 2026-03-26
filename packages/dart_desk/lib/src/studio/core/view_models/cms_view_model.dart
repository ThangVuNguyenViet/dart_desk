import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../data/models/document_version.dart';
class CmsViewModel {
  final DataSource dataSource;

  /// The registered document types (injected from coordinator/app config).
  final List<DocumentType> documentTypes;

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

  /// Computed: resolves the slug to a DocumentType object.
  late final currentDocumentType = Computed<DocumentType?>(() {
    final slug = currentDocumentTypeSlug.value;
    if (slug == null) return null;
    try {
      return documentTypes.firstWhere((dt) => dt.name == slug);
    } catch (_) {
      return null;
    }
  }, debugLabel: 'currentDocumentType');

  // ============================================================
  // Search Signal
  // ============================================================

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
  // Signal Containers for Dynamic Data Fetching
  // ============================================================

  late final documentsContainer = SignalContainer(
    (String documentType) => FutureSignal(
      () => dataSource.getDocuments(documentType, limit: 200),
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
    required this.documentTypes,
  });

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

    final docIdInt = documentId != null ? int.tryParse(documentId) : null;
    selectedDocumentId.value = docIdInt;
    currentDocumentId.value = documentId;

    // Update version ID
    currentVersionId.value = versionId;

    final versionIdInt = versionId != null ? int.tryParse(versionId) : null;
    selectedVersionId.value = versionIdInt;
  }

  final selectedDocumentId = Signal<int?>(null, debugLabel: 'selectedDocumentId');
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

      selectedDocumentId.value = document.id;

      final versions = await dataSource.getDocumentVersions(document.id!);
      if (versions.versions.isNotEmpty) {
        selectedVersionId.value = versions.versions.first.id;
      }

      documentsContainer(currentDocumentType.value?.name ?? '').reload();

      return document;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    final result = await dataSource.deleteDocument(documentId);
    if (result) {
      if (selectedDocumentId.value == documentId) {
        selectedDocumentId.value = null;
        selectedVersionId.value = null;
      }
      documentsContainer(currentDocumentType.value?.name ?? '').reload();
    }
    return result;
  }

  Future<CmsDocument?> updateDocumentData(Map<String, dynamic> data) async {
    final documentId = selectedDocumentId.value;
    if (documentId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocumentData(documentId, data);
      documentsContainer(currentDocumentType.value?.name ?? '').reload();
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

      final docId = selectedDocumentId.value;
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

      final docId = selectedDocumentId.value;
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

      final docId = selectedDocumentId.value;
      if (docId != null) {
        versionsContainer(docId).reload();
      }
    }
    return result;
  }

  // ============================================================
  // Search
  // ============================================================

  void setSearchQuery(String? query) {
    searchQuery.value = query;
  }

  // ============================================================
  // Refresh Methods
  // ============================================================

  void refreshDocuments() {
    final docType = currentDocumentType.value?.name;
    if (docType != null) {
      documentsContainer(docType).reload();
    }
  }

  void refreshVersions() {
    final docId = selectedDocumentId.value;
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
    currentDocumentType.dispose();
    currentDocumentTypeSlug.dispose();
    currentDocumentId.dispose();
    currentVersionId.dispose();
    selectedVersionId.dispose();
    selectedDocumentId.dispose();
    searchQuery.dispose();
    sidebarCollapsed.dispose();
    documentListVisible.dispose();
    isSaving.dispose();
  }
}

