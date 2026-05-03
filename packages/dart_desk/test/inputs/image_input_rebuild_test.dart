import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_desk/src/studio/components/forms/desk_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

class MockDataSource extends Mock implements DataSource {}

/// Wrapper that counts how many times [DeskImageInput] rebuilds.
class RebuildCounter extends StatefulWidget {
  final Widget child;
  final ValueNotifier<int> counter;

  const RebuildCounter({super.key, required this.child, required this.counter});

  @override
  State<RebuildCounter> createState() => _RebuildCounterState();
}

class _RebuildCounterState extends State<RebuildCounter> {
  @override
  Widget build(BuildContext context) {
    // This widget itself doesn't count — we inject a builder into the tree
    // that increments on every build of its subtree.
    return widget.child;
  }
}

/// A [StatelessWidget] that increments a counter every time it builds.
/// Place it as a sibling or parent proxy to detect unnecessary rebuilds.
class BuildTracker extends StatelessWidget {
  final ValueNotifier<int> counter;
  final Widget child;

  const BuildTracker({super.key, required this.counter, required this.child});

  @override
  Widget build(BuildContext context) {
    counter.value++;
    return child;
  }
}

void main() {
  setUpAll(() {
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

  group('DeskImageInput rebuild efficiency', () {
    testWidgets('empty state does not rebuild siblings', (tester) async {
      final siblingBuilds = ValueNotifier<int>(0);

      await tester.pumpWidget(
        buildInputApp(
          Column(
            children: [
              DeskImageInput(field: field, dataSource: MockDataSource()),
              BuildTracker(
                counter: siblingBuilds,
                child: const Text('sibling'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialBuilds = siblingBuilds.value;

      await tester.pump();

      expect(
        siblingBuilds.value,
        initialBuilds,
        reason: 'Sibling widget should not rebuild when DeskImageInput is idle',
      );
    });

    testWidgets('entering URL only rebuilds DeskImageInput, not siblings', (
      tester,
    ) async {
      final siblingBuilds = ValueNotifier<int>(0);

      await tester.pumpWidget(
        buildInputApp(
          Column(
            children: [
              DeskImageInput(field: field, dataSource: MockDataSource()),
              BuildTracker(
                counter: siblingBuilds,
                child: const Text('sibling'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialBuilds = siblingBuilds.value;

      // Type a URL
      await tester.enterText(
        find.byKey(const ValueKey('url_input')),
        'https://example.com/img.png',
      );
      await tester.pump();

      await tester.pump();

      expect(
        siblingBuilds.value,
        initialBuilds,
        reason:
            'Sibling widget should not rebuild when URL is entered in DeskImageInput',
      );
    });

    testWidgets('pre-loaded asset state has bounded rebuilds on initial load', (
      tester,
    ) async {
      final dataSource = MockDataSource();
      final asset = MediaAsset(
        id: '1',
        assetId: 'asset-hero',
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
      when(
        () => dataSource.getMediaAsset('asset-hero'),
      ).thenAnswer((_) async => asset);

      var imageInputBuilds = 0;

      await tester.pumpWidget(
        buildInputApp(
          // We can't directly count DeskImageInput's build() calls,
          // but we can verify that it stabilises quickly by checking
          // that after the asset loads, no further rebuilds occur on
          // a sibling.
          Builder(
            builder: (context) {
              imageInputBuilds++;
              return DeskImageInput(
                field: field,
                data: const DeskData(
                  value: {'_type': 'imageReference', 'assetId': 'asset-hero'},
                  path: 'hero',
                ),
                dataSource: dataSource,
              );
            },
          ),
        ),
      );

      await tester.pump();
      final buildsAfterLoad = imageInputBuilds;
      await tester.pump();

      expect(
        imageInputBuilds,
        buildsAfterLoad,
        reason:
            'DeskImageInput parent Builder should not rebuild after asset has loaded and state stabilised',
      );
    });

    testWidgets(
      'parent rebuild with value-equal DeskData does not reset viewmodel '
      '(no re-fetch of asset)',
      (tester) async {
        final dataSource = MockDataSource();
        final asset = MediaAsset(
          id: '1',
          assetId: 'asset-hero',
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
        when(
          () => dataSource.getMediaAsset('asset-hero'),
        ).thenAnswer((_) async => asset);

        final inputBuilds = ValueNotifier<int>(0);
        final rebuildTrigger = ValueNotifier<int>(0);

        // Each build constructs a fresh DeskData wrapper with an equivalent
        // (but not identical) value Map — mimics what an array/object parent
        // does on every rebuild.
        await tester.pumpWidget(
          buildInputApp(
            ValueListenableBuilder<int>(
              valueListenable: rebuildTrigger,
              builder: (_, _, _) => BuildTracker(
                counter: inputBuilds,
                child: DeskImageInput(
                  field: field,
                  data: DeskData(
                    value: <String, dynamic>{
                      '_type': 'imageReference',
                      'assetId': 'asset-hero',
                    },
                    path: 'hero',
                  ),
                  dataSource: dataSource,
                ),
              ),
            ),
          ),
        );

        // Let initial asset load settle.
        await tester.pump();

        verify(() => dataSource.getMediaAsset('asset-hero')).called(1);
        final buildsAfterLoad = inputBuilds.value;

        // Force exactly 5 parent rebuilds — each provides a NEW DeskData
        // wrapper with a NEW (but equivalent) Map value.
        const forcedRebuilds = 5;
        for (var i = 0; i < forcedRebuilds; i++) {
          rebuildTrigger.value++;
          await tester.pump();
        }

        // 1. No additional getMediaAsset calls — viewmodel preserved.
        verifyNever(() => dataSource.getMediaAsset(any()));

        // 2. The tree under the parent rebuilds exactly once per parent
        //    rebuild — no internal feedback loop (e.g. viewmodel reset
        //    causing signal re-emission causing another rebuild).
        expect(
          inputBuilds.value - buildsAfterLoad,
          forcedRebuilds,
          reason:
              'DeskImageInput subtree should rebuild exactly once per parent '
              'rebuild — extra rebuilds indicate viewmodel churn',
        );
      },
    );

    testWidgets(
      'parent rebuild with different value DOES re-init viewmodel',
      (tester) async {
        final dataSource = MockDataSource();
        final assetA = MediaAsset(
          id: '1',
          assetId: 'asset-a',
          fileName: 'a.png',
          mimeType: 'image/png',
          fileSize: 1024,
          publicUrl: 'https://cdn.example.com/a.png',
          width: 100,
          height: 100,
          hasAlpha: false,
          blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
          createdAt: DateTime(2026),
          metadataStatus: MediaAssetMetadataStatus.complete,
        );
        final assetB = MediaAsset(
          id: '2',
          assetId: 'asset-b',
          fileName: 'b.png',
          mimeType: 'image/png',
          fileSize: 1024,
          publicUrl: 'https://cdn.example.com/b.png',
          width: 100,
          height: 100,
          hasAlpha: false,
          blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
          createdAt: DateTime(2026),
          metadataStatus: MediaAssetMetadataStatus.complete,
        );
        when(
          () => dataSource.getMediaAsset('asset-a'),
        ).thenAnswer((_) async => assetA);
        when(
          () => dataSource.getMediaAsset('asset-b'),
        ).thenAnswer((_) async => assetB);

        final currentAssetId = ValueNotifier<String>('asset-a');

        await tester.pumpWidget(
          buildInputApp(
            ValueListenableBuilder<String>(
              valueListenable: currentAssetId,
              builder: (_, id, _) => DeskImageInput(
                field: field,
                data: DeskData(
                  value: <String, dynamic>{
                    '_type': 'imageReference',
                    'assetId': id,
                  },
                  path: 'hero',
                ),
                dataSource: dataSource,
              ),
            ),
          ),
        );

        await tester.pump();
        verify(() => dataSource.getMediaAsset('asset-a')).called(1);

        // Switch to a genuinely different value.
        currentAssetId.value = 'asset-b';
        await tester.pump();

        verify(() => dataSource.getMediaAsset('asset-b')).called(1);
      },
    );

    testWidgets('remove does not cause cascading rebuilds', (tester) async {
      final siblingBuilds = ValueNotifier<int>(0);
      final dataSource = MockDataSource();

      await tester.pumpWidget(
        buildInputApp(
          Column(
            children: [
              DeskImageInput(
                field: field,
                data: const DeskData(
                  value: {
                    '_type': 'imageReference',
                    'externalUrl': 'https://example.com/photo.jpg',
                  },
                  path: 'hero',
                ),
                dataSource: dataSource,
              ),
              BuildTracker(
                counter: siblingBuilds,
                child: const Text('sibling'),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      final buildsBeforeRemove = siblingBuilds.value;

      // Tap remove
      final removeButton = find.byKey(const ValueKey('remove_button'));
      if (removeButton.evaluate().isNotEmpty) {
        await tester.tap(removeButton);
        await tester.pump();
      }

      await tester.pump();

      expect(
        siblingBuilds.value,
        buildsBeforeRemove,
        reason: 'Removing an image should not cause sibling widgets to rebuild',
      );
    });

    // Original bug: image input inside an array-of-objects loses state when
    // any sibling field in the same item is edited. Typing in the String
    // sub-field triggers _DeskArrayInputState.setState (line 324 of
    // array_input.dart), rebuilding the whole inline editor; the image
    // input gets a fresh DeskData wrapper and used to call resetForNewData.
    testWidgets(
      'typing in a sibling String field does not reset the image input '
      "in the same array item",
      (tester) async {
        final dataSource = MockDataSource();
        final asset = MediaAsset(
          id: '1',
          assetId: 'asset-hero',
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
        when(
          () => dataSource.getMediaAsset('asset-hero'),
        ).thenAnswer((_) async => asset);

        // The default DeskImageField builder reads its DataSource from
        // GetIt; in this test we inject the mock directly.
        DeskFieldInputRegistry.register<DeskImageField>(
          (f, data, onChanged) => DeskImageInput(
            key: ValueKey(f!.name),
            field: f as DeskImageField,
            data: data,
            dataSource: dataSource,
            onChanged: (value) => onChanged(f.name, value),
          ),
        );
        addTearDown(() {
          DeskFieldInputRegistry.register<DeskImageField>(
            (_, _, _) => const SizedBox.shrink(),
          );
        });

        // Inner field: an object with { caption: String, image: Image }.
        const innerObject = DeskObjectField(
          name: 'item',
          title: 'Gallery Item',
          option: DeskObjectOption(
            children: [
              ColumnFields(
                children: [
                  DeskStringField(name: 'caption', title: 'Caption'),
                  DeskImageField(
                    name: 'image',
                    title: 'Image',
                    option: DeskImageOption(hotspot: false),
                  ),
                ],
              ),
            ],
          ),
        );

        final arrayField = DeskArrayField<Map<String, dynamic>>(
          name: 'gallery',
          title: 'Gallery',
          innerField: innerObject,
          fromMap: (m) => Map<String, dynamic>.from(m),
        );

        await tester.pumpWidget(
          buildInputApp(
            DeskArrayInput<Map<String, dynamic>>(
              field: arrayField,
              data: DeskData(
                value: [
                  <String, dynamic>{
                    'caption': 'hi',
                    'image': <String, dynamic>{
                      '_type': 'imageReference',
                      'assetId': 'asset-hero',
                    },
                  },
                ],
                path: 'gallery',
              ),
            ),
          ),
        );
        await tester.pump();

        // Open the inline editor for the seeded item (pencil icon).
        await tester.tap(find.byIcon(FontAwesomeIcons.pen).first);
        await tester.pump();

        // Image input mounts and fetches the asset exactly once.
        verify(() => dataSource.getMediaAsset('asset-hero')).called(1);

        // Real user interaction: type into the Caption field. This fires
        // the inner editor's onChanged → array's setState(_editingValue) →
        // whole inline editor rebuilds → image input gets fresh DeskData.
        final captionField = find.byType(ShadInputFormField).first;
        await tester.enterText(captionField, 'updated caption');
        await tester.pump();
        await tester.enterText(captionField, 'updated caption!!');
        await tester.pump();
        await tester.enterText(captionField, 'final caption');
        await tester.pump();

        // The image input must NOT have re-fetched on any of those keystrokes.
        verifyNever(() => dataSource.getMediaAsset(any()));
      },
    );
  });
}
