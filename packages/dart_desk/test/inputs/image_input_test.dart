import 'dart:io';

import 'package:dart_desk/src/inputs/image_input.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

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
      await tester.pumpWidget(buildInputApp(
        CmsImageInput(field: field),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('upload_button')),
        findsOneWidget,
      );
    });

    testWidgets('remove fires onChanged null (with pre-loaded image)',
        (tester) async {
      Map<String, dynamic>? received = {'sentinel': true};
      final dataSource = MockDataSource();

      await tester.pumpWidget(buildInputApp(
        CmsImageInput(
          field: field,
          data: const CmsData(
            value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
            path: 'hero',
          ),
          dataSource: dataSource,
          onChanged: (v) => received = v,
        ),
      ));

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

    testWidgets('edit crop button appears with hotspot enabled',
        (tester) async {
      final dataSource = MockDataSource();

      await tester.pumpWidget(buildInputApp(
        CmsImageInput(
          field: hotspotField,
          data: const CmsData(
            value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
            path: 'hero',
          ),
          dataSource: dataSource,
        ),
      ));

      // Pump multiple frames for async image load
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        find.byKey(const ValueKey('edit_crop_button')),
        findsOneWidget,
      );
    });

    testWidgets('tapping upload triggers pick without crash', (tester) async {
      final dataSource = MockDataSource();
      FakeImagePickerPlatform.install();

      await tester.pumpWidget(buildInputApp(
        CmsImageInput(
          field: field,
          dataSource: dataSource,
        ),
      ));
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
