import 'package:signals/signals_flutter.dart';

import '../../../data/desk_data_source.dart';
import '../../../data/models/desk_document.dart';
import '../../../extensions/awaitable_future_signal.dart';
import '../signals/mutation_signal.dart';
import 'desk_view_model.dart';

/// ViewModel for managing a single document's state.
///
/// This ViewModel handles document-level operations including:
/// - Document metadata (title, slug)
/// - Document data updates via CRDT
/// - Version management
class DeskDocumentViewModel {
  final DataSource dataSource;

  /// Signal for the document ID
  final documentId = Signal<String?>(null, debugLabel: 'documentId');

  /// FutureSignal for the currently selected document
  late final selectedDocument = AwaitableFutureSignal<DeskDocument?>(() async {
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

  /// Shared edited data signal — written by the editor, read by the preview.
  final editedData = MapSignal<String, dynamic>({}, debugLabel: 'editedData');

  final List<EffectCleanup> _cleanups = [];

  DeskDocumentViewModel(this.dataSource);

  /// Sets up reactive effects that watch [deskVM.selectedDocumentId] and
  /// [deskVM.currentDocumentType].
  ///
  /// Effect 1: syncs [documentId], resets [editedData], and auto-loads the
  /// latest version data whenever the selected document changes.
  ///
  /// Effect 2: seeds [editedData] with the document type's default values
  /// whenever the type or document changes and [editedData] is empty.
  void listenTo(DeskViewModel deskVM) {
    _cleanups.add(
      effect(() {
        final newDocId = deskVM.selectedDocumentId.value;
        final currentDocId = untracked(() => documentId.value);

        if (currentDocId != newDocId) {
          batch(() {
            documentId.value = newDocId;
            editedData.value = {};
          });

          if (newDocId != null) {
            _autoLoadLatestData(deskVM, newDocId);
          }
        }
      }),
    );

    _cleanups.add(
      effect(() {
        final docType = deskVM.currentDocumentType.value;
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
  /// updates [deskVM.selectedVersionId].
  Future<void> _autoLoadLatestData(DeskViewModel deskVM, String docId) async {
    try {
      final versions = await dataSource.getDocumentVersions(docId);
      if (editedData.disposed) return;
      if (versions.versions.isNotEmpty) {
        final versionId = versions.versions.first.id!;

        // Use the document's activeVersionData which reflects the latest
        // CRDT-merged state, rather than getDocumentVersionData which only
        // reconstructs state up to the version's snapshot HLC.
        final doc = await dataSource.getDocument(docId);
        if (editedData.disposed) return;
        final docData = doc?.activeVersionData;
        if (docData != null && docData.isNotEmpty) {
          editedData.value = Map<String, dynamic>.from(docData);
        }

        // Set version ID after editedData so the editor's early-return
        // path (editedData.isNotEmpty) prevents the loading→form transition.
        deskVM.selectedVersionId.value = versionId;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[autoLoad] docId=$docId ERROR: $e');
    }
  }

  /// Updates the document metadata (title, slug, isDefault).
  late final updateMetadata =
      mutationSignal<
        DeskDocument?,
        ({
          String documentId,
          String? newTitle,
          String? newSlug,
          bool? newIsDefault,
        })
      >((args) async {
        final result = await dataSource.updateDocument(
          args.documentId,
          title: args.newTitle,
          slug: args.newSlug,
          isDefault: args.newIsDefault,
        );

        if (result != null && args.documentId == documentId.value) {
          // Update local signals if we're still on the same document
          if (args.newTitle != null) title.value = args.newTitle!;
          if (args.newSlug != null) slug.value = args.newSlug!;
          if (args.newIsDefault != null) isDefault.value = args.newIsDefault!;
        }

        return result;
      }, debugLabel: 'updateMetadata');

  /// Updates the document data using CRDT operations.
  late final updateData =
      mutationSignal<
        DeskDocument,
        ({String documentId, Map<String, dynamic> updates})
      >((args) async {
        final result = await dataSource.updateDocumentData(
          args.documentId,
          args.updates,
        );

        return result;
      }, debugLabel: 'updateData');

  /// Deletes the document.
  late final delete = mutationSignal<bool, String>((docId) async {
    return await dataSource.deleteDocument(docId);
  }, debugLabel: 'delete');

  /// Loads a document by ID and updates the signals
  Future<DeskDocument?> loadDocument(String id) async {
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
    editedData.dispose();
  }
}
