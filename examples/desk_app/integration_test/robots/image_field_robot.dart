import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/settle.dart';

class ImageFieldRobot {
  final WidgetTester tester;
  ImageFieldRobot(this.tester);

  Finder _field(String fieldKey) =>
      find.byKey(ValueKey('image_input_$fieldKey'));

  Future<void> tapUpload(String fieldKey) async {
    await tester.tap(
      find.descendant(
        of: _field(fieldKey),
        matching: find.byKey(const ValueKey('upload_button')),
      ),
    );
    await tester.settle(const Duration(seconds: 3));
  }

  Future<void> tapBrowseMedia(String fieldKey) async {
    await tester.tap(
      find.descendant(
        of: _field(fieldKey),
        matching: find.byKey(const ValueKey('browse_media_button')),
      ),
    );
    await tester.settle(const Duration(seconds: 3));
  }

  Future<void> tapRemove(String fieldKey) async {
    await tester.tap(
      find.descendant(
        of: _field(fieldKey),
        matching: find.byKey(const ValueKey('remove_button')),
      ),
    );
    await tester.settle();
  }

  Future<void> enterUrl(String fieldKey, String url) async {
    final urlInput = find.descendant(
      of: _field(fieldKey),
      matching: find.byKey(const ValueKey('url_input')),
    );
    await tester.enterText(urlInput, url);
    await tester.settle();
  }

  Future<void> expectImagePreview(String fieldKey) async {
    final field = _field(fieldKey);
    final removeFinder = find.descendant(
      of: field,
      matching: find.byKey(const ValueKey('remove_button')),
    );
    final imageFinder = find.descendant(
      of: field,
      matching: find.byType(Image),
    );
    for (var i = 0; i < 15; i++) {
      if (imageFinder.evaluate().isNotEmpty) return;
      if (removeFinder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(seconds: 1));
    }
    expect(imageFinder, findsOneWidget);
  }

  void expectFieldEmpty(String fieldKey) {
    final field = _field(fieldKey);
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('upload_button')),
      ),
      findsOneWidget,
    );
    // In empty state, the editable URL input should be present
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('url_input')),
      ),
      findsOneWidget,
    );
  }

  void expectReadOnlyUrl(String fieldKey) {
    final field = _field(fieldKey);
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('url_display')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('url_input')),
      ),
      findsNothing,
    );
  }

  void expectEditableUrl(String fieldKey) {
    final field = _field(fieldKey);
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('url_input')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: field,
        matching: find.byKey(const ValueKey('url_display')),
      ),
      findsNothing,
    );
  }
}
