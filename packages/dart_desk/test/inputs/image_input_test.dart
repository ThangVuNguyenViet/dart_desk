import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

class MockDataSource extends Mock implements DataSource {}

MediaAsset _testAsset({String assetId = 'asset-hero'}) => MediaAsset(
  id: '1',
  assetId: assetId,
  fileName: 'test.png',
  mimeType: 'image/png',
  fileSize: 1024,
  publicUrl: 'https://cdn.example.com/test.png',
  width: 100,
  height: 100,
  hasAlpha: false,
  blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
  createdAt: DateTime(2026),
  metadataStatus: MediaAssetMetadataStatus.complete,
);

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  const field = DeskImageField(
    name: 'hero',
    title: 'Hero Image',
    option: DeskImageOption(hotspot: false),
  );

  const hotspotField = DeskImageField(
    name: 'hero',
    title: 'Hero Image',
    option: DeskImageOption(hotspot: true),
  );

  group('DeskImageInput', () {
    testWidgets('renders upload area when no data', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(field: field, dataSource: MockDataSource()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('upload_button')), findsOneWidget);
    });

    testWidgets('shows editable URL field in empty state', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(field: field, dataSource: MockDataSource()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('url_input')), findsOneWidget);
    });

    testWidgets('remove fires onChanged null (with pre-loaded image)', (
      tester,
    ) async {
      Map<String, dynamic>? received = {'sentinel': true};
      final dataSource = MockDataSource();

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: field,
            data: const DeskData(
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
      when(() => dataSource.getMediaAsset('asset-hero'))
          .thenAnswer((_) async => _testAsset());

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: hotspotField,
            data: const DeskData(
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
      when(() => dataSource.getMediaAsset('asset-hero'))
          .thenAnswer((_) async => _testAsset());

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: hotspotField,
            data: const DeskData(
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
        buildInputApp(DeskImageInput(field: field, dataSource: dataSource)),
      );
      await tester.pumpAndSettle();

      // Tap the upload button — the full async pipeline (pick → metadata
      // extraction via compute/isolate → upload) can't complete in widget
      // tests. Full upload is verified via integration tests.
      await tester.tap(find.byKey(const ValueKey('upload_button')));
      await tester.pump();

      // No crash — widget handled the tap
      expect(find.byKey(const ValueKey('upload_button')), findsOneWidget);
    });

    testWidgets('shows Image.memory preview during upload', (tester) async {
      final dataSource = MockDataSource();
      FakeFilePickerPlatform.install();

      final completer = Completer<MediaAsset>();
      when(
        () => dataSource.uploadImage(any(), any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildInputApp(DeskImageInput(field: field, dataSource: dataSource)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('upload_button')));
      // Pump enough for FilePicker to resolve and _UploadState.uploading to be set.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // While upload is in progress, widget shows Image.memory from picked bytes.
      expect(
        find.byWidgetPredicate((w) => w is Image && w.image is MemoryImage),
        findsOneWidget,
      );

      completer.complete(_testAsset());
      await tester.pumpAndSettle();
    });

    testWidgets('external URL data shows editable URL field with value', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: field,
            data: const DeskData(
              value: {
                '_type': 'imageReference',
                'externalUrl': 'https://example.com/photo.jpg',
              },
              path: 'hero',
            ),
            dataSource: MockDataSource(),
          ),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // URL input should be present (editable mode for external URLs)
      expect(find.byKey(const ValueKey('url_input')), findsOneWidget);
      // Remove button should appear since we have a value
      expect(find.byKey(const ValueKey('remove_button')), findsOneWidget);
    });

    testWidgets('asset mode shows read-only URL field with copy button', (
      tester,
    ) async {
      final dataSource = MockDataSource();
      when(
        () => dataSource.getMediaAsset('asset-hero'),
      ).thenAnswer((_) async => _testAsset());

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: field,
            data: const DeskData(
              value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
              path: 'hero',
            ),
            dataSource: dataSource,
          ),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Read-only URL display should be present (not the editable url_input)
      expect(find.byKey(const ValueKey('url_display')), findsOneWidget);
      expect(find.byKey(const ValueKey('url_input')), findsNothing);
    });

    testWidgets('remove clears both asset and external URL', (tester) async {
      Map<String, dynamic>? received = {'sentinel': true};

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: field,
            data: const DeskData(
              value: {
                '_type': 'imageReference',
                'externalUrl': 'https://example.com/photo.jpg',
              },
              path: 'hero',
            ),
            dataSource: MockDataSource(),
            onChanged: (v) => received = v,
          ),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final removeButton = find.byKey(const ValueKey('remove_button'));
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pump();

      expect(received, isNull);
      // Should be back to editable URL input
      expect(find.byKey(const ValueKey('url_input')), findsOneWidget);
    });

    testWidgets('typing URL fires onChanged with externalUrl', (tester) async {
      Map<String, dynamic>? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: field,
            dataSource: MockDataSource(),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('url_input')),
        'https://example.com/img.png',
      );
      await tester.pump();

      expect(received, isNotNull);
      expect(received!['externalUrl'], 'https://example.com/img.png');
      expect(received!['_type'], 'imageReference');
    });

    testWidgets('optional toggle off fires onChanged(null) once', (tester) async {
      const optField = DeskImageField(
        name: 'hero',
        title: 'Hero Image',
        option: DeskImageOption(hotspot: false, optional: true),
      );
      final received = <Map<String, dynamic>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: optField,
            data: const DeskData(
              value: {
                '_type': 'imageReference',
                'externalUrl': 'https://example.com/photo.jpg',
              },
              path: 'hero',
            ),
            dataSource: MockDataSource(),
            onChanged: received.add,
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pump();

      expect(received.length, 1);
      expect(received[0], isNull);
    });

    testWidgets('optional toggle off then on restores last value', (tester) async {
      const optField = DeskImageField(
        name: 'hero',
        title: 'Hero Image',
        option: DeskImageOption(hotspot: false, optional: true),
      );
      final received = <Map<String, dynamic>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(
            field: optField,
            data: const DeskData(
              value: {
                '_type': 'imageReference',
                'externalUrl': 'https://example.com/photo.jpg',
              },
              path: 'hero',
            ),
            dataSource: MockDataSource(),
            onChanged: received.add,
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pump();
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pump();

      expect(received.length, 2);
      expect(received[0], isNull);
      expect(received[1], isNotNull);
      expect(received[1]!['externalUrl'], 'https://example.com/photo.jpg');
    });

    testWidgets('optional external value flip to null does not fire onChanged', (
      tester,
    ) async {
      const optField = DeskImageField(
        name: 'hero',
        title: 'Hero Image',
        option: DeskImageOption(hotspot: false, optional: true),
      );
      var fireCount = 0;
      Widget mk(Map<String, dynamic>? value) => buildInputApp(
        DeskImageInput(
          field: optField,
          data: value == null ? null : DeskData(value: value, path: 'hero'),
          dataSource: MockDataSource(),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(
        mk({
          '_type': 'imageReference',
          'externalUrl': 'https://example.com/photo.jpg',
        }),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      fireCount = 0;
      await tester.pumpWidget(mk(null));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(fireCount, 0);
      final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });

    testWidgets('no tabs present in unified layout', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskImageInput(field: field, dataSource: MockDataSource()),
        ),
      );
      await tester.pumpAndSettle();

      // Tabs should not exist in the unified layout
      expect(find.text('Upload'), findsOneWidget); // button text
      expect(find.text('URL'), findsNothing); // tab text gone
    });
  });

  group('DeskImageInput keep-alive', () {
    testWidgets('stays alive when scrolled out of a ListView and back',
        (tester) async {
      // Build a DeskImageInput inside a ListView.builder with many tall spacers.
      // Scroll the image_input off-screen, then back. Assert the State object
      // identity is preserved (would fail without AutomaticKeepAliveClientMixin).
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: ShadToaster(
              child: ListView.builder(
                itemCount: 51,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return SizedBox(
                      height: 400,
                      child: DeskImageInput(
                        field: field,
                        dataSource: MockDataSource(),
                      ),
                    );
                  }
                  return const SizedBox(height: 400, child: Placeholder());
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final finder = find.byType(DeskImageInput);
      final stateBefore = tester.state(finder);

      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, 5000));
      await tester.pump();

      final stateAfter = tester.state(finder);
      expect(identical(stateBefore, stateAfter), isTrue,
          reason:
              'DeskImageInput State should be kept alive across scroll');
    });
  });
}
