// Screen-level goldens for the desk_app studio.
//
// Goldens are pixel-pinned for Linux. Regenerate with:
//   make goldens-screens   (from examples/desk_app/)
// Capturing on macOS will produce diffs vs. CI — always regen in Docker.
import 'dart:io';

import 'package:dart_desk/testing.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import 'screen_test_helpers.dart';

/// Desktop-class viewport for full-app screen captures. Studio shell breakpoint
/// is `desktop` above 1024 (`DeskBreakpoints.tablet`); use 1280 for headroom.
const _desktop = BoxConstraints.tightFor(width: 1280, height: 800);

void main() {
  setUpAll(installScreenGoldenMocks);
  tearDown(resetGetItForScreenGolden);

  testGoldenScene('Studio screens gallery', (tester) async {
    await Gallery(
      'DartDesk studio — canonical screens',
      directory: Directory('goldens'),
      fileName: 'studio_screens_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromPumper(
          id: 'empty_studio',
          description: 'empty studio (no documents)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final app = await buildScreenApp(MockDataSource());
            await tester.pumpWidget(scaffold(tester, app));
            await tester.pump(const Duration(seconds: 2));
          },
        )
        .itemFromPumper(
          id: 'chef_list_one_doc',
          description: 'document list — chef profile (1 doc)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedShowcaseChef(source);
            final app = await buildScreenApp(source);
            await tester.pumpWidget(scaffold(tester, app));
            await tester.pump(const Duration(seconds: 2));
          },
        )
        .run(tester);
  });
}
