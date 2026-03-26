import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';
import '../../../data/models/document_version.dart';
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
  late final selectedDocument = FutureSignal<CmsDocument?>(() async {
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

  EffectCleanup? _cleanup;

  CmsDocumentViewModel(this.dataSource);

  /// Sets up a reactive effect that watches [cmsVM.selectedDocumentId].
  /// When it changes, syncs [documentId], resets [editedData], and
  /// auto-loads the latest version data.
  void listenTo(CmsViewModel cmsVM) {
    _cleanup = effect(() {
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
    });
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
    } catch (_) {
      // Silently ignore — editor will show empty state
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
    _cleanup?.call();
    documentId.dispose();
    title.dispose();
    slug.dispose();
    isDefault.dispose();
    isSaving.dispose();
    editedData.dispose();
  }
}
