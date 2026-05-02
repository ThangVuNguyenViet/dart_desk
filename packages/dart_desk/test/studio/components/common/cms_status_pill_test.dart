import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------------------------------------------------------------------------
// Data sources
// ---------------------------------------------------------------------------

/// A data source whose [updateDocumentData] never completes — freezes
/// [updateData] in [MutationPending] for the "Saving…" state test.
class _HangingDataSource extends MockDataSource {
  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) {
    return Completer<DeskDocument>().future;
  }
}

/// A data source whose [updateDocumentData] always throws — produces
/// [MutationError] for the "Save failed — retry" state test.
class _FailingDataSource extends MockDataSource {
  @override
  Future<DeskDocument> updateDocumentData(
    String documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    throw Exception('network error');
  }
}

// ---------------------------------------------------------------------------
// Widget helpers
// ---------------------------------------------------------------------------

Widget _buildPillApp({required MockDataSource dataSource}) {
  return ShadApp(
    home: Scaffold(
      body: StudioProvider(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        child: const Center(child: CmsStatusPill()),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // State 1 — "Saved" (idle, no unpublished changes)
  // =========================================================================

  group('CmsStatusPill — Saved state', () {
    testWidgets('shows "Saved" when idle and no unpublished changes', (
      tester,
    ) async {
      final dataSource = MockDataSource()..seedDefaults();

      await tester.pumpWidget(_buildPillApp(dataSource: dataSource));
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  // =========================================================================
  // State 2 — "Unpublished changes"
  // =========================================================================

  group('CmsStatusPill — Unpublished changes state', () {
    testWidgets(
        'shows "Unpublished changes" when hasUnpublishedChanges is true', (
      tester,
    ) async {
      final dataSource = MockDataSource()..seedDefaults();

      // Pre-stamp crdtHlc to make hasUnpublishedChanges = true without
      // triggering the data source's updateDocumentData (avoids async races).
      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;
      dataSource.forceSetCrdtHlc(doc.id!, '9999999999999999');

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: StudioProvider(
              dataSource: dataSource,
              documentTypes: [allFieldsDocumentType],
              child: Builder(
                builder: (context) {
                  // Set selectedDocumentId so hasUnpublishedChanges can compute.
                  GetIt.I<DeskViewModel>().selectedDocumentId.value = doc.id!;
                  return const Center(child: CmsStatusPill());
                },
              ),
            ),
          ),
        ),
      );
      // Let the selectedDocumentContainer async future resolve.
      await tester.pumpAndSettle();

      expect(find.text('Unpublished changes'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });

  // =========================================================================
  // State 3 — "Saving…"
  // =========================================================================

  group('CmsStatusPill — Saving state', () {
    testWidgets('shows "Saving…" while updateData is in flight', (
      tester,
    ) async {
      final hangingDataSource = _HangingDataSource()..seedDefaults();
      final docs = await hangingDataSource.getDocuments(
        allFieldsDocumentType.name,
      );
      final doc = docs.documents.first;

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: StudioProvider(
              dataSource: hangingDataSource,
              documentTypes: [allFieldsDocumentType],
              child: Builder(
                builder: (context) {
                  GetIt.I<DeskDocumentViewModel>().documentId.value = doc.id!;
                  return const Center(child: CmsStatusPill());
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Trigger updateData — it will never complete (hanging data source).
      GetIt.I<DeskDocumentViewModel>().updateData.run((
        documentId: doc.id!,
        updates: {'string_field': 'test'},
      ));
      await tester.pump();

      expect(find.text('Saving…'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    });
  });

  // =========================================================================
  // State 4 — "Save failed — retry"
  // =========================================================================

  group('CmsStatusPill — Save failed state', () {
    testWidgets('shows "Save failed — retry" when updateData has error', (
      tester,
    ) async {
      final failingDataSource = _FailingDataSource()..seedDefaults();
      final docs = await failingDataSource.getDocuments(
        allFieldsDocumentType.name,
      );
      final doc = docs.documents.first;

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: StudioProvider(
              dataSource: failingDataSource,
              documentTypes: [allFieldsDocumentType],
              child: Builder(
                builder: (context) {
                  GetIt.I<DeskDocumentViewModel>().documentId.value = doc.id!;
                  return const Center(child: CmsStatusPill());
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Run updateData — it throws, producing MutationError.
      await GetIt.I<DeskDocumentViewModel>().updateData.run((
        documentId: doc.id!,
        updates: {'string_field': 'test'},
      ));
      await tester.pump();

      expect(find.text('Save failed — retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('tapping "Save failed — retry" resets updateData to idle', (
      tester,
    ) async {
      final failingDataSource = _FailingDataSource()..seedDefaults();
      final docs = await failingDataSource.getDocuments(
        allFieldsDocumentType.name,
      );
      final doc = docs.documents.first;

      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: StudioProvider(
              dataSource: failingDataSource,
              documentTypes: [allFieldsDocumentType],
              child: Builder(
                builder: (context) {
                  GetIt.I<DeskDocumentViewModel>().documentId.value = doc.id!;
                  return const Center(child: CmsStatusPill());
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Trigger error state.
      await GetIt.I<DeskDocumentViewModel>().updateData.run((
        documentId: doc.id!,
        updates: {'string_field': 'test'},
      ));
      await tester.pump();

      // Confirm error pill is visible.
      expect(find.text('Save failed — retry'), findsOneWidget);

      // Tap the pill — onTap calls updateData.reset().
      await tester.tap(find.text('Save failed — retry'));
      await tester.pump();

      // After reset, MutationSignal is idle → falls through to "Saved".
      expect(
        GetIt.I<DeskDocumentViewModel>().updateData.value.isIdle,
        isTrue,
        reason: 'reset() must return signal to MutationIdle',
      );
      expect(find.text('Saved'), findsOneWidget);
    });
  });
}
