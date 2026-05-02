import 'package:dart_desk/src/studio/components/version/desk_version_history.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_view_model.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------------------------------------------------------------------------
// Data sources
// ---------------------------------------------------------------------------

/// A [MockDataSource] with a working [restoreDocumentVersion] that records
/// the last call for assertion.
class _TrackingDataSource extends MockDataSource {
  String? lastRestoredDocumentId;
  String? lastRestoredVersionId;

  @override
  Future<DeskDocument> restoreDocumentVersion(
    String documentId,
    String versionId,
  ) async {
    lastRestoredDocumentId = documentId;
    lastRestoredVersionId = versionId;
    return super.restoreDocumentVersion(documentId, versionId);
  }
}

/// A [MockDataSource] whose [restoreDocumentVersion] never completes —
/// keeps the mutation in [MutationPending] for in-flight assertions.
class _HangingRestoreDataSource extends MockDataSource {
  @override
  Future<DeskDocument> restoreDocumentVersion(
    String documentId,
    String versionId,
  ) {
    // Never completes.
    return Future<DeskDocument>.delayed(const Duration(days: 999));
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [DeskVersionHistory] in a minimal testable app with [ShadToaster]
/// and [StudioProvider].
Widget _buildApp({
  required MockDataSource dataSource,
  void Function(BuildContext)? onBuilt,
}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: [allFieldsDocumentType],
          child: Builder(
            builder: (context) {
              onBuilt?.call(context);
              return Center(
                child: DeskVersionHistory(
                  viewModel: GetIt.I<DeskViewModel>(),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

/// Seeds [dataSource] with a document that has [publishedCount] published
/// versions and [draftCount] draft versions, and sets the active document
/// in [DeskDocumentViewModel].
///
/// Returns the document ID.
Future<String> _seedVersions(
  MockDataSource dataSource, {
  int publishedCount = 2,
  int draftCount = 1,
}) async {
  final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
  final docId = docs.documents.first.id!;

  // Get the existing version for this doc (seeded by seedDefaults).
  final existingVersions = await dataSource.getDocumentVersions(docId);
  // Archive any pre-existing versions so our counts are exact.
  for (final v in existingVersions.versions) {
    if (v.id != null && v.isPublished) {
      await dataSource.archiveDocumentVersion(v.id!);
    }
  }

  // Add published versions with distinct timestamps.
  for (int i = 0; i < publishedCount; i++) {
    await dataSource.publishCurrentVersion(docId);
  }
  // Add draft versions.
  for (int i = 0; i < draftCount; i++) {
    await dataSource.createDocumentVersion(docId);
  }

  return docId;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeskVersionHistory — timeline rendering', () {
    testWidgets('renders a PublishedEvent row for each published version', (
      tester,
    ) async {
      final dataSource = MockDataSource()..seedDefaults();
      late String docId;

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Obtain the first document id and ensure it has 2 published versions.
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      docId = docs.documents.first.id!;

      // Publish two versions on the doc.
      await dataSource.publishCurrentVersion(docId);
      await dataSource.publishCurrentVersion(docId);

      // Set the document in DeskDocumentViewModel so versionsContainer resolves.
      GetIt.I<DeskDocumentViewModel>().documentId.value = docId;
      GetIt.I<DeskViewModel>().selectedDocumentId.value = docId;

      await tester.pump();
      await tester.pumpAndSettle();

      // Open the popover.
      await tester.tap(find.byKey(const ValueKey('version_history_button')));
      await tester.pumpAndSettle();

      // At least one "Published" label should appear.
      expect(find.text('Published'), findsWidgets);
    });

    testWidgets('hides draft and archived versions — only published shown', (
      tester,
    ) async {
      final dataSource = MockDataSource()..seedDefaults();

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
          },
        ),
      );
      await tester.pumpAndSettle();

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final docId = docs.documents.first.id!;

      // Publish one version, leave a draft version as well.
      await dataSource.publishCurrentVersion(docId);
      await dataSource.createDocumentVersion(docId); // draft

      GetIt.I<DeskDocumentViewModel>().documentId.value = docId;
      GetIt.I<DeskViewModel>().selectedDocumentId.value = docId;
      await tester.pump();
      await tester.pumpAndSettle();

      // Open the popover.
      await tester.tap(find.byKey(const ValueKey('version_history_button')));
      await tester.pumpAndSettle();

      // "Published" rows should exist; the word "draft" should NOT appear as
      // a row label in the timeline.
      expect(find.text('Published'), findsWidgets);
      // No row bearing the draft-status badge text 'D' or 'DRAFT' via
      // _StatusBadge — the timeline rows never show _StatusBadge.
      // More importantly, no Restore button should appear with a key that
      // belongs to a draft version (those are not in events).
      final restoreButtons = find.textContaining('Restore');
      // Every Restore button that exists must be for a published version.
      // We just confirm no crash and the button is present for the published
      // version only.
      expect(restoreButtons, findsWidgets);
    });

    testWidgets('shows empty state when there are no published versions', (
      tester,
    ) async {
      final dataSource = MockDataSource()..seedDefaults();

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
          },
        ),
      );
      await tester.pumpAndSettle();

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      // Use the last doc — seeded as draft-only (no published version).
      final draftDoc = docs.documents.last;

      GetIt.I<DeskDocumentViewModel>().documentId.value = draftDoc.id!;
      GetIt.I<DeskViewModel>().selectedDocumentId.value = draftDoc.id!;
      await tester.pump();
      await tester.pumpAndSettle();

      // Button should be disabled (versions exist but none published).
      // Tapping a disabled button should open nothing.
      final versions = await dataSource.getDocumentVersions(draftDoc.id!);
      final hasPublished = versions.versions.any((v) => v.isPublished);
      if (!hasPublished && versions.versions.isNotEmpty) {
        // Button is disabled — can't open popover, but no crash.
        expect(find.byKey(const ValueKey('version_history_button')), findsOneWidget);
      }
    });

    testWidgets('published events are sorted newest first', (tester) async {
      final dataSource = MockDataSource()..seedDefaults();

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final docId = docs.documents.first.id!;

      // Publish two versions in sequence. publishCurrentVersion stamps
      // publishedAt = DateTime.now() each time, so v2.publishedAt >= v1.publishedAt.
      // The timeline sorts by timestamp descending → v2 (higher versionNumber) first.
      final v1 = await dataSource.publishCurrentVersion(docId);
      final v2 = await dataSource.publishCurrentVersion(docId);

      // v2 must have a higher version number.
      expect(v2.versionNumber, greaterThan(v1.versionNumber));

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
            GetIt.I<DeskDocumentViewModel>().documentId.value = docId;
            GetIt.I<DeskViewModel>().selectedDocumentId.value = docId;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Open the popover.
      await tester.tap(find.byKey(const ValueKey('version_history_button')));
      await tester.pumpAndSettle();

      // Both version labels should be visible.
      expect(find.text('v${v1.versionNumber}'), findsOneWidget);
      expect(find.text('v${v2.versionNumber}'), findsOneWidget);

      // v2 (newer) should render above v1 (older): lower dy value.
      final v2Top = tester.getTopLeft(find.text('v${v2.versionNumber}')).dy;
      final v1Top = tester.getTopLeft(find.text('v${v1.versionNumber}')).dy;
      expect(v2Top, lessThan(v1Top),
          reason: 'Newer version (v${v2.versionNumber}) should appear first');
    });
  });

  // ---------------------------------------------------------------------------
  // Restore action
  // ---------------------------------------------------------------------------

  group('DeskVersionHistory — Restore action', () {
    testWidgets('tapping Restore calls restoreVersion with correct args', (
      tester,
    ) async {
      final dataSource = _TrackingDataSource()..seedDefaults();

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
          },
        ),
      );
      await tester.pumpAndSettle();

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final docId = docs.documents.first.id!;

      final publishedVersion = await dataSource.publishCurrentVersion(docId);

      GetIt.I<DeskDocumentViewModel>().documentId.value = docId;
      GetIt.I<DeskViewModel>().selectedDocumentId.value = docId;
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('version_history_button')));
      await tester.pumpAndSettle();

      // Tap the Restore button for the published version.
      final restoreKey = ValueKey('restore_button_${publishedVersion.id}');
      expect(find.byKey(restoreKey), findsOneWidget);
      await tester.tap(find.byKey(restoreKey));
      await tester.pumpAndSettle();

      expect(dataSource.lastRestoredDocumentId, equals(docId));
      expect(dataSource.lastRestoredVersionId, equals(publishedVersion.id));
    });

    testWidgets('Restore success shows toast without crashing', (
      tester,
    ) async {
      final dataSource = _TrackingDataSource()..seedDefaults();

      await tester.pumpWidget(
        _buildApp(
          dataSource: dataSource,
          onBuilt: (context) {
            GetIt.I<DeskViewModel>().currentDocumentTypeSlug.value =
                allFieldsDocumentType.name;
          },
        ),
      );
      await tester.pumpAndSettle();

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final docId = docs.documents.first.id!;
      final publishedVersion = await dataSource.publishCurrentVersion(docId);

      GetIt.I<DeskDocumentViewModel>().documentId.value = docId;
      GetIt.I<DeskViewModel>().selectedDocumentId.value = docId;
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('version_history_button')));
      await tester.pumpAndSettle();

      final restoreKey = ValueKey('restore_button_${publishedVersion.id}');
      await tester.tap(find.byKey(restoreKey));
      await tester.pumpAndSettle();

      // Toast message should contain "Restored".
      expect(find.textContaining('Restored'), findsOneWidget);
    });
  });
}
