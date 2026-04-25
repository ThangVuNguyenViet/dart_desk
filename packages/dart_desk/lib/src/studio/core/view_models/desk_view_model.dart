import 'package:collection/collection.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/desk_data_source.dart';
import '../../../data/models/desk_document.dart';
import '../../../data/models/document_version.dart';
import '../../../extensions/awaitable_future_signal.dart';
import '../signals/mutation_signal.dart';

class DeskViewModel {
  final DataSource dataSource;

  /// The registered document types (injected from coordinator/app config).
  final List<DocumentType> documentTypes;

  // ============================================================
  // Route Param Signals (written by StudioShellScreen._onRouteChanged)
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
    (String documentType) => AwaitableFutureSignal(
      () => dataSource.getDocuments(documentType, limit: 200),
      debugLabel: 'documents',
    ),
    cache: true,
  );

  late final versionsContainer = SignalContainer(
    (String documentId) => AwaitableFutureSignal(
      () => dataSource.getDocumentVersions(documentId),
      debugLabel: 'versions',
    ),
    cache: true,
  );

  late final documentDataContainer = SignalContainer(
    (String versionId) => AwaitableFutureSignal(
      () => _fetchVersionWithData(versionId),
      debugLabel: 'documentData',
    ),
    cache: true,
  );

  // ============================================================
  // Constructor
  // ============================================================

  DeskViewModel({required this.dataSource, required this.documentTypes});

  // ============================================================
  // Internal Fetch Methods
  // ============================================================

  /// Fetches a document version with its data.
  ///
  /// `getDocumentVersion` returns metadata only (no data field).
  /// This method also fetches the version data and combines them.
  Future<DocumentVersion?> _fetchVersionWithData(String versionId) async {
    final results = await Future.wait([
      dataSource.getDocumentVersion(versionId),
      dataSource.getDocumentVersionData(versionId),
    ]);
    final version = results[0] as DocumentVersion?;
    final data = results[1] as Map<String, dynamic>?;
    if (version == null) return null;
    return version.copyWith(data: data);
  }

  final selectedDocumentId = Signal<String?>(
    null,
    debugLabel: 'selectedDocumentId',
  );
  final selectedVersionId = Signal<String?>(
    null,
    debugLabel: 'selectedVersionId',
  );

  // ============================================================
  // Document Operations
  // ============================================================

  Future<String?> suggestSlug(String title) async {
    final docType = currentDocumentType.value;
    if (docType == null) return null;
    return await dataSource.suggestSlug(title, docType.name);
  }

  late final createDocument =
      mutationSignal<
        DeskDocument?,
        ({
          String title,
          Map<String, dynamic> data,
          String? slug,
          bool isDefault,
          bool publish,
        })
      >((args) async {
        final docType = currentDocumentType.value;
        if (docType == null) return null;

        final document = await dataSource.createDocument(
          docType.name,
          args.title,
          args.data,
          slug: args.slug,
          isDefault: args.isDefault,
        );

        selectedDocumentId.value = document.id;

        final versions = await dataSource.getDocumentVersions(document.id!);
        if (versions.versions.isNotEmpty) {
          final versionId = versions.versions.first.id!;
          selectedVersionId.value = versionId;

          if (args.publish) {
            await dataSource.publishDocumentVersion(versionId);
          }
        }

        documentsContainer(
          currentDocumentType.value?.name ?? '',
        ).awaitableReload();

        return document;
      }, debugLabel: 'createDocument');

  late final setDefaultDocument = mutationSignal<DeskDocument?, String>((
    documentId,
  ) async {
    final docTypeName = currentDocumentType.value?.name ?? '';
    final updated = await dataSource.setDefaultDocument(
      docTypeName,
      documentId,
    );
    documentsContainer(docTypeName).awaitableReload();
    return updated;
  }, debugLabel: 'setDefaultDocument');

  late final deleteDocument =
      mutationSignal<({bool deleted, DeskDocument? newDefault}), String>((
        documentId,
      ) async {
        final docTypeName = currentDocumentType.value?.name ?? '';

        // Snapshot whether this doc is currently the default
        final snapshot = untracked(() => documentsContainer(docTypeName).value);
        final wasDefault = snapshot.map(
          data: (d) =>
              d.documents.any((doc) => doc.id == documentId && doc.isDefault),
          loading: () => false,
          error: (_, _) => false,
        );

        final result = await dataSource.deleteDocument(documentId);
        if (!result) return (deleted: false, newDefault: null);

        if (selectedDocumentId.value == documentId) {
          selectedDocumentId.value = null;
          selectedVersionId.value = null;
        }
        await documentsContainer(docTypeName).awaitableReload();

        if (wasDefault) {
          final refreshed = untracked(
            () => documentsContainer(docTypeName).value,
          );
          final newDefault = refreshed.map(
            data: (d) => d.documents.firstWhereOrNull((doc) => doc.isDefault),
            loading: () => null,
            error: (_, _) => null,
          );
          return (deleted: true, newDefault: newDefault);
        }

        return (deleted: true, newDefault: null);
      }, debugLabel: 'deleteDocument');

  late final saveDocumentData =
      mutationSignal<
        DeskDocument?,
        ({String documentId, Map<String, dynamic> data})
      >((args) async {
        final result = await dataSource.updateDocumentData(
          args.documentId,
          args.data,
        );

        documentsContainer(
          currentDocumentType.value?.name ?? '',
        ).awaitableReload();

        return result;
      }, debugLabel: 'saveDocumentData');

  late final publishDocumentData =
      mutationSignal<
        DeskDocument?,
        ({String documentId, Map<String, dynamic> data})
      >((args) async {
        final result = await dataSource.updateDocumentData(
          args.documentId,
          args.data,
        );

        final newVersion = await dataSource.createDocumentVersion(
          args.documentId,
          changeLog: 'Saved and published',
        );
        await dataSource.publishDocumentVersion(newVersion.id!);
        selectedVersionId.value = newVersion.id;

        documentsContainer(
          currentDocumentType.value?.name ?? '',
        ).awaitableReload();

        versionsContainer(args.documentId).awaitableReload();
        final versionId = selectedVersionId.value;
        if (versionId != null) {
          documentDataContainer(versionId).awaitableReload();
        }

        return result;
      }, debugLabel: 'publishDocumentData');

  // ============================================================
  // Version Status Operations
  // ============================================================

  late final publishVersion = mutationSignal<DocumentVersion?, String>((
    versionId,
  ) async {
    final result = await dataSource.publishDocumentVersion(versionId);

    final docId = selectedDocumentId.value;
    if (docId != null) {
      versionsContainer(docId).awaitableReload();
    }
    documentDataContainer(versionId).awaitableReload();

    return result;
  }, debugLabel: 'publishVersion');

  late final archiveVersion = mutationSignal<DocumentVersion?, String>((
    versionId,
  ) async {
    final result = await dataSource.archiveDocumentVersion(versionId);

    final docId = selectedDocumentId.value;
    if (docId != null) {
      versionsContainer(docId).awaitableReload();
    }
    documentDataContainer(versionId).awaitableReload();

    return result;
  }, debugLabel: 'archiveVersion');

  late final deleteVersion = mutationSignal<bool, String>((versionId) async {
    final result = await dataSource.deleteDocumentVersion(versionId);
    if (result) {
      if (selectedVersionId.value == versionId) {
        selectedVersionId.value = null;
      }

      final docId = selectedDocumentId.value;
      if (docId != null) {
        versionsContainer(docId).awaitableReload();
      }
    }
    return result;
  }, debugLabel: 'deleteVersion');

  // ============================================================
  // Refresh Methods
  // ============================================================

  void refreshDocuments() {
    final docType = currentDocumentType.value?.name;
    if (docType != null) {
      documentsContainer(docType).awaitableReload();
    }
  }

  void refreshVersions() {
    final docId = selectedDocumentId.value;
    if (docId != null) {
      versionsContainer(docId).awaitableReload();
    }
  }

  void refreshSelectedData() {
    final versionId = selectedVersionId.value;
    if (versionId != null) {
      documentDataContainer(versionId).awaitableReload();
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
    sidebarCollapsed.dispose();
    documentListVisible.dispose();
  }
}
