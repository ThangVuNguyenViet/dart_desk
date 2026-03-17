import 'package:signals/signals_flutter.dart';

import '../../../data/cms_data_source.dart';
import '../../../data/models/cms_document.dart';

/// ViewModel for managing a single document's state.
///
/// This ViewModel handles document-level operations including:
/// - Document metadata (title, slug)
/// - Document data updates via CRDT
/// - Version management
class CmsDocumentViewModel {
  final CmsDataSource dataSource;

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

  CmsDocumentViewModel(this.dataSource);

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
    documentId.dispose();
    title.dispose();
    slug.dispose();
    isDefault.dispose();
    isSaving.dispose();
    editedData.dispose();
  }
}
