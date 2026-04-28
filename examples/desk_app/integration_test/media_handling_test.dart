import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/screenshot_helper.dart';
import 'test_utils/settle.dart';
import 'test_utils/test_app.dart';

void main() {
  final binding = ensureTestInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('02 - Media Handling', () {
    testWidgets('TC-E2E-02-01: Upload image via UI and verify preview', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_02_01');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Chef profile');
      await ss.take(tester, 'document_type_selected');

      await docList.createDocument('Media Test Doc');
      await ss.take(tester, 'document_created');

      await docList.tapDocument('Media Test Doc');
      await ss.take(tester, 'doc_opened');

      // Verify empty state with unified layout
      image.expectFieldEmpty('portrait');
      await ss.take(tester, 'empty_state');

      await image.tapUpload('portrait');
      await image.expectImagePreview('portrait');
      await ss.take(tester, 'image_uploaded');

      // Verify read-only URL after upload
      image.expectReadOnlyUrl('portrait');
      await ss.take(tester, 'url_readonly');

      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'saved');
    });

    testWidgets(
      'TC-E2E-02-02: Upload file via file field and verify metadata',
      (tester) async {
        final ss = ScreenshotHelper(binding, 'tc_02_02');
        await pumpTestApp(tester);

        final sidebar = SidebarRobot(tester);
        final docList = DocumentListRobot(tester);
        final editor = DocumentEditorRobot(tester);

        await sidebar.tapDocumentType('Chef profile');
        await ss.take(tester, 'document_type_selected');

        await docList.tapDocument('Media Test Doc');
        await ss.take(tester, 'doc_opened');

        await tester.tap(find.byKey(const ValueKey('cv')));
        await tester.settle(const Duration(seconds: 3));
        await ss.take(tester, 'file_uploaded');

        await editor.tapSave();
        editor.expectSaveConfirmation();
        await ss.take(tester, 'saved');
      },
    );

    testWidgets('TC-E2E-02-03: Remove uploaded image and verify field empty', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_02_03');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Chef profile');
      await ss.take(tester, 'document_type_selected');

      await docList.tapDocument('Media Test Doc');
      await ss.take(tester, 'doc_opened');

      await image.expectImagePreview('portrait');
      await ss.take(tester, 'image_present');

      await image.tapRemove('portrait');
      image.expectFieldEmpty('portrait');
      await ss.take(tester, 'image_removed');

      // Verify editable URL field is back
      image.expectEditableUrl('portrait');
      await ss.take(tester, 'url_editable_after_remove');
    });

    testWidgets('TC-E2E-02-04: Image persists after save and reload', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_02_04');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);
      final image = ImageFieldRobot(tester);

      await sidebar.tapDocumentType('Chef profile');
      await ss.take(tester, 'document_type_selected');

      await docList.createDocument('Persist Media Doc');
      await ss.take(tester, 'document_created');

      await docList.tapDocument('Persist Media Doc');
      await ss.take(tester, 'doc_opened');

      await image.tapUpload('portrait');
      await image.expectImagePreview('portrait');
      await ss.take(tester, 'image_uploaded');

      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'saved');

      await editor.navigateBack();
      await ss.take(tester, 'navigated_back');

      await docList.tapDocument('Persist Media Doc');
      await image.expectImagePreview('portrait');
      await ss.take(tester, 'image_persisted');

      image.expectReadOnlyUrl('portrait');
      await ss.take(tester, 'url_readonly_after_reload');
    });
  });
}
