import 'dart:typed_data';

import 'package:dart_desk/src/data/desk_data_source.dart';
import 'package:dart_desk/src/data/models/document_version.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_desk/src/data/models/document_list.dart';
import 'package:dart_desk/src/data/models/media_asset.dart';
import 'package:dart_desk/src/data/models/media_page.dart';
import 'package:dart_desk/src/data/models/image_types.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Minimal helpers
// ---------------------------------------------------------------------------

DeskDocument _mkDoc({String? id, String? crdtHlc}) {
  return DeskDocument(
    id: id ?? 'doc-1',
    clientId: 'client-1',
    documentType: 'article',
    title: 'Test Doc',
    crdtHlc: crdtHlc,
  );
}

DocumentVersion _mkVersion({
  required int versionNumber,
  required DocumentVersionStatus status,
  String? snapshotHlc,
}) {
  return DocumentVersion(
    id: 'ver-$versionNumber',
    documentId: 'doc-1',
    versionNumber: versionNumber,
    status: status,
    snapshotHlc: snapshotHlc,
    createdAt: DateTime.now(),
  );
}

// ---------------------------------------------------------------------------
// Minimal fake DataSource
// ---------------------------------------------------------------------------

class _FakeDataSource implements DataSource {
  DeskDocument? document;
  DocumentVersionList _versionList = const DocumentVersionList(
    versions: [],
    total: 0,
    page: 1,
    pageSize: 20,
  );

  List<DocumentVersion> get versions => _versionList.versions;
  set versions(List<DocumentVersion> v) {
    _versionList = DocumentVersionList(
      versions: v,
      total: v.length,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<DeskDocument?> getDocument(String documentId) async => document;

  @override
  Future<DocumentVersionList> getDocumentVersions(
    String documentId, {
    int limit = 20,
    int offset = 0,
  }) async =>
      _versionList;

  // --- stubs for the rest of the interface ---

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async =>
      const DocumentList(documents: [], total: 0, page: 1, pageSize: 20);

  @override
  Future<DeskDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DeskDocument?> updateDocument(
    String documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async =>
      throw UnimplementedError();

  @override
  Future<bool> deleteDocument(String documentId) async =>
      throw UnimplementedError();

  @override
  Future<DeskDocument> setDefaultDocument(
    String documentTypeSlug,
    String documentId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<String> suggestSlug(String title, String documentType) async =>
      throw UnimplementedError();

  @override
  Future<List<String>> getDocumentTypes() async => throw UnimplementedError();

  @override
  Future<DocumentVersion?> getDocumentVersion(String versionId) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> getDocumentVersionData(
    String versionId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<DocumentVersion> createDocumentVersion(
    String documentId, {
    String status = 'draft',
    String? changeLog,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DocumentVersion?> publishDocumentVersion(String versionId) async =>
      throw UnimplementedError();

  @override
  Future<DocumentVersion> publishCurrentVersion(String documentId) async =>
      throw UnimplementedError();

  @override
  Future<DocumentVersion?> archiveDocumentVersion(String versionId) async =>
      throw UnimplementedError();

  @override
  Future<DeskDocument> restoreDocumentVersion(
    String documentId,
    String versionId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<bool> deleteDocumentVersion(String versionId) async =>
      throw UnimplementedError();

  @override
  Future<MediaAsset> uploadImage(String fileName, Uint8List fileData) async =>
      throw UnimplementedError();

  @override
  Future<MediaAsset> uploadFile(String fileName, Uint8List fileData) async =>
      throw UnimplementedError();

  @override
  Future<bool> deleteMedia(String assetId) async => throw UnimplementedError();

  @override
  Future<MediaAsset?> getMediaAsset(String assetId) async =>
      throw UnimplementedError();

  @override
  Future<MediaPage> listMedia({
    String? search,
    MediaTypeFilter? type,
    MediaSort sort = MediaSort.dateDesc,
    int limit = 50,
    int offset = 0,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MediaAsset> updateMediaAsset(
    String assetId, {
    String? fileName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<int> getMediaUsageCount(String assetId) async =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeskViewModel', () {
    group('hasUnpublishedChanges', () {
      /// Waits for both async containers to settle by polling until neither
      /// is in the loading state (or until [maxAttempts] are exhausted).
      Future<void> waitForContainers(DeskViewModel vm, String docId) async {
        for (var i = 0; i < 50; i++) {
          // Accessing the value triggers the FutureSignal to start loading.
          final versionsLoading = vm.versionsContainer(docId).value.isLoading;
          final docLoading = vm.selectedDocumentContainer(docId).value.isLoading;
          if (!versionsLoading && !docLoading) return;
          await pumpEventQueue();
        }
      }

      test(
        'is true when document.crdtHlc > latest published snapshotHlc',
        () async {
          final fakeDS = _FakeDataSource()
            ..document = _mkDoc(id: 'doc-1', crdtHlc: 'h-200')
            ..versions = [
              _mkVersion(
                versionNumber: 1,
                status: DocumentVersionStatus.published,
                snapshotHlc: 'h-100',
              ),
            ];

          final vm = DeskViewModel(
            dataSource: fakeDS,
            documentTypes: [],
          );

          vm.selectedDocumentId.value = 'doc-1';
          await waitForContainers(vm, 'doc-1');

          expect(vm.hasUnpublishedChanges.value, isTrue);
        },
      );

      test(
        'is false when document.crdtHlc == latest published snapshotHlc',
        () async {
          final fakeDS = _FakeDataSource()
            ..document = _mkDoc(id: 'doc-1', crdtHlc: 'h-200')
            ..versions = [
              _mkVersion(
                versionNumber: 1,
                status: DocumentVersionStatus.published,
                snapshotHlc: 'h-100',
              ),
              _mkVersion(
                versionNumber: 2,
                status: DocumentVersionStatus.published,
                snapshotHlc: 'h-200',
              ),
            ];

          final vm = DeskViewModel(
            dataSource: fakeDS,
            documentTypes: [],
          );

          vm.selectedDocumentId.value = 'doc-1';
          await waitForContainers(vm, 'doc-1');

          expect(vm.hasUnpublishedChanges.value, isFalse);
        },
      );

      test(
        'flips from true to false after versions container is reloaded with caught-up snapshotHlc',
        () async {
          final fakeDS = _FakeDataSource()
            ..document = _mkDoc(id: 'doc-1', crdtHlc: 'h-200')
            ..versions = [
              _mkVersion(
                versionNumber: 1,
                status: DocumentVersionStatus.published,
                snapshotHlc: 'h-100',
              ),
            ];

          final vm = DeskViewModel(
            dataSource: fakeDS,
            documentTypes: [],
          );

          vm.selectedDocumentId.value = 'doc-1';
          await waitForContainers(vm, 'doc-1');

          expect(vm.hasUnpublishedChanges.value, isTrue);

          // Simulate a successful publish: new version with snapshotHlc == crdtHlc.
          fakeDS.versions = [
            _mkVersion(
              versionNumber: 1,
              status: DocumentVersionStatus.published,
              snapshotHlc: 'h-100',
            ),
            _mkVersion(
              versionNumber: 2,
              status: DocumentVersionStatus.published,
              snapshotHlc: 'h-200',
            ),
          ];
          vm.versionsContainer('doc-1').awaitableReload();
          await waitForContainers(vm, 'doc-1');

          expect(vm.hasUnpublishedChanges.value, isFalse);
        },
      );

      test('is true when there are no published versions yet', () async {
        final fakeDS = _FakeDataSource()
          ..document = _mkDoc(id: 'doc-1', crdtHlc: 'h-100')
          ..versions = [
            _mkVersion(
              versionNumber: 1,
              status: DocumentVersionStatus.draft,
              snapshotHlc: null,
            ),
          ];

        final vm = DeskViewModel(
          dataSource: fakeDS,
          documentTypes: [],
        );

        vm.selectedDocumentId.value = 'doc-1';
        await waitForContainers(vm, 'doc-1');

        expect(vm.hasUnpublishedChanges.value, isTrue);
      });

      test('is false when no document is selected', () {
        final vm = DeskViewModel(
          dataSource: _FakeDataSource(),
          documentTypes: [],
        );

        // No selectedDocumentId set.
        expect(vm.hasUnpublishedChanges.value, isFalse);
      });
    });

    test('saveDocumentData mutation no longer exists on DeskViewModel', () {
      final vm = DeskViewModel(
        dataSource: _FakeDataSource(),
        documentTypes: [],
      );
      // The field was removed — accessing it via `dynamic` should throw NoSuchMethodError.
      expect(
        () => (vm as dynamic).saveDocumentData,
        throwsNoSuchMethodError,
      );
    });

    test('publishDocumentData mutation no longer exists on DeskViewModel', () {
      final vm = DeskViewModel(
        dataSource: _FakeDataSource(),
        documentTypes: [],
      );
      expect(
        () => (vm as dynamic).publishDocumentData,
        throwsNoSuchMethodError,
      );
    });

    test('publishCurrentDraft mutation exists', () {
      final vm = DeskViewModel(
        dataSource: _FakeDataSource(),
        documentTypes: [],
      );
      expect(vm.publishCurrentDraft, isNotNull);
    });

    test('restoreVersion mutation exists', () {
      final vm = DeskViewModel(
        dataSource: _FakeDataSource(),
        documentTypes: [],
      );
      expect(vm.restoreVersion, isNotNull);
    });
  });
}
