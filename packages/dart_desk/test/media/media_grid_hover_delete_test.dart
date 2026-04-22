import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:dart_desk/src/media/browser/media_browser_state.dart';
import 'package:dart_desk/src/media/browser/media_grid.dart';
import 'package:dart_desk/testing.dart';

void main() {
  testWidgets('shows trash button on hover and hides off-hover',
      (tester) async {
    final state = MediaBrowserState(dataSource: MockDataSource());
    addTearDown(state.dispose);

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: MediaGrid(state: state),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey &&
          (w.key as ValueKey).value.toString().startsWith('media_grid_item_'),
    ).first;
    expect(tile, findsOneWidget);

    final trashFinder = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey &&
          (w.key as ValueKey).value.toString().startsWith('media_grid_trash_'),
    ).first;

    // Pre-hover
    final beforeOpacity = tester.widget<AnimatedOpacity>(
      find.ancestor(of: trashFinder, matching: find.byType(AnimatedOpacity)).first,
    );
    expect(beforeOpacity.opacity, equals(0));

    // Hover
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(() async => gesture.removePointer());
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(tile));
    await tester.pumpAndSettle();

    final afterOpacity = tester.widget<AnimatedOpacity>(
      find.ancestor(of: trashFinder, matching: find.byType(AnimatedOpacity)).first,
    );
    expect(afterOpacity.opacity, equals(1));
  });
}
