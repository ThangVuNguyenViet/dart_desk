import 'package:dart_desk/src/media/browser/asset_detail_panel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/settle.dart';

class MediaLibraryRobot {
  final WidgetTester tester;
  MediaLibraryRobot(this.tester);

  Future<void> openMediaLibrary() async {
    await tester.tap(find.byKey(const ValueKey('sidebar_media_button')));
    await tester.settle();
  }

  Finder tileAt(int index) {
    return find
        .byWidgetPredicate(
          (w) =>
              w.key is ValueKey &&
              (w.key as ValueKey).value.toString().startsWith('media_grid_item_'),
        )
        .at(index);
  }

  Future<void> hoverTile(int index) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(tileAt(index)));
    await tester.pumpAndSettle();
  }

  Future<void> tapTrash(int index) async {
    final trash = find.descendant(
      of: tileAt(index),
      matching: find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey &&
            (w.key as ValueKey).value
                .toString()
                .startsWith('media_grid_trash_'),
      ),
    );
    await tester.tap(trash, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> confirmDelete() async {
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }

  Future<void> cancelDelete() async {
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  }

  Future<void> closeInUseDialog() async {
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  }

  void expectDetailPanelVisible() {
    expect(find.byType(AssetDetailPanel), findsOneWidget);
  }

  int visibleTileCount() => find
      .byWidgetPredicate(
        (w) =>
            w.key is ValueKey &&
            (w.key as ValueKey).value
                .toString()
                .startsWith('media_grid_item_'),
      )
      .evaluate()
      .length;
}
