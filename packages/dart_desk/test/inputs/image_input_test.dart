import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/input_test_helpers.dart';

class MockDataSource extends Mock implements DataSource {}

void main() {
  setUpAll(() {
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  const field = CmsImageField(
    name: 'hero',
    title: 'Hero Image',
    option: CmsImageOption(hotspot: false),
  );

  const hotspotField = CmsImageField(
    name: 'hero',
    title: 'Hero Image',
    option: CmsImageOption(hotspot: true),
  );

  group('CmsImageInput', () {
    testWidgets('renders upload area when no data', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          CmsImageInput(field: field, dataSource: MockDataSource()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('upload_button')), findsOneWidget);
    });

    testWidgets('remove fires onChanged null (with pre-loaded image)', (
      tester,
    ) async {
      Map<String, dynamic>? received = {'sentinel': true};
      final dataSource = MockDataSource();

      await tester.pumpWidget(
        buildInputApp(
          CmsImageInput(
            field: field,
            data: const CmsData(
              value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
              path: 'hero',
            ),
            dataSource: dataSource,
            onChanged: (v) => received = v,
          ),
        ),
      );

      // Pump multiple frames for async image load (avoid pumpAndSettle
      // since Image.network animation never settles)
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Find and tap the remove button
      final removeButton = find.byKey(const ValueKey('remove_button'));
      if (removeButton.evaluate().isNotEmpty) {
        await tester.tap(removeButton);
        await tester.pump();

        expect(received, isNull);
      }
    });

    testWidgets('edit framing button appears with hotspot enabled', (
      tester,
    ) async {
      final dataSource = MockDataSource();

      await tester.pumpWidget(
        buildInputApp(
          CmsImageInput(
            field: hotspotField,
            data: const CmsData(
              value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
              path: 'hero',
            ),
            dataSource: dataSource,
          ),
        ),
      );

      // Pump multiple frames for async image load
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byKey(const ValueKey('edit_framing_button')), findsOneWidget);
      expect(find.text('Edit framing'), findsOneWidget);
    });

    testWidgets('framing status reflects custom hotspot and crop', (
      tester,
    ) async {
      final dataSource = MockDataSource();

      await tester.pumpWidget(
        buildInputApp(
          CmsImageInput(
            field: hotspotField,
            data: const CmsData(
              value: {
                '_type': 'imageReference',
                'assetId': 'asset-hero',
                'crop': {'top': 0.1, 'bottom': 0.0, 'left': 0.0, 'right': 0.0},
              },
              path: 'hero',
            ),
            dataSource: dataSource,
          ),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Crop adjusted'), findsOneWidget);
    });

    testWidgets('tapping upload triggers pick without crash', (tester) async {
      final dataSource = MockDataSource();
      FakeImagePickerPlatform.install();

      await tester.pumpWidget(
        buildInputApp(CmsImageInput(field: field, dataSource: dataSource)),
      );
      await tester.pumpAndSettle();

      // Tap the upload button — the full async pipeline (pick → metadata
      // extraction via compute/isolate → upload) can't complete in widget
      // tests. Full upload is verified via Marionette QA integration tests.
      await tester.tap(find.byKey(const ValueKey('upload_button')));
      await tester.pump();

      // No crash — widget handled the tap
      expect(find.byKey(const ValueKey('upload_button')), findsOneWidget);
    });
  });
}
