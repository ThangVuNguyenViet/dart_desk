// End-to-end correctness test for the save / publish redesign.
//
// Verifies the public-read-leak bug is fixed:
//   • After autosave, the draft is updated but the public snapshot is NOT.
//   • After Publish, the public snapshot reflects the new content.
//   • After a subsequent draft edit (autosave), the public snapshot stays at
//     the content from the PREVIOUS publish — no leak.
//
// This is a ViewModel / mock-state flow test, not a golden test.
// No Docker required; runs natively on macOS.

import 'dart:async';
import 'dart:io';

import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------------------------------------------------------------------------
// Widget helper
// ---------------------------------------------------------------------------

Widget _buildEditorApp({required MockDataSource dataSource}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: [allFieldsDocumentType],
          child: Builder(
            builder: (context) {
              GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                  allFieldsDocumentType.name;
              return DeskDocumentEditor(
                fields: allFieldsDocumentType.fields,
                title: allFieldsDocumentType.title,
              );
            },
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockDataSource dataSource;

  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  setUp(() {
    dataSource = MockDataSource()..seedDefaults();
  });

  // =========================================================================
  // Core four-assertion flow test
  //
  // 1. After typing + 1 s autosave + pumpAndSettle:
  //    - Draft (activeVersionData) has the new value.
  //    - Public snapshot (getPublishedData) does NOT have the new value.
  //    - Status pill shows "Unpublished changes".
  //
  // 2. After Publish:
  //    - Public snapshot returns the new value.
  //    - Status pill shows "Saved" (no unpublished changes remain).
  //
  // 3. After a second round of typing + autosave:
  //    - Draft has the second value.
  //    - Public snapshot still holds the FIRST published value (no leak).
  //    - Status pill shows "Unpublished changes" again.
  // =========================================================================

  testWidgets(
    'autosave debounces; publish flips public read; subsequent edits do not leak',
    (tester) async {
      // -----------------------------------------------------------------------
      // Setup: pick the first document and mount the editor
      // -----------------------------------------------------------------------
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(_buildEditorApp(dataSource: dataSource));
      await tester.pumpAndSettle();

      // Wire up ViewModels to the document under test.
      final deskVM = GetIt.I<DeskViewModel>();
      final docVM = GetIt.I<DeskDocumentViewModel>();

      deskVM.selectedDocumentId.value = doc.id!;
      docVM.documentId.value = doc.id!;
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------------
      // Phase 1 — edit title field → autosave fires → public read unchanged
      // -----------------------------------------------------------------------
      const firstDraftValue = 'Hello world draft';

      // Simulate a field edit (mirrors what DeskForm.onFieldChanged does).
      docVM.editedData['string_field'] = firstDraftValue;
      docVM.isDirty.value = true;

      // Advance past the 1-second autosave debounce.
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));
      await tester.pumpAndSettle();

      // Draft is saved.
      expect(
        docVM.isDirty.value,
        isFalse,
        reason: 'isDirty must be false after autosave completes',
      );

      // Draft data reflects the edit.
      final draftDoc1 = await dataSource.getDocument(doc.id!);
      expect(
        draftDoc1?.activeVersionData?['string_field'],
        firstDraftValue,
        reason: 'activeVersionData must contain the autosaved value',
      );

      // Assertion 1: public snapshot does NOT have the new value yet.
      final publicBefore = await dataSource.getPublishedData(doc.id!);
      expect(
        publicBefore,
        isNull,
        reason:
            'getPublishedData must return null — document has never been published',
      );

      // Assertion 1b: status pill shows "Unpublished changes".
      // After autosave completes, crdtHlc > snapshotHlc (no published version
      // exists yet), so hasUnpublishedChanges = true.
      // Reload containers so the computed signal picks up the fresh crdtHlc.
      deskVM.selectedDocumentContainer(doc.id!).awaitableReload();
      deskVM.versionsContainer(doc.id!).awaitableReload();
      await tester.pumpAndSettle();

      expect(
        find.text('Unpublished changes'),
        findsNothing, // CmsStatusPill is not in this minimal app build
        // NOTE: CmsStatusPill is not included in the _buildEditorApp helper.
        // We verify hasUnpublishedChanges via the signal directly.
      );
      expect(
        deskVM.hasUnpublishedChanges.value,
        isTrue,
        reason:
            'hasUnpublishedChanges must be true after autosave with no published version',
      );

      // -----------------------------------------------------------------------
      // Phase 2 — Publish → public snapshot flips
      // -----------------------------------------------------------------------
      await tester.tap(find.byKey(const ValueKey('publish_document_button')));
      await tester.pumpAndSettle();

      // Assertion 2: public snapshot now contains the published value.
      final publicAfterPublish = await dataSource.getPublishedData(doc.id!);
      expect(
        publicAfterPublish,
        isNotNull,
        reason: 'getPublishedData must return data after first publish',
      );
      expect(
        publicAfterPublish!['string_field'],
        firstDraftValue,
        reason:
            'published snapshot must equal the value that was in the draft at publish time',
      );

      // hasUnpublishedChanges must be false now (snapshot HLC == crdtHlc).
      await tester.pumpAndSettle();
      expect(
        deskVM.hasUnpublishedChanges.value,
        isFalse,
        reason: 'hasUnpublishedChanges must be false immediately after publish',
      );

      // -----------------------------------------------------------------------
      // Phase 3 — post-publish edit → draft changes; public snapshot stays
      // -----------------------------------------------------------------------
      const secondDraftValue = 'Draft only — should not be public';

      docVM.editedData['string_field'] = secondDraftValue;
      docVM.isDirty.value = true;

      // Advance past the autosave debounce.
      await tester.pump(const Duration(seconds: 1, milliseconds: 100));
      await tester.pumpAndSettle();

      expect(
        docVM.isDirty.value,
        isFalse,
        reason: 'isDirty must be false after the second autosave',
      );

      // Draft now has the new value.
      final draftDoc2 = await dataSource.getDocument(doc.id!);
      expect(
        draftDoc2?.activeVersionData?['string_field'],
        secondDraftValue,
        reason: 'activeVersionData must hold the second edit after autosave',
      );

      // Assertion 3: public snapshot still holds the FIRST published value.
      final publicAfterSecondEdit = await dataSource.getPublishedData(doc.id!);
      expect(
        publicAfterSecondEdit!['string_field'],
        firstDraftValue,
        reason:
            'getPublishedData must NOT be updated by a draft autosave — '
            'this is the core public-read-leak bug fix',
      );

      // hasUnpublishedChanges is true again because crdtHlc > snapshotHlc.
      deskVM.selectedDocumentContainer(doc.id!).awaitableReload();
      deskVM.versionsContainer(doc.id!).awaitableReload();
      await tester.pumpAndSettle();
      expect(
        deskVM.hasUnpublishedChanges.value,
        isTrue,
        reason:
            'hasUnpublishedChanges must be true again after the post-publish draft edit',
      );
    },
  );

  // =========================================================================
  // Focused unit assertion — getPublishedData is null before any publish
  // =========================================================================

  test('getPublishedData returns null before document has ever been published',
      () async {
    final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
    final doc = docs.documents.first;

    await dataSource.updateDocumentData(
      doc.id!,
      {'string_field': 'unpublished edit'},
    );

    final publicData = await dataSource.getPublishedData(doc.id!);
    expect(
      publicData,
      isNull,
      reason:
          'No publish call has been made — public snapshot must be absent',
    );
  });

  // =========================================================================
  // Focused unit assertion — publishCurrentVersion snapshots correctly
  // =========================================================================

  test(
    'publishCurrentVersion freezes snapshot; subsequent updateDocumentData does not mutate it',
    () async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      // Write a value and publish.
      await dataSource.updateDocumentData(
        doc.id!,
        {'string_field': 'published content'},
      );
      await dataSource.publishCurrentVersion(doc.id!);

      final snapshotAfterPublish = await dataSource.getPublishedData(doc.id!);
      expect(snapshotAfterPublish!['string_field'], 'published content');

      // Now write a new draft value without publishing.
      await dataSource.updateDocumentData(
        doc.id!,
        {'string_field': 'new draft — should not be public'},
      );

      // Active draft reflects the new edit.
      final draftDoc = await dataSource.getDocument(doc.id!);
      expect(
        draftDoc!.activeVersionData!['string_field'],
        'new draft — should not be public',
      );

      // Public snapshot is unchanged.
      final snapshotAfterDraft = await dataSource.getPublishedData(doc.id!);
      expect(
        snapshotAfterDraft!['string_field'],
        'published content',
        reason:
            'updateDocumentData must not mutate the published snapshot — '
            'this is the model-split correctness guarantee',
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Minimal HTTP override so Image.network calls don't throw in tests
// ---------------------------------------------------------------------------

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _installScreenGoldenMocksClient();
}

// Reuse the mechanism from screen_test_helpers (no dependency on the internal
// helper so we keep test isolation) — just delegate to a simple no-op stub.
HttpClient _installScreenGoldenMocksClient() {
  return _NoOpHttpClient();
}

class _NoOpHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _NoOpRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _NoOpRequest();
  @override
  Future<HttpClientRequest> headUrl(Uri url) async => _NoOpRequest();
  @override
  void close({bool force = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _NoOpHeaders();
  @override
  Future<HttpClientResponse> close() async => _NoOpResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpResponse implements HttpClientResponse {
  static final _bytes = <int>[];
  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => 0;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream<List<int>>.fromIterable([_bytes]).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
  @override
  HttpHeaders get headers => _NoOpHeaders();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
  @override
  String? value(String name) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
