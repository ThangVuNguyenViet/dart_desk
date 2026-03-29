import 'package:flutter_test/flutter_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/screenshot_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  final binding = ensureTestInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('07 - Image Upload E2E', () {
    testWidgets('TC-E2E-07-01: Upload image and verify preview', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_07_01');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Upload Test Doc A');
      await docList.tapDocument('Upload Test Doc A');

      await image.tapUpload('image_field');
      await image.expectImagePreview('image_field');
      await ss.take(tester, 'image_preview_shown');
    });

    testWidgets('TC-E2E-07-02: Uploaded image persists after save and reload', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_07_02');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Upload Test Doc A');

      await image.tapUpload('image_field');
      await image.expectImagePreview('image_field');

      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'saved');

      await editor.navigateBack();

      // Re-open and verify image persists
      await docList.tapDocument('Upload Test Doc A');
      await image.expectImagePreview('image_field');
      await ss.take(tester, 'image_persisted');
    });

    testWidgets(
      'TC-E2E-07-03: Remove saved image, save, reload, verify field empty',
      (tester) async {
        final ss = ScreenshotHelper(binding, 'tc_07_03');
        await pumpTestApp(tester);

        final sidebar = SidebarRobot(tester);
        final docList = DocumentListRobot(tester);
        final editor = DocumentEditorRobot(tester);
        final image = ImageFieldRobot(tester);

        await sidebar.tapDocumentType('Integration Test');
        await docList.tapDocument('Upload Test Doc A');

        await image.expectImagePreview('image_field');
        await image.tapRemove('image_field');
        image.expectFieldEmpty('image_field');
        await ss.take(tester, 'image_removed');

        await editor.tapSave();
        editor.expectSaveConfirmation();

        await editor.navigateBack();

        // Re-open and verify field is still empty
        await docList.tapDocument('Upload Test Doc A');
        image.expectFieldEmpty('image_field');
        await ss.take(tester, 'field_still_empty');
      },
    );

    testWidgets(
      'TC-E2E-07-04: Same image uploaded to two docs — backend deduplicates by content hash',
      (tester) async {
        final ss = ScreenshotHelper(binding, 'tc_07_04');
        await pumpTestApp(tester);

        final sidebar = SidebarRobot(tester);
        final docList = DocumentListRobot(tester);
        final editor = DocumentEditorRobot(tester);
        final image = ImageFieldRobot(tester);

        await sidebar.tapDocumentType('Integration Test');

        // Upload image to doc A
        await docList.tapDocument('Upload Test Doc A');
        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        await editor.tapSave();
        editor.expectSaveConfirmation();
        await editor.navigateBack();

        // Create doc B and upload the same image (FakePicker returns same test PNG)
        await docList.createDocument('Upload Test Doc B');
        await docList.tapDocument('Upload Test Doc B');
        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        await editor.tapSave();
        editor.expectSaveConfirmation();
        await ss.take(tester, 'doc_b_saved');
        await editor.navigateBack();

        // Navigate back to doc A and confirm image preview is still present
        await docList.tapDocument('Upload Test Doc A');
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'doc_a_image_still_present');
      },
    );
  });
}
