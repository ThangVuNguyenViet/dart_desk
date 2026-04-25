import 'dart:async';
import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

// ---------------------------------------------------------------------------
// Slow data source — lets tests inspect loading state before async completes
// ---------------------------------------------------------------------------

class _HangingDataSource extends MockDataSource {
  // Never completes; used to freeze the loading state for inspection.
  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) {
    return Completer<DeskDocument>().future;
  }
}

// ---------------------------------------------------------------------------
// Test widget builders
// ---------------------------------------------------------------------------

Widget _buildEditorApp({
  required MockDataSource dataSource,
  required DocumentType docType,
  void Function(BuildContext)? onBuilt,
}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: [docType],
          child: Builder(
            builder: (context) {
              GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                  docType.name;
              onBuilt?.call(context);
              return DeskDocumentEditor(
                fields: docType.fields,
                title: docType.title,
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _buildDocumentListApp({
  required MockDataSource dataSource,
  required DocumentType docType,
}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: [docType],
          child: Builder(
            builder: (context) {
              GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                  docType.name;
              return DeskDocumentListView(
                selectedDocumentType: docType,
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
    HttpOverrides.global = FakeHttpOverrides();
    initTestPngBytes();
  });

  setUp(() {
    dataSource = MockDataSource();
  });

  // =========================================================================
  // Bug 1: editedData is NOT cleared after save
  //
  // Before the fix: _performSave called `editedData.value = {}` after saving,
  // which caused the editor to fall back to stale version snapshot data and
  // made focused text fields revert to old values.
  // After the fix: only `isDirty` is cleared; `editedData` keeps its values.
  // =========================================================================

  group('Bug 1: editedData retained after save', () {
    testWidgets('editedData keeps its value after Save completes', (
      tester,
    ) async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            // Seed editedData first so the defaults effect won't overwrite it.
            docVM.editedData.value = {'string_field': 'user edited value'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      // Save button is visible because isDirty = true.
      expect(find.byKey(const ValueKey('save_document_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_document_button')));
      await tester.pumpAndSettle();

      final docVM = GetIt.I<DeskDocumentViewModel>();

      // editedData must NOT be cleared — the editor should keep showing the
      // saved value rather than reverting to defaults or an empty state.
      expect(
        docVM.editedData.value,
        isNotEmpty,
        reason: 'editedData must not be cleared after save',
      );
      expect(
        docVM.editedData['string_field'],
        'user edited value',
        reason: 'editedData must retain the value that was saved',
      );
    });

    testWidgets('isDirty is false after Save completes', (tester) async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            docVM.editedData.value = {'string_field': 'some change'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('save_document_button')));
      await tester.pumpAndSettle();

      expect(
        GetIt.I<DeskDocumentViewModel>().isDirty.value,
        isFalse,
        reason: 'isDirty must be cleared after a successful save',
      );
    });

    testWidgets('Save/Discard bar disappears after Save (isDirty = false)', (
      tester,
    ) async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            docVM.editedData.value = {'string_field': 'change'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_document_button')));
      await tester.pumpAndSettle();

      // Action bar hidden once isDirty is false.
      expect(
        find.byKey(const ValueKey('save_document_button')),
        findsNothing,
        reason: 'Save button must be hidden when isDirty is false',
      );
    });

    testWidgets('editedData keeps its value after Publish completes', (
      tester,
    ) async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            docVM.editedData.value = {'string_field': 'publish value'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('publish_document_button')));
      await tester.pumpAndSettle();

      final docVM = GetIt.I<DeskDocumentViewModel>();
      expect(
        docVM.editedData.value,
        isNotEmpty,
        reason: 'editedData must not be cleared after publish',
      );
      expect(docVM.editedData['string_field'], 'publish value');
    });
  });

  // =========================================================================
  // Bug 2: Save and Publish loading indicators are independent
  //
  // Before the fix: a single `updateDocumentData` mutation signal was used for
  // both Save and Publish. Its `isLoading` state was applied to BOTH buttons,
  // so clicking Save made the Publish button show a spinner too.
  // After the fix: two separate mutation signals (`saveDocumentData` and
  // `publishDocumentData`) each with their own `isLoading`.
  // =========================================================================

  group('Bug 2: Save and Publish loading are independent', () {
    testWidgets('Save shows spinner only on Save button', (tester) async {
      final hangingDataSource = _HangingDataSource();
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: hangingDataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            docVM.editedData.value = {'string_field': 'check loading'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      // Tap Save — updateDocumentData will hang, so loading stays true.
      await tester.tap(find.byKey(const ValueKey('save_document_button')));
      await tester.pump(); // process tap + start async; don't settle

      final saveBtn = tester.widget<DeskButton>(
        find.byKey(const ValueKey('save_document_button')),
      );
      final publishBtn = tester.widget<DeskButton>(
        find.byKey(const ValueKey('publish_document_button')),
      );

      expect(
        saveBtn.loading,
        isTrue,
        reason: 'Save button must show loading while save is in progress',
      );
      expect(
        publishBtn.loading,
        isFalse,
        reason: 'Publish button must NOT show loading during a save operation',
      );
    });

    testWidgets('Publish shows spinner only on Publish button', (tester) async {
      final hangingDataSource = _HangingDataSource();
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _buildEditorApp(
          dataSource: hangingDataSource,
          docType: allFieldsDocumentType,
          onBuilt: (context) {
            final docVM = GetIt.I<DeskDocumentViewModel>();
            docVM.editedData.value = {'string_field': 'check loading'};
            docVM.documentId.value = doc.id!;
            docVM.isDirty.value = true;
          },
        ),
      );
      await tester.pump();

      // Tap Publish — updateDocumentData will hang.
      await tester.tap(find.byKey(const ValueKey('publish_document_button')));
      await tester.pump();

      final saveBtn = tester.widget<DeskButton>(
        find.byKey(const ValueKey('save_document_button')),
      );
      final publishBtn = tester.widget<DeskButton>(
        find.byKey(const ValueKey('publish_document_button')),
      );

      expect(
        publishBtn.loading,
        isTrue,
        reason: 'Publish button must show loading while publish is in progress',
      );
      expect(
        saveBtn.loading,
        isFalse,
        reason: 'Save button must NOT show loading during a publish operation',
      );
    });
  });

  // =========================================================================
  // Bug 3: Document list status badge reflects the LATEST version status
  //
  // Before the fix: `versions.first` was used; since versions are returned
  // ascending (oldest first), this always returned the initial draft version
  // even after publishing a newer version.
  // After the fix: `versions.last` returns the newest version's status.
  // =========================================================================

  group('Bug 3: Status badge reflects latest version after publish', () {
    testWidgets('badge shows "draft" before any publish', (tester) async {
      // Use "Beta" doc — it starts with a single draft version only.
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final betaDoc = docs.documents.firstWhere(
        (d) => d.title == 'Test Document Beta',
      );

      await tester.pumpWidget(
        _buildDocumentListApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pumpAndSettle();

      // Find the status pill next to the Beta document tile.
      final tile = find.ancestor(
        of: find.text('Test Document Beta'),
        matching: find.byType(Container),
      ).first;

      // Verify the pill says "draft".
      expect(
        find.descendant(of: tile, matching: find.text('draft')),
        findsOneWidget,
        reason: 'Beta doc starts with a draft version — badge must say "draft"',
      );

      // Suppress unused variable warning.
      expect(betaDoc.id, isNotNull);
    });

    testWidgets('badge shows "published" after Publish', (tester) async {
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final betaDoc = docs.documents.firstWhere(
        (d) => d.title == 'Test Document Beta',
      );

      await tester.pumpWidget(
        _buildDocumentListApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pumpAndSettle();

      // Publish the beta document via the ViewModel directly (bypasses UI
      // navigation; tests only the list badge reactive update).
      final viewModel = GetIt.I<DeskViewModel>();
      viewModel.currentDocumentTypeSlug.value = allFieldsDocumentType.name;
      await viewModel.publishDocumentData.run((
        documentId: betaDoc.id!,
        data: {'string_field': 'published content'},
      ));
      await tester.pumpAndSettle();

      // Reload the versions container so the badge widget reacts.
      viewModel.versionsContainer(betaDoc.id!).awaitableReload();
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Test Document Beta'),
        matching: find.byType(Container),
      ).first;

      expect(
        find.descendant(of: tile, matching: find.text('published')),
        findsOneWidget,
        reason:
            'After publish the newest version is published — badge must say "published"',
      );
    });
  });

  // =========================================================================
  // DeskButton: loading state shows button label, not "Please wait"
  //
  // Before the fix: `child: Text(loading ? 'Please wait' : text)` replaced
  // the label with "Please wait" during loading, which dimmed into the button
  // background color and was invisible on the auth screen.
  // After the fix: `child: Text(text)` always shows the label; the spinner
  // appears as a leading widget.
  // =========================================================================

  group('DeskButton: loading state', () {
    testWidgets('shows original label text while loading', (tester) async {
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: Center(
              child: DeskButton(
                key: const ValueKey('test_btn'),
                text: 'Save',
                loading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Save'),
        findsOneWidget,
        reason: 'Button must display its label even while loading',
      );
      expect(
        find.text('Please wait'),
        findsNothing,
        reason: '"Please wait" must not appear — it becomes invisible on colored buttons',
      );
    });

    testWidgets('shows CircularProgressIndicator while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: Center(
              child: DeskButton(
                key: const ValueKey('test_btn'),
                text: 'Publish',
                loading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no spinner when not loading', (tester) async {
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: Center(
              child: DeskButton(
                key: const ValueKey('test_btn'),
                text: 'Save',
                loading: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  // =========================================================================
  // DeskStatusPill: renders correct label per status
  // =========================================================================

  group('DeskStatusPill: label per status', () {
    for (final (status, expectedLabel) in [
      (DocumentVersionStatus.draft, 'draft'),
      (DocumentVersionStatus.published, 'published'),
      (DocumentVersionStatus.archived, 'archived'),
      (DocumentVersionStatus.scheduled, 'scheduled'),
    ]) {
      testWidgets('shows "$expectedLabel" for $status', (tester) async {
        await tester.pumpWidget(
          ShadApp(
            home: Scaffold(
              body: Center(child: DeskStatusPill(status: status)),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(expectedLabel), findsOneWidget);
      });
    }
  });
}
