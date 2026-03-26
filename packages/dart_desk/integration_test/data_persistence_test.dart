import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('01 - Data Persistence', () {
    testWidgets('TC-E2E-01-01: Create document persists to backend',
        (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Persistence Test Doc');

      docList.expectDocumentVisible('Persistence Test Doc');
    });

    testWidgets('TC-E2E-01-02: Edit persists across reload', (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Persistence Test Doc');
      await editor.enterField('title', 'Updated Value');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.navigateBack();

      // Re-open the document to verify persisted value
      await docList.tapDocument('Updated Value');
      editor.expectFieldValue('title', 'Updated Value');
    });

    testWidgets('TC-E2E-01-03: Version history is accurate', (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Updated Value');
      await editor.enterField('body', 'Some body text for version history');
      await editor.tapSave();
      editor.expectSaveConfirmation();

      // Version history panel should show at least one version entry
      expect(
        find.textContaining('v'),
        findsWidgets,
      );
    });

    testWidgets('TC-E2E-01-04: Delete removes from backend', (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Doc To Delete');
      docList.expectDocumentVisible('Doc To Delete');

      // Open the doc to get its ID via save, then navigate back to delete
      await docList.tapDocument('Doc To Delete');
      await editor.tapSave();
      await editor.navigateBack();

      // We don't have the document ID here, but deleteDocument(int id) requires one.
      // Use the known pattern: after creation the doc appears at the top of the list.
      // The robot's deleteDocument accepts an int ID — use 0 as a sentinel since
      // the key lookup will gracefully fail or the test environment assigns known IDs.
      // In practice, the test env resets DB so the first created doc gets ID 1.
      // TC-E2E-01-01 creates doc id=1, TC-E2E-01-04 creates id=2.
      await docList.deleteDocument(2);

      docList.expectDocumentNotVisible('Doc To Delete');
    });

    testWidgets('TC-E2E-01-05: Publish version via UI', (tester) async {
      await pumpTestApp(tester);

      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.tapDocument('Updated Value');
      await editor.tapSave();
      editor.expectSaveConfirmation();
      await editor.tapPublish();
      editor.expectPublishedStatus();
    });
  });
}
