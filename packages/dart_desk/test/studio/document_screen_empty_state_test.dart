import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/studio/providers/studio_provider.dart';
import 'package:dart_desk/src/studio/screens/document_screen.dart';
import 'package:dart_desk/src/studio/screens/document_type_screen.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _emptyStateText = 'Select or create a document to get started';

Widget _wrap({
  required MockDataSource dataSource,
  required DocumentType docType,
  required Widget child,
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
              return ResponsiveBreakpoints.builder(
                breakpoints: const [
                  Breakpoint(
                    start: 0,
                    end: DeskBreakpoints.mobile,
                    name: DeskBreakpoints.mobileTag,
                  ),
                  Breakpoint(
                    start: DeskBreakpoints.mobile,
                    end: DeskBreakpoints.tablet,
                    name: DeskBreakpoints.tabletTag,
                  ),
                  Breakpoint(
                    start: DeskBreakpoints.tablet,
                    end: double.infinity,
                    name: DeskBreakpoints.desktopTag,
                  ),
                ],
                child: child,
              );
            },
          ),
        ),
      ),
    ),
  );
}

void main() {
  late MockDataSource dataSource;

  setUpAll(() {
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  setUp(() {
    dataSource = MockDataSource();
  });

  group('DocumentTypeScreen (no document selected)', () {
    testWidgets('desktop renders empty state, not editor', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          child: DocumentTypeScreen(
            documentTypeSlug: allFieldsDocumentType.name,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(_emptyStateText), findsOneWidget);
      expect(find.byType(DeskDocumentEditor), findsNothing);
    });
  });

  group('DocumentScreen (document selected)', () {
    testWidgets('desktop renders editor, not empty state', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final docs = await dataSource.getDocuments(allFieldsDocumentType.name);
      final doc = docs.documents.first;

      await tester.pumpWidget(
        _wrap(
          dataSource: dataSource,
          docType: allFieldsDocumentType,
          child: DocumentScreen(
            documentTypeSlug: allFieldsDocumentType.name,
            documentId: doc.id!,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeskDocumentEditor), findsOneWidget);
      expect(find.text(_emptyStateText), findsNothing);
    });
  });
}
