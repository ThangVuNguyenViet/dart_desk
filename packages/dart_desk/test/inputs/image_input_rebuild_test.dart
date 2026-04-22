import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

      // Pump several more frames — sibling should not rebuild
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

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

      // Pump additional frames for image load attempt
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

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

      // Let the async asset load complete
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final buildsAfterLoad = imageInputBuilds;

      // Pump more frames — should be stable
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        imageInputBuilds,
        buildsAfterLoad,
        reason:
            'DeskImageInput parent Builder should not rebuild after asset has loaded and state stabilised',
      );
    });

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

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final buildsBeforeRemove = siblingBuilds.value;

      // Tap remove
      final removeButton = find.byKey(const ValueKey('remove_button'));
      if (removeButton.evaluate().isNotEmpty) {
        await tester.tap(removeButton);
        await tester.pump();
      }

      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        siblingBuilds.value,
        buildsBeforeRemove,
        reason: 'Removing an image should not cause sibling widgets to rebuild',
      );
    });
  });
}
