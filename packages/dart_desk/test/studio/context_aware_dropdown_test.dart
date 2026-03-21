import 'dart:async';

import 'package:dart_desk/src/inputs/dropdown_input.dart';
import 'package:dart_desk/src/inputs/multi_dropdown_input.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../helpers/input_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// A CmsMultiDropdownOption subclass that resolves options from BuildContext,
/// proving the context-aware API works.
class _ContextAwareDropdownOption extends CmsMultiDropdownOption<String> {
  final String documentType;

  const _ContextAwareDropdownOption({required this.documentType});

  @override
  List<DropdownOption<String>> options(BuildContext context) {
    final viewModel = cmsViewModelProvider.of(context);
    final state = viewModel.documentsContainer(documentType).watch(context);
    return state.map(
      data: (list) => list.documents
          .map((d) => DropdownOption(
              value: d.id.toString(), label: d.title))
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  @override
  List<String>? get defaultValues => null;

  @override
  String? get placeholder => 'Select a document...';

  @override
  int? get minSelected => null;

  @override
  int? get maxSelected => null;
}

/// Wraps a widget in StudioProvider + ShadApp for tests that need CmsViewModel.
Widget buildStudioTestApp({
  required MockDataSource dataSource,
  required List<DocumentType> documentTypes,
  required Widget Function(BuildContext context) builder,
}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: documentTypes,
          child: Builder(builder: builder),
        ),
      ),
    ),
  );
}

/// A simple document type for these tests.
final _testDocType = DocumentType(
  name: 'test_type',
  title: 'Test Type',
  description: 'Test document type',
  fields: const [],
  builder: (_) => const SizedBox(),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockDataSource dataSource;

  setUp(() {
    dataSource = MockDataSource();
  });

  // ==========================================================================
  // Group 1: Context-aware dropdown options (Change 1)
  // ==========================================================================

  group('Context-aware CmsDropdownOption', () {
    testWidgets('CmsDropdownSimpleOption ignores context and returns static options',
        (tester) async {
      const field = CmsDropdownField<String>(
        name: 'simple',
        title: 'Simple',
        option: CmsDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'Alpha'),
            DropdownOption(value: 'b', label: 'Beta'),
          ],
          placeholder: 'Pick one',
        ),
      );

      await tester.pumpWidget(buildInputApp(
        CmsDropdownInput<String>(field: field),
      ));
      await tester.pumpAndSettle();

      // Placeholder visible
      expect(find.text('Pick one'), findsOneWidget);

      // Open dropdown — both options should appear
      await tester.tap(find.text('Pick one'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsWidgets);
      expect(find.text('Beta'), findsWidgets);
    });

    testWidgets('context-aware option resolves documents from CmsViewModel',
        (tester) async {
      // MockDataSource seeds 3 documents of type 'test_all_fields'.
      // We use that type so documentsContainer returns real data.
      final field = CmsMultiDropdownField<String>(
        name: 'ref_doc',
        title: 'Reference Document',
        option: _ContextAwareDropdownOption(documentType: 'test_all_fields'),
      );

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CmsMultiDropdownInput<String>(field: field),
            ),
          );
        },
      ));

      // FutureSignal needs time to resolve
      await tester.pumpAndSettle();

      // Open the dropdown — should show the 3 seeded documents
      await tester.tap(find.text('Select a document...'));
      await tester.pumpAndSettle();

      expect(find.text('Test Document Alpha'), findsWidgets);
      expect(find.text('Test Document Beta'), findsWidgets);
      expect(find.text('Test Document Gamma'), findsWidgets);
    });

    testWidgets('context-aware option shows empty when no documents exist',
        (tester) async {
      // Use a document type that has no seeded documents
      final field = CmsMultiDropdownField<String>(
        name: 'ref_doc',
        title: 'Reference Document',
        option: _ContextAwareDropdownOption(documentType: 'nonexistent_type'),
      );

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [_testDocType],
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CmsMultiDropdownInput<String>(field: field),
            ),
          );
        },
      ));

      await tester.pumpAndSettle();

      // Should show "No options available" since the type has no docs
      expect(find.text('No options available'), findsOneWidget);
    });

    testWidgets('context-aware option rebuilds when documents change',
        (tester) async {
      final field = CmsMultiDropdownField<String>(
        name: 'ref_doc',
        title: 'Reference Document',
        option: _ContextAwareDropdownOption(documentType: 'test_all_fields'),
      );

      late CmsViewModel viewModel;

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          viewModel = cmsViewModelProvider.of(context);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CmsMultiDropdownInput<String>(field: field),
            ),
          );
        },
      ));
      await tester.pumpAndSettle();

      // Open dropdown — 3 seeded docs
      await tester.tap(find.text('Select a document...'));
      await tester.pumpAndSettle();
      expect(find.text('Test Document Alpha'), findsWidgets);

      // Close dropdown
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Create a new document via the data source directly
      await dataSource.createDocument(
        'test_all_fields',
        'Delta Document',
        {},
      );

      // Reload the container
      viewModel.documentsContainer('test_all_fields').reload();
      await tester.pumpAndSettle();

      // Open dropdown again — should now show 4 docs
      await tester.tap(find.text('Select a document...'));
      await tester.pumpAndSettle();

      expect(find.text('Delta Document'), findsWidgets);
    });
  });

  // ==========================================================================
  // Group 2: Simplified documentsContainer (Change 2)
  // ==========================================================================

  group('Simplified documentsContainer', () {
    testWidgets('keys on String document type and fetches documents',
        (tester) async {
      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          final vm = cmsViewModelProvider.of(context);
          final state = vm.documentsContainer('test_all_fields').watch(context);
          return state.map(
            data: (list) => Text('count: ${list.documents.length}'),
            loading: () => const Text('loading'),
            error: (e, _) => Text('error: $e'),
          );
        },
      ));

      // Initially loading
      expect(find.text('loading'), findsOneWidget);

      await tester.pumpAndSettle();

      // Should show 3 seeded documents
      expect(find.text('count: 3'), findsOneWidget);
    });

    testWidgets('different document types produce separate containers',
        (tester) async {
      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType, _testDocType],
        builder: (context) {
          final vm = cmsViewModelProvider.of(context);
          final state1 =
              vm.documentsContainer('test_all_fields').watch(context);
          final state2 = vm.documentsContainer('test_type').watch(context);

          final count1 = state1.map(
            data: (list) => list.documents.length,
            loading: () => -1,
            error: (_, __) => -2,
          );
          final count2 = state2.map(
            data: (list) => list.documents.length,
            loading: () => -1,
            error: (_, __) => -2,
          );

          return Text('counts: $count1, $count2');
        },
      ));

      await tester.pumpAndSettle();

      // test_all_fields has 3 docs, test_type has 0
      expect(find.text('counts: 3, 0'), findsOneWidget);
    });

    testWidgets('reload updates the container data', (tester) async {
      late CmsViewModel viewModel;

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          viewModel = cmsViewModelProvider.of(context);
          final state = viewModel
              .documentsContainer('test_all_fields')
              .watch(context);
          return state.map(
            data: (list) => Text('count: ${list.documents.length}'),
            loading: () => const Text('loading'),
            error: (e, _) => Text('error: $e'),
          );
        },
      ));

      await tester.pumpAndSettle();
      expect(find.text('count: 3'), findsOneWidget);

      // Add a document and reload
      await dataSource.createDocument('test_all_fields', 'New Doc', {});
      viewModel.documentsContainer('test_all_fields').reload();

      await tester.pumpAndSettle();
      expect(find.text('count: 4'), findsOneWidget);
    });

    testWidgets('CmsViewModel.refreshDocuments reloads current type',
        (tester) async {
      late CmsViewModel viewModel;

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          viewModel = cmsViewModelProvider.of(context);
          viewModel.currentDocumentTypeSlug.value = 'test_all_fields';

          final state = viewModel
              .documentsContainer('test_all_fields')
              .watch(context);
          return state.map(
            data: (list) => Text('count: ${list.documents.length}'),
            loading: () => const Text('loading'),
            error: (e, _) => Text('error: $e'),
          );
        },
      ));

      await tester.pumpAndSettle();
      expect(find.text('count: 3'), findsOneWidget);

      // Add document and use refreshDocuments (the simplified API)
      await dataSource.createDocument('test_all_fields', 'Extra', {});
      viewModel.refreshDocuments();

      await tester.pumpAndSettle();
      expect(find.text('count: 4'), findsOneWidget);
    });

    testWidgets('createDocument reloads the documents container',
        (tester) async {
      late CmsViewModel viewModel;

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          viewModel = cmsViewModelProvider.of(context);
          viewModel.currentDocumentTypeSlug.value = 'test_all_fields';

          final state = viewModel
              .documentsContainer('test_all_fields')
              .watch(context);
          return state.map(
            data: (list) => Text('count: ${list.documents.length}'),
            loading: () => const Text('loading'),
            error: (e, _) => Text('error: $e'),
          );
        },
      ));

      await tester.pumpAndSettle();
      expect(find.text('count: 3'), findsOneWidget);

      // Use the ViewModel's createDocument, which should auto-reload
      await viewModel.createDocument('New via VM', {});

      await tester.pumpAndSettle();
      expect(find.text('count: 4'), findsOneWidget);
    });

    testWidgets('deleteDocument reloads the documents container',
        (tester) async {
      late CmsViewModel viewModel;

      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          viewModel = cmsViewModelProvider.of(context);
          viewModel.currentDocumentTypeSlug.value = 'test_all_fields';

          final state = viewModel
              .documentsContainer('test_all_fields')
              .watch(context);
          return state.map(
            data: (list) => Text('count: ${list.documents.length}'),
            loading: () => const Text('loading'),
            error: (e, _) => Text('error: $e'),
          );
        },
      ));

      await tester.pumpAndSettle();
      expect(find.text('count: 3'), findsOneWidget);

      // Delete the first document (ID 1)
      await viewModel.deleteDocument(1);

      await tester.pumpAndSettle();
      expect(find.text('count: 2'), findsOneWidget);
    });
  });

  // ==========================================================================
  // Group 3: Document list with client-side search (Change 2 - UI)
  // ==========================================================================

  group('CmsDocumentListView with simplified container', () {
    testWidgets('renders document list for a document type', (tester) async {
      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          final vm = cmsViewModelProvider.of(context);
          vm.currentDocumentTypeSlug.value = 'test_all_fields';

          return CmsDocumentListView(
            selectedDocumentType: allFieldsDocumentType,
          );
        },
      ));

      await tester.pumpAndSettle();

      // All 3 seeded documents should be visible
      expect(find.text('Test Document Alpha'), findsOneWidget);
      expect(find.text('Test Document Beta'), findsOneWidget);
      expect(find.text('Test Document Gamma'), findsOneWidget);
    });

    testWidgets('client-side search filters documents', (tester) async {
      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          final vm = cmsViewModelProvider.of(context);
          vm.currentDocumentTypeSlug.value = 'test_all_fields';

          return CmsDocumentListView(
            selectedDocumentType: allFieldsDocumentType,
          );
        },
      ));

      await tester.pumpAndSettle();

      // All 3 visible initially
      expect(find.text('Test Document Alpha'), findsOneWidget);
      expect(find.text('Test Document Beta'), findsOneWidget);
      expect(find.text('Test Document Gamma'), findsOneWidget);

      // Type in the search bar
      await tester.enterText(
        find.widgetWithText(ShadInputFormField, 'Search documents...'),
        'Alpha',
      );
      await tester.pumpAndSettle();

      // Only Alpha should be visible
      expect(find.text('Test Document Alpha'), findsOneWidget);
      expect(find.text('Test Document Beta'), findsNothing);
      expect(find.text('Test Document Gamma'), findsNothing);
    });

    testWidgets('search with no matches shows empty state', (tester) async {
      await tester.pumpWidget(buildStudioTestApp(
        dataSource: dataSource,
        documentTypes: [allFieldsDocumentType],
        builder: (context) {
          final vm = cmsViewModelProvider.of(context);
          vm.currentDocumentTypeSlug.value = 'test_all_fields';

          return CmsDocumentListView(
            selectedDocumentType: allFieldsDocumentType,
          );
        },
      ));

      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(ShadInputFormField, 'Search documents...'),
        'nonexistent',
      );
      await tester.pumpAndSettle();

      expect(find.text('No documents match your search'), findsOneWidget);
    });
  });
}
