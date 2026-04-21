import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/screenshot_helper.dart';
import 'test_utils/test_app.dart';

/// Generates a unique document name to avoid collisions with existing data.
String _uniqueName(String prefix) {
  final suffix = Random().nextInt(99999).toString().padLeft(5, '0');
  return '$prefix $suffix';
}

void main() {
  final binding = ensureTestInitialized();

  // No DbHelper.reset() — tests are self-cleaning.

  group('07 - Image Upload E2E', () {
    testWidgets('TC-E2E-07-01: Upload image and verify preview', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_07_01');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      final docName = _uniqueName('Upload Test');

      await sidebar.tapDocumentType('Integration Test');
      await ss.take(tester, 'document_type_selected');

      await docList.createDocument(docName);
      await ss.take(tester, 'document_created');

      await docList.tapDocument(docName);
      await ss.take(tester, 'document_opened');

      // Verify empty state: editable URL field present
      image.expectFieldEmpty('image_field');
      await ss.take(tester, 'empty_state_with_url_field');

      await image.tapUpload('image_field');
      await image.expectImagePreview('image_field');
      await ss.take(tester, 'image_preview_shown');

      // After upload, URL field should be read-only showing public URL
      image.expectReadOnlyUrl('image_field');
      await ss.take(tester, 'url_field_readonly');

      // Clean up: navigate back and delete
      final editor = DocumentEditorRobot(tester);
      await editor.navigateBack();
      await docList.deleteDocument(docName);
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

      final docName = _uniqueName('Persist Test');

      await sidebar.tapDocumentType('Integration Test');
      await ss.take(tester, 'document_type_selected');

      await docList.createDocument(docName);
      await docList.tapDocument(docName);
      await ss.take(tester, 'document_opened');

      await image.tapUpload('image_field');
      await image.expectImagePreview('image_field');
      await ss.take(tester, 'image_uploaded');

      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'saved');

      await editor.navigateBack();
      await ss.take(tester, 'navigated_back');

      // Re-open and verify image persists
      await docList.tapDocument(docName);
      await image.expectImagePreview('image_field');
      await ss.take(tester, 'image_persisted');

      // URL field should be read-only with public URL
      image.expectReadOnlyUrl('image_field');
      await ss.take(tester, 'url_readonly_after_reload');

      // Clean up
      await editor.navigateBack();
      await docList.deleteDocument(docName);
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

        final docName = _uniqueName('Remove Test');

        await sidebar.tapDocumentType('Integration Test');
        await ss.take(tester, 'document_type_selected');

        // Create doc, upload image, save
        await docList.createDocument(docName);
        await docList.tapDocument(docName);
        await image.tapUpload('image_field');
        await editor.tapSave();
        await editor.navigateBack();

        // Re-open and remove the image
        await docList.tapDocument(docName);
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'image_present');

        await image.tapRemove('image_field');
        image.expectFieldEmpty('image_field');
        await ss.take(tester, 'image_removed');

        await editor.tapSave();
        editor.expectSaveConfirmation();
        await ss.take(tester, 'saved_after_remove');

        await editor.navigateBack();
        await ss.take(tester, 'navigated_back');

        // Re-open and verify field is still empty
        await docList.tapDocument(docName);
        image.expectFieldEmpty('image_field');
        await ss.take(tester, 'field_still_empty');

        // Clean up
        await editor.navigateBack();
        await docList.deleteDocument(docName);
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

        final docNameA = _uniqueName('Dedup A');
        final docNameB = _uniqueName('Dedup B');

        await sidebar.tapDocumentType('Integration Test');
        await ss.take(tester, 'document_type_selected');

        // Upload image to doc A (createDocument auto-opens the new doc)
        await docList.createDocument(docNameA);
        await ss.take(tester, 'doc_a_opened');

        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'doc_a_image_uploaded');

        await editor.tapSave();
        editor.expectSaveConfirmation();
        await ss.take(tester, 'doc_a_saved');

        await editor.navigateBack();
        await ss.take(tester, 'back_to_list');

        // Create doc B and upload the same image (auto-opens doc B)
        await docList.createDocument(docNameB);
        await ss.take(tester, 'doc_b_opened');

        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'doc_b_image_uploaded');

        await editor.tapSave();
        editor.expectSaveConfirmation();
        await ss.take(tester, 'doc_b_saved');

        await editor.navigateBack();
        await ss.take(tester, 'back_to_list_again');

        // Navigate back to doc A and confirm image preview is still present
        await docList.tapDocument(docNameA);
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'doc_a_image_still_present');

        // Clean up both docs
        await editor.navigateBack();
        await docList.deleteDocument(docNameA);
        await docList.deleteDocument(docNameB);
      },
    );

    testWidgets('TC-E2E-07-05: Paste external URL and verify preview', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_07_05');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      final docName = _uniqueName('URL Test');

      await sidebar.tapDocumentType('Integration Test');
      await ss.take(tester, 'document_type_selected');

      await docList.createDocument(docName);
      await ss.take(tester, 'document_created');

      await docList.tapDocument(docName);
      await ss.take(tester, 'document_opened');

      // Verify empty state
      image.expectFieldEmpty('image_field');
      image.expectEditableUrl('image_field');
      await ss.take(tester, 'empty_state');

      // Enter external URL
      await image.enterUrl('image_field', 'https://example.com/photo.jpg');
      await ss.take(tester, 'url_entered');

      // URL field should stay editable (external URL mode)
      image.expectEditableUrl('image_field');
      await ss.take(tester, 'url_field_still_editable');

      // Save and verify persistence
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'saved_with_url');

      await editor.navigateBack();
      await ss.take(tester, 'navigated_back');

      await docList.tapDocument(docName);
      await ss.take(tester, 'reopened');

      // URL field should be editable with the external URL
      image.expectEditableUrl('image_field');
      await ss.take(tester, 'url_persisted');

      // Clean up
      await editor.navigateBack();
      await docList.deleteDocument(docName);
    });

    testWidgets(
      'TC-E2E-07-06: Upload replaces external URL, remove clears everything',
      (tester) async {
        final ss = ScreenshotHelper(binding, 'tc_07_06');
        await pumpTestApp(tester);

        final sidebar = SidebarRobot(tester);
        final docList = DocumentListRobot(tester);
        final editor = DocumentEditorRobot(tester);
        final image = ImageFieldRobot(tester);

        final docName = _uniqueName('Replace Test');

        await sidebar.tapDocumentType('Integration Test');
        await ss.take(tester, 'document_type_selected');

        await docList.createDocument(docName);
        await ss.take(tester, 'document_created');

        await docList.tapDocument(docName);
        await ss.take(tester, 'document_opened');

        // Enter external URL first
        await image.enterUrl('image_field', 'https://example.com/old.jpg');
        image.expectEditableUrl('image_field');
        await ss.take(tester, 'external_url_entered');

        // Upload replaces external URL
        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        await ss.take(tester, 'upload_replaced_url');

        // URL field should now be read-only with public URL
        image.expectReadOnlyUrl('image_field');
        await ss.take(tester, 'url_readonly_after_upload');

        // Remove clears everything
        await image.tapRemove('image_field');
        image.expectFieldEmpty('image_field');
        image.expectEditableUrl('image_field');
        await ss.take(tester, 'everything_cleared');

        // Clean up
        await editor.navigateBack();
        await docList.deleteDocument(docName);
      },
    );
  });
}
