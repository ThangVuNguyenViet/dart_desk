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
import 'package:signals/signals_flutter.dart';

import '../helpers/input_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

/// Minimal preview panel that watches editedData and calls docType.builder,
/// mirroring the real DeskStudio._buildPreview logic.
class _PreviewPanel extends StatelessWidget {
  final DocumentType docType;
  const _PreviewPanel({required this.docType});

  @override
  Widget build(BuildContext context) {
    final edited = GetIt.I<DeskDocumentViewModel>().editedData.watch(context);
    return docType.builder(edited);
  }
}

/// Builds a test app with StudioProvider wrapping an editor + preview side by
/// side. Optionally seeds editedData so the preview starts with known values.
Widget buildEditorPreviewTestApp({
  required MockDataSource dataSource,
  required DocumentType docType,
  Map<String, dynamic> seedData = const {},
}) {
  return ShadApp(
    home: Scaffold(
      body: ShadToaster(
        child: StudioProvider(
          dataSource: dataSource,
          documentTypes: [docType],
          child: Builder(
            builder: (context) {
              // Activate the document type so DeskForm's DeskImageField branch works.
              final vm = GetIt.I<DeskViewModel>();
              vm.currentDocumentTypeSlug.value = docType.name;

              // Seed editedData if provided.
              if (seedData.isNotEmpty) {
                final docVM = GetIt.I<DeskDocumentViewModel>();
                docVM.editedData.value = Map<String, dynamic>.from(seedData);
              }

              return Row(
                children: [
                  Expanded(child: _PreviewPanel(docType: docType)),
                  Expanded(
                    child: DeskDocumentEditor(
                      fields: docType.fields,
                      title: docType.title,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

/// Builds a standalone DeskForm (no provider required beyond deskViewModelProvider
/// for image field) wrapped in the same shell as input tests.
Widget buildDeskFormTestApp({
  required MockDataSource dataSource,
  required DocumentType docType,
  required List<DeskField> fields,
  Map<String, dynamic> data = const {},
  OnFieldChanged? onFieldChanged,
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
              return DeskForm(
                fields: fields,
                data: data,
                onFieldChanged: onFieldChanged,
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
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  setUp(() {
    dataSource = MockDataSource();
  });

  // ========================================================================
  // Group 1: DeskForm field routing
  // ========================================================================

  group('DeskForm field routing', () {
    testWidgets('renders all field inputs', (tester) async {
      await tester.pumpWidget(
        buildDeskFormTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          fields: allFieldsDocumentType.fields,
        ),
      );
      await tester.pump();

      // Spot-check several input types are present.
      expect(find.byType(DeskStringInput), findsOneWidget);
      expect(find.byType(DeskNumberInput), findsOneWidget);
      expect(find.byType(DeskBooleanInput), findsOneWidget);
      expect(find.byType(DeskTextInput), findsOneWidget);
      expect(find.byType(DeskUrlInput), findsOneWidget);
    });

    testWidgets('routes string field change', (tester) async {
      String? receivedName;
      dynamic receivedValue;

      await tester.pumpWidget(
        buildDeskFormTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          fields: const [
            DeskStringField(
              name: 'string_field',
              title: 'String Field',
              option: DeskStringOption(),
            ),
          ],
          onFieldChanged: (name, value) {
            receivedName = name;
            receivedValue = value;
          },
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(ShadInputFormField), 'typed text');
      await tester.pump();

      expect(receivedName, 'string_field');
      expect(receivedValue, 'typed text');
    });

    testWidgets('routes number field change', (tester) async {
      String? receivedName;
      dynamic receivedValue;

      await tester.pumpWidget(
        buildDeskFormTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          fields: const [
            DeskNumberField(
              name: 'number_field',
              title: 'Number Field',
              option: DeskNumberOption(),
            ),
          ],
          onFieldChanged: (name, value) {
            receivedName = name;
            receivedValue = value;
          },
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(ShadInputFormField), '123');
      await tester.pump();

      expect(receivedName, 'number_field');
      expect(receivedValue, 123);
    });

    testWidgets('routes boolean field change', (tester) async {
      String? receivedName;
      dynamic receivedValue;

      await tester.pumpWidget(
        buildDeskFormTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          fields: const [
            DeskBooleanField(
              name: 'boolean_field',
              title: 'Boolean Field',
              option: DeskBooleanOption(),
            ),
          ],
          onFieldChanged: (name, value) {
            receivedName = name;
            receivedValue = value;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(receivedName, 'boolean_field');
      expect(receivedValue, isNotNull);
    });
  });

  // ========================================================================
  // Group 2: Editor → editedData signal
  // ========================================================================

  group('Editor writes to editedData', () {
    testWidgets('on string change', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pump();

      // The string field is the first ShadInputFormField in the form.
      final stringField = find.byKey(const ValueKey('string_field'));
      expect(stringField, findsOneWidget);

      // Find the ShadInputFormField inside the string field widget.
      final inputField = find.descendant(
        of: stringField,
        matching: find.byType(ShadInputFormField),
      );
      expect(inputField, findsOneWidget);

      await tester.enterText(inputField, 'hello world');
      await tester.pump();

      // Access editedData through the element tree.
      final editedData = GetIt.I<DeskDocumentViewModel>().editedData;
      expect(editedData['string_field'], 'hello world');
    });

    testWidgets('on number change', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pump();

      final numberField = find.byKey(const ValueKey('number_field'));
      final inputField = find.descendant(
        of: numberField,
        matching: find.byType(ShadInputFormField),
      );
      expect(inputField, findsOneWidget);

      await tester.enterText(inputField, '99');
      await tester.pump();

      final editedData = GetIt.I<DeskDocumentViewModel>().editedData;
      expect(editedData['number_field'], 99);
    });

    testWidgets('on boolean toggle', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pump();

      final boolField = find.byKey(const ValueKey('boolean_field'));
      final switchFinder = find.descendant(
        of: boolField,
        matching: find.byType(ShadSwitch),
      );
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final editedData = GetIt.I<DeskDocumentViewModel>().editedData;
      expect(editedData['boolean_field'], isNotNull);
    });
  });

  // ========================================================================
  // Group 3: editedData → Preview rebuild
  // ========================================================================

  group('Preview rebuilds from editedData', () {
    testWidgets('shows seed data on load', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {'string_field': 'Hello World', 'number_field': 42},
        ),
      );
      await tester.pump();

      expect(find.text('preview:string_field: Hello World'), findsOneWidget);
      expect(find.text('preview:number_field: 42'), findsOneWidget);
    });

    testWidgets('updates when string edited', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {'string_field': 'original'},
        ),
      );
      await tester.pump();

      expect(find.text('preview:string_field: original'), findsOneWidget);

      // Edit the string field.
      final stringField = find.byKey(const ValueKey('string_field'));
      final inputField = find.descendant(
        of: stringField,
        matching: find.byType(ShadInputFormField),
      );
      await tester.enterText(inputField, 'updated');
      await tester.pump();

      expect(find.text('preview:string_field: updated'), findsOneWidget);
    });

    testWidgets('updates when number edited', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {'number_field': 10},
        ),
      );
      await tester.pump();

      expect(find.text('preview:number_field: 10'), findsOneWidget);

      final numberField = find.byKey(const ValueKey('number_field'));
      final inputField = find.descendant(
        of: numberField,
        matching: find.byType(ShadInputFormField),
      );
      await tester.enterText(inputField, '77');
      await tester.pump();

      expect(find.text('preview:number_field: 77'), findsOneWidget);
    });

    testWidgets('updates when boolean toggled', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {'boolean_field': false},
        ),
      );
      await tester.pump();

      expect(find.text('preview:boolean_field: false'), findsOneWidget);

      final boolField = find.byKey(const ValueKey('boolean_field'));
      final switchFinder = find.descendant(
        of: boolField,
        matching: find.byType(ShadSwitch),
      );
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('preview:boolean_field: true'), findsOneWidget);
    });

    testWidgets('shows empty document_ref_dropdown preview when null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {'document_ref_dropdown': <String>[]},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('preview:document_ref_dropdown: []'), findsOneWidget);
    });

    testWidgets('shows resolved title in document_ref_dropdown preview', (
      tester,
    ) async {
      final docs = await dataSource.getDocuments('test_all_fields');
      final betaDoc = docs.documents.firstWhere(
        (d) => d.title == 'Test Document Beta',
      );

      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {
            'document_ref_dropdown': [betaDoc.id!],
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'preview:document_ref_dropdown: [${betaDoc.id}] (Test Document Beta)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('updates preview when document_ref_dropdown changes', (
      tester,
    ) async {
      final docs = await dataSource.getDocuments('test_all_fields');
      final alphaDoc = docs.documents.firstWhere(
        (d) => d.title == 'Test Document Alpha',
      );
      final gammaDoc = docs.documents.firstWhere(
        (d) => d.title == 'Test Document Gamma',
      );

      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          seedData: {
            'document_ref_dropdown': [alphaDoc.id!],
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'preview:document_ref_dropdown: [${alphaDoc.id}] (Test Document Alpha)',
        ),
        findsOneWidget,
      );

      // Programmatically update editedData to simulate selection change
      final editedData = GetIt.I<DeskDocumentViewModel>().editedData;
      editedData.value = {
        ...editedData.value,
        'document_ref_dropdown': [gammaDoc.id!],
      };
      await tester.pumpAndSettle();

      expect(
        find.text(
          'preview:document_ref_dropdown: [${gammaDoc.id}] (Test Document Gamma)',
        ),
        findsOneWidget,
      );
    });
  });

  // ========================================================================
  // Group 4: Save / Discard buttons
  // ========================================================================

  group('Save and Discard buttons', () {
    testWidgets('appear after edit', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pump();

      // Initially no Save/Discard.
      expect(find.text('Save'), findsNothing);
      expect(find.text('Discard'), findsNothing);

      // Type something to trigger unsaved changes.
      final stringField = find.byKey(const ValueKey('string_field'));
      final inputField = find.descendant(
        of: stringField,
        matching: find.byType(ShadInputFormField),
      );
      await tester.enterText(inputField, 'change');
      await tester.pump();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('Discard resets editedData', (tester) async {
      await tester.pumpWidget(
        buildEditorPreviewTestApp(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
        ),
      );
      await tester.pump();

      // Make an edit.
      final stringField = find.byKey(const ValueKey('string_field'));
      final inputField = find.descendant(
        of: stringField,
        matching: find.byType(ShadInputFormField),
      );
      await tester.enterText(inputField, 'dirty');
      await tester.pump();

      // Verify editedData has the change.
      final editedData = GetIt.I<DeskDocumentViewModel>().editedData;
      expect(editedData['string_field'], 'dirty');

      // Tap Discard.
      await tester.tap(find.text('Discard'));
      await tester.pump();

      // editedData should be reset (empty map = defaults).
      expect(editedData.value.isEmpty, isTrue);
    });
  });
}
