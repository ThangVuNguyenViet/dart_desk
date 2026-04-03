import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../extensions/awaitable_future_signal.dart';
import 'cms_view_model.dart';

/// ViewModel for managing a single document's state.
///
/// This ViewModel handles document-level operations including:
/// - Document metadata (title, slug)
/// - Document data updates via CRDT
/// - Version management
class CmsDocumentViewModel {
  final DataSource dataSource;

  /// Signal for the document ID
  final documentId = Signal<int?>(null, debugLabel: 'documentId');

  /// FutureSignal for the currently selected document
  late final selectedDocument = AwaitableFutureSignal<CmsDocument?>(() async {
    final docId = documentId.value;
    if (docId == null) return null;
    return await dataSource.getDocument(docId);
  }, debugLabel: 'selectedDocument');

  /// Signal for the document title
  final title = Signal<String>('', debugLabel: 'title');

  /// Signal for the document slug
  final slug = Signal<String>('', debugLabel: 'slug');

  /// Signal for whether the document is the default for its type
  final isDefault = Signal<bool>(false, debugLabel: 'isDefault');

  /// Signal for tracking save operations
  final isSaving = Signal<bool>(false, debugLabel: 'isSaving');

  /// Shared edited data signal — written by the editor, read by the preview.
  final editedData = MapSignal<String, dynamic>({}, debugLabel: 'editedData');

  final List<EffectCleanup> _cleanups = [];

  CmsDocumentViewModel(this.dataSource);

  /// Sets up reactive effects that watch [cmsVM.selectedDocumentId] and
  /// [cmsVM.currentDocumentType].
  ///
  /// Effect 1: syncs [documentId], resets [editedData], and auto-loads the
  /// latest version data whenever the selected document changes.
  ///
  /// Effect 2: seeds [editedData] with the document type's default values
  /// whenever the type or document changes and [editedData] is empty.
  void listenTo(CmsViewModel cmsVM) {
    _cleanups.add(
      effect(() {
        final newDocId = cmsVM.selectedDocumentId.value;
        final currentDocId = untracked(() => documentId.value);

        if (currentDocId != newDocId) {
          batch(() {
            documentId.value = newDocId;
            editedData.value = {};
          });

          if (newDocId != null) {
            _autoLoadLatestData(cmsVM, newDocId);
          }
        }
      }),
    );

    _cleanups.add(
      effect(() {
        final docType = cmsVM.currentDocumentType.value;
        final docId =
            documentId.value; // tracked — re-run when document changes
        final defaults = docType?.defaultValue?.toMap() ?? {};
        if (docId == null) {
          // New-document form: always seed current type's defaults, even if
          // editedData already has stale data from a previous type.
          if (defaults.isNotEmpty) editedData.value = defaults;
        } else if (untracked(() => editedData.value.isEmpty) &&
            defaults.isNotEmpty) {
          // Document selected but autoLoad hasn't populated editedData yet.
          editedData.value = defaults;
        }
      }),
    );
  }

  /// Fetches versions for a document and auto-loads the latest data.
  /// Sets [editedData] from the document's active version data and
  /// updates [cmsVM.selectedVersionId].
  Future<void> _autoLoadLatestData(CmsViewModel cmsVM, int docId) async {
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
          editedData.value = Map<String, dynamic>.from(docData);
        }

        // Set version ID after editedData so the editor's early-return
        // path (editedData.isNotEmpty) prevents the loading→form transition.
        cmsVM.selectedVersionId.value = versionId;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[autoLoad] docId=$docId ERROR: $e');
    }
  }

  /// Updates the document metadata (title, slug, isDefault).
  ///
  /// Returns the updated document, or null if update failed.
  Future<CmsDocument?> updateMetadata({
    String? newTitle,
    String? newSlug,
    bool? newIsDefault,
  }) async {
    final docId = documentId.value;
    if (docId == null) return null;

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocument(
        docId,
        title: newTitle,
        slug: newSlug,
        isDefault: newIsDefault,
      );

      if (result != null) {
        // Update local signals
        if (newTitle != null) title.value = newTitle;
        if (newSlug != null) slug.value = newSlug;
        if (newIsDefault != null) isDefault.value = newIsDefault;
      }

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  /// Updates the document data using CRDT operations.
  ///
  /// [updates] - Map of field updates (only changed fields)
  ///
  /// Returns the updated document.
  Future<CmsDocument> updateData(Map<String, dynamic> updates) async {
    final docId = documentId.value;
    if (docId == null) {
      throw Exception('Cannot update data: documentId is null');
    }

    isSaving.value = true;
    try {
      final result = await dataSource.updateDocumentData(docId, updates);

      return result;
    } finally {
      isSaving.value = false;
    }
  }

  /// Deletes the document.
  ///
  /// Returns true if deleted successfully.
  Future<bool> delete() async {
    final docId = documentId.value;
    if (docId == null) return false;

    return await dataSource.deleteDocument(docId);
  }

  /// Loads a document by ID and updates the signals
  Future<CmsDocument?> loadDocument(int id) async {
    documentId.value = id;

    final doc = await dataSource.getDocument(id);
    if (doc != null) {
      title.value = doc.title;
      slug.value = doc.slug ?? '';
      isDefault.value = doc.isDefault;
    }

    return doc;
  }

  /// Disposes all signals
  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
    documentId.dispose();
    title.dispose();
    slug.dispose();
    isDefault.dispose();
    isSaving.dispose();
    editedData.dispose();
  }
}
