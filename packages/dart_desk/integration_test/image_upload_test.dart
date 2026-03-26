import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('07 - Image Upload E2E', () {
    testWidgets('TC-E2E-07-01: Upload image and verify preview',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Upload Test Doc A');
      await docList.tapDocument('Upload Test Doc A');

      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
    });

    testWidgets('TC-E2E-07-02: Uploaded image persists after save and reload',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Upload Test Doc A');

      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');

      await editor.tapSave();
      editor.expectSaveConfirmation();

      await editor.navigateBack();

      // Re-open and verify image persists
      await docList.tapDocument('Upload Test Doc A');
      image.expectImagePreview('image_field');
    });

    testWidgets(
        'TC-E2E-07-03: Remove saved image, save, reload, verify field empty',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      // Open doc with saved image from TC-E2E-07-02
      await docList.tapDocument('Upload Test Doc A');

      image.expectImagePreview('image_field');
      await image.tapRemove('image_field');
      image.expectFieldEmpty('image_field');

      await editor.tapSave();
      editor.expectSaveConfirmation();

      await editor.navigateBack();

      // Re-open and verify field is still empty
      await docList.tapDocument('Upload Test Doc A');
      image.expectFieldEmpty('image_field');
    });

    testWidgets(
        'TC-E2E-07-04: Same image uploaded to two docs — backend deduplicates by content hash',
        (tester) async {
      // FakeImagePickerPlatform always returns the same test PNG bytes, so
      // uploading to two separate documents exercises the backend's content-hash
      // deduplication logic. The single asset entry can be confirmed via:
      //   curl http://localhost:8080/api/media/list
      // Both documents should reference the same assetId. This is verified at the
      // backend level only; here we confirm both docs show an image preview.
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');

      // Upload image to doc A
      await docList.tapDocument('Upload Test Doc A');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Create doc B and upload the same image (FakePicker returns same test PNG)
      await docList.createDocument('Upload Test Doc B');
      await docList.tapDocument('Upload Test Doc B');
      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Navigate back to doc A and confirm image preview is still present
      await docList.tapDocument('Upload Test Doc A');
      image.expectImagePreview('image_field');
    });
  });
}
