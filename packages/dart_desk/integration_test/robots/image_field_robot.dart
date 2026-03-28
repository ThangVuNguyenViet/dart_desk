import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/settle.dart';

class ImageFieldRobot {
  final WidgetTester tester;
  ImageFieldRobot(this.tester);

  Future<void> tapUpload(String fieldKey) async {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    await tester.tap(find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('upload_button')),
    ));
    await tester.settle(const Duration(seconds: 3));
  }

  Future<void> tapRemove(String fieldKey) async {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    await tester.tap(find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('remove_button')),
    ));
    await tester.settle();
  }

  Future<void> expectImagePreview(String fieldKey) async {
    // Image loading involves a chain of sequential async HTTP calls (document
    // data → version data → image asset). pumpAndSettle exits when no frames
    // are scheduled, which can happen between HTTP calls. Use explicit 1s pumps
    // instead: each pump(1s) advances real time by 1s (allowing HTTP responses
    // to arrive) then processes one frame. Repeat until Image widget appears.
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    // Also poll for remove_button: it appears when _imageRef != null, even
    // before the Image.network widget settles (same render pass). If
    // remove_button is found but Image is not, we still have a loaded ref.
    final removeFinder = find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('remove_button')),
    );
    final imageFinder = find.descendant(of: field, matching: find.byType(Image));
    for (var i = 0; i < 15; i++) {
      if (imageFinder.evaluate().isNotEmpty) return;
      if (removeFinder.evaluate().isNotEmpty) return; // _imageRef is set
      await tester.pump(const Duration(seconds: 1));
    }
    expect(imageFinder, findsOneWidget);
  }

  void expectFieldEmpty(String fieldKey) {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('upload_button')),
      ),
      findsOneWidget,
    );
  }
}
