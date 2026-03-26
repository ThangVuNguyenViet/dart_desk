import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/finders.dart';

class ImageFieldRobot {
  final WidgetTester tester;
  ImageFieldRobot(this.tester);

  /// Taps the "Upload" button for the image input.
  Future<void> tapUpload() async {
    await tester.tap(findByKey('upload_button'));
    await tester.pumpAndSettle();
  }

  /// Taps the "Browse media" button to open the media browser dialog.
  Future<void> tapBrowseMedia() async {
    await tester.tap(findByKey('browse_media_button'));
    await tester.pumpAndSettle();
  }

  /// Taps the "Remove" button to clear the current image.
  Future<void> tapRemove() async {
    await tester.tap(findByKey('remove_button'));
    await tester.pumpAndSettle();
  }

  /// Expects the image preview to be visible (an Image.network widget).
  void expectImagePreviewVisible() {
    expect(find.byType(Image), findsOneWidget);
  }

  /// Expects no image preview (empty/upload placeholder state).
  void expectNoImagePreview() {
    expect(find.text('Drop image or click to upload'), findsOneWidget);
  }

  /// Expects the image input container for a given field name to be visible.
  void expectImageFieldVisible(String fieldName) {
    expect(findByKey('image_input_$fieldName'), findsOneWidget);
  }

  /// Expects the remove button to be visible (image is loaded).
  void expectRemoveButtonVisible() {
    expect(findByKey('remove_button'), findsOneWidget);
  }

  /// Expects the remove button to not be present (no image loaded).
  void expectRemoveButtonNotVisible() {
    expect(findByKey('remove_button'), findsNothing);
  }
}
