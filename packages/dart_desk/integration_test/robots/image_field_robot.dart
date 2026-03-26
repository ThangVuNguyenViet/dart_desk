import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ImageFieldRobot {
  final WidgetTester tester;
  ImageFieldRobot(this.tester);

  Future<void> tapUpload(String fieldKey) async {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    await tester.tap(find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('upload_button')),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> tapRemove(String fieldKey) async {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    await tester.tap(find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('remove_button')),
    ));
    await tester.pumpAndSettle();
  }

  void expectImagePreview(String fieldKey) {
    final field = find.byKey(ValueKey('image_input_$fieldKey'));
    expect(
      find.descendant(of: field, matching: find.byType(Image)),
      findsOneWidget,
    );
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
