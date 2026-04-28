import 'package:flutter_test/flutter_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/screenshot_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  final binding = ensureTestInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('01 - Data Persistence', () {
    testWidgets('TC-E2E-01-01: Create document persists to backend', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_01_01');
      await pumpTestApp(tester);
      await ss.take(tester, 'app_loaded');

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await ss.take(tester, 'doc_type_selected');
      await docList.createDocument('Persistence Test Doc');
      await ss.take(tester, 'document_created');

      docList.expectDocumentVisible('Persistence Test Doc');
    });

    testWidgets('TC-E2E-01-02: Edit persists across reload', (tester) async {
      final ss = ScreenshotHelper(binding, 'tc_01_02');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Persistence Test Doc');
      await ss.take(tester, 'document_opened');
      await editor.enterField('title', 'Updated Value');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await ss.take(tester, 'after_save');
      await editor.navigateBack();

      // Re-open the same document to verify the content field persisted.
      // The list title stays 'Persistence Test Doc' — that's the document
      // metadata title, not the 'title' content field.
      await docList.tapDocument('Persistence Test Doc');
      editor.expectFieldValue('title', 'Updated Value');
      await ss.take(tester, 'value_persisted');
    });

    testWidgets('TC-E2E-01-03: Version history is accurate', (tester) async {
      final ss = ScreenshotHelper(binding, 'tc_01_03');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Persistence Test Doc');
      await editor.enterField('body', 'Some body text for version history');
      await editor.tapSave();
      editor.expectSaveConfirmation();

      // Version history panel should show at least one version entry
      await editor.expectVersionHistoryShown();
      await ss.take(tester, 'version_history_visible');
    });

    testWidgets('TC-E2E-01-04: Delete removes from backend', (tester) async {
      final ss = ScreenshotHelper(binding, 'tc_01_04');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Doc To Delete');
      docList.expectDocumentVisible('Doc To Delete');
      await ss.take(tester, 'doc_created');

      await docList.deleteDocument('Doc To Delete');
      await ss.take(tester, 'doc_deleted');

      docList.expectDocumentNotVisible('Doc To Delete');
    });

    testWidgets('TC-E2E-01-05: Publish version from history', (tester) async {
      final ss = ScreenshotHelper(binding, 'tc_01_05');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Persistence Test Doc');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.tapPublishFromHistory();
      await editor.expectPublishedStatus();
      await ss.take(tester, 'published_from_history');
    });

    testWidgets('TC-E2E-01-06: Save and Publish document button', (
      tester,
    ) async {
      final ss = ScreenshotHelper(binding, 'tc_01_06');
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Persistence Test Doc');
      await editor.enterField('title', 'Published Title');
      await editor.tapSaveAndPublish();
      editor.expectPublishConfirmation();
      await ss.take(tester, 'published_via_button');

      await editor.expectPublishedStatus();
    });
  });
}
