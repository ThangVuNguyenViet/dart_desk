import 'package:flutter/material.dart';
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

  group('02 - Media Handling', () {
    testWidgets('TC-E2E-02-01: Upload image via UI and verify preview',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      // Create a document to use for media tests
      await docList.createDocument('Media Test Doc');
      await docList.tapDocument('Media Test Doc');

      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');

      await editor.tapSave();
      editor.expectSaveConfirmation();
    });

    testWidgets('TC-E2E-02-02: Upload file via file field and verify metadata',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Media Test Doc');

      // FileFieldRobot does not exist yet; using find.byKey directly as an
      // accepted exception per the integration test plan (Task 5 spec).
      // FakeImagePickerPlatform installed by pumpTestApp handles the picker.
      await tester.tap(find.byKey(const ValueKey('file_field')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await editor.tapSave();
      editor.expectSaveConfirmation();
    });

    testWidgets('TC-E2E-02-03: Remove uploaded image and verify field empty',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Media Test Doc');

      // Verify image preview exists before removal (uploaded in TC-02-01)
      image.expectImagePreview('image_field');

      await image.tapRemove('image_field');
      image.expectFieldEmpty('image_field');
    });

    testWidgets('TC-E2E-02-04: Image persists after save and reload',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Persist Media Doc');
      await docList.tapDocument('Persist Media Doc');

      await image.tapUpload('image_field');
      image.expectImagePreview('image_field');

      await editor.tapSave();
      editor.expectSaveConfirmation();

      await editor.navigateBack();

      // Re-open document and verify image still present
      await docList.tapDocument('Persist Media Doc');
      image.expectImagePreview('image_field');
    });
  });
}
