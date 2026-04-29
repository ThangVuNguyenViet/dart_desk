import 'package:dart_desk/src/media/browser/asset_detail_panel.dart';
import 'package:dart_desk/src/media/browser/media_browser.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets(
    'tapping a tile shows AssetDetailPanel inline (no layout jump)',
    (tester) async {
      final dataSource = MockDataSource()..seedDefaults();
      await tester.pumpWidget(
        ShadApp(
          home: Scaffold(
            body: SizedBox(
              width: 1024,
              height: 700,
              child: MediaBrowser(dataSource: dataSource),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Detail column is always reserved — placeholder before selection.
      expect(find.byType(AssetDetailPanel), findsNothing);
      expect(find.text('Select an asset to see details'), findsOneWidget);

      final firstTile = find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey &&
                (w.key as ValueKey).value.toString().startsWith(
                  'media_grid_item_',
                ),
          )
          .first;

      // Measure tile width before selection.
      final widthBefore = tester.getSize(firstTile).width;

      await tester.tap(firstTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailPanel), findsOneWidget);

      // Grid width must not reflow after selection.
      final widthAfter = tester.getSize(firstTile).width;
      expect(
        (widthAfter - widthBefore).abs() < 1.0,
        isTrue,
        reason: 'Tile width changed: $widthBefore -> $widthAfter',
      );
    },
  );
}
