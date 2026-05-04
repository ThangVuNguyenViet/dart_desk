// Screen-level goldens for the desk_app studio.
//
// Goldens are pixel-pinned for Linux. Regenerate with:
//   make goldens-screens   (from examples/desk_app/)
// Capturing on macOS will produce diffs vs. CI — always regen in Docker.
import 'dart:io';

import 'package:dart_desk/testing.dart';
import 'package:data_models/example_data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import 'screen_test_helpers.dart';

/// Desktop viewport for full-app captures. Studio shell breakpoint is
/// `desktop` above 1024 (`DeskBreakpoints.tablet`); 1280 gives headroom.
const _desktop = BoxConstraints.tightFor(width: 1280, height: 800);

const _chefSidebarKey = ValueKey("doc_type_Chef's Choice");
const _mediaButtonKey = ValueKey('sidebar_media_button');
const _versionButtonKey = ValueKey('version_history_button');

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
          tolerancePx: kGoldenTolerancePx,
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
          tolerancePx: kGoldenTolerancePx,
          id: 'chef_list_one_doc',
          description: 'document list — chef profile (1 doc)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedShowcaseChef(source);
            await _pumpAndOpenChefList(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'chef_list_many_docs',
          description: 'document list — chef profile (5 docs)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedManyChefDocs(source, count: 5);
            await _pumpAndOpenChefList(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'document_editor_all_fields',
          description: 'editor — chef profile (all fields populated)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedChefWith(
              source,
              ChefConfigFixtures.allFieldsPopulated(),
            );
            await _pumpAndOpenChefDoc(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'document_editor_empty_defaults',
          description: 'editor — chef profile (empty defaults)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedChefWith(source, ChefConfigFixtures.empty());
            await _pumpAndOpenChefDoc(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'document_editor_validation_error',
          description: 'editor — chef profile (required field empty)',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedChefWith(
              source,
              ChefConfigFixtures.withValidationError(),
            );
            await _pumpAndOpenChefDoc(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'media_gallery_populated',
          description: 'media library — 4 seeded assets',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource()..seedDefaults();
            await _pumpAndOpenMedia(tester, scaffold, source);
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'media_gallery_empty',
          description: 'media library — empty state',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            await _pumpAndOpenMedia(tester, scaffold, MockDataSource());
          },
        )
        .itemFromPumper(
          tolerancePx: kGoldenTolerancePx,
          id: 'version_history_panel',
          description: 'editor — version history popover open',
          constraints: _desktop,
          pumper: (tester, scaffold, _) async {
            final source = MockDataSource();
            await seedChefWithVersions(source);
            await _pumpAndOpenChefDoc(tester, scaffold, source);
            await tester.tap(find.byKey(_versionButtonKey));
            await tester.pumpAndSettle();
          },
        )
        // TODO: mobile_layout — DeskTopBar overflows at 390×844 because the
        // breadcrumb + theme toggle + version selector + avatar row never had
        // a mobile constraint applied. Fix needs a responsive top bar in
        // packages/dart_desk; gated behind that work.
        .run(tester);
  });
}

/// Pumps the app, lets the shell auto-nav settle, then taps the Chef sidebar
/// entry so the chef-profile document list panel is on screen.
Future<void> _pumpAndOpenChefList(
  WidgetTester tester,
  Widget Function(WidgetTester, Widget) scaffold,
  MockDataSource source,
) async {
  final app = await buildScreenApp(source);
  await tester.pumpWidget(scaffold(tester, app));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(_chefSidebarKey));
  await tester.pumpAndSettle();
}

/// Pumps the app, opens the chef list, then taps the first doc card to drop
/// into the editor for the seeded chef document.
Future<void> _pumpAndOpenChefDoc(
  WidgetTester tester,
  Widget Function(WidgetTester, Widget) scaffold,
  MockDataSource source,
) async {
  await _pumpAndOpenChefList(tester, scaffold, source);
  // Doc cards aren't keyed; the title is unique per scene.
  await tester.tap(find.text("Marco's Choice").first);
  await tester.pumpAndSettle();
}

/// Pumps the app and taps the Media Library footer button to open the gallery.
Future<void> _pumpAndOpenMedia(
  WidgetTester tester,
  Widget Function(WidgetTester, Widget) scaffold,
  MockDataSource source,
) async {
  final app = await buildScreenApp(source);
  await tester.pumpWidget(scaffold(tester, app));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(_mediaButtonKey));
  await tester.pumpAndSettle();
}
