import 'package:flutter_test/flutter_test.dart';

import 'robots/document_editor_robot.dart';
import 'robots/document_list_robot.dart';
import 'robots/image_field_robot.dart';
import 'robots/media_library_robot.dart';
import 'robots/sidebar_robot.dart';
import 'test_utils/db_helper.dart';
import 'test_utils/screenshot_helper.dart';
import 'test_utils/test_app.dart';

void main() {
  final binding = ensureTestInitialized();

  setUpAll(() async => DbHelper.reset());
  tearDownAll(() async => DbHelper.reset());

  group('08 - Gallery Delete', () {
    testWidgets('TC-E2E-08-01: Delete unused asset from gallery',
        (tester) async {
      final ss = ScreenshotHelper(binding, 'tc_08_01');
      await pumpTestApp(tester);

      // Upload an image and then remove it from the field before saving so the
      // asset exists in the media library but is not referenced by any document.
      final sidebar = SidebarRobot(tester);
      final docList = DocumentListRobot(tester);
      final image = ImageFieldRobot(tester);
      final editor = DocumentEditorRobot(tester);

      await sidebar.tapDocumentType('Integration Test');
      await docList.createDocument('Orphan Upload');
      await docList.tapDocument('Orphan Upload');
      await image.tapUpload('image_field');
      await image.expectImagePreview('image_field');
      // Remove the reference from the field before saving so the asset is
      // orphaned (uploaded but not linked to any document).
      await image.tapRemove('image_field');
      await editor.tapSave();

      final library = MediaLibraryRobot(tester);
      await library.openMediaLibrary();
      await ss.take(tester, 'library_opened');

      final before = library.visibleTileCount();
      expect(before, greaterThan(0));

      await library.hoverTile(0);
      await library.tapTrash(0);
      await ss.take(tester, 'confirm_dialog');

      expect(find.text('Delete'), findsOneWidget);
      await library.confirmDelete();
      await tester.pumpAndSettle();
      await ss.take(tester, 'after_delete');

      expect(library.visibleTileCount(), equals(before - 1));
    });

    testWidgets(
      'TC-E2E-08-02: Delete blocked when referenced by document',
      (tester) async {
        final ss = ScreenshotHelper(binding, 'tc_08_02');
        await pumpTestApp(tester);

        final sidebar = SidebarRobot(tester);
        final docList = DocumentListRobot(tester);
        final image = ImageFieldRobot(tester);
        final editor = DocumentEditorRobot(tester);

        await sidebar.tapDocumentType('Integration Test');
        await docList.createDocument('Referenced Image Doc');
        await docList.tapDocument('Referenced Image Doc');
        await image.tapUpload('image_field');
        await image.expectImagePreview('image_field');
        // Save with the image attached so the asset is actively referenced.
        await editor.tapSave();

        final library = MediaLibraryRobot(tester);
        await library.openMediaLibrary();
        final before = library.visibleTileCount();

        await library.hoverTile(0);
        await library.tapTrash(0);
        await ss.take(tester, 'in_use_dialog');

        expect(find.textContaining('In use'), findsOneWidget);
        expect(find.text('Delete'), findsNothing);
        expect(find.text('Close'), findsOneWidget);
        await library.closeInUseDialog();

        expect(library.visibleTileCount(), equals(before));
      },
    );

    testWidgets('TC-E2E-08-03: Detail sheet does not reflow grid',
        (tester) async {
      await pumpTestApp(tester);
      final library = MediaLibraryRobot(tester);
      await library.openMediaLibrary();

      expect(library.visibleTileCount(), greaterThanOrEqualTo(2));

      final tile0 = library.tileAt(0);
      final beforeSize = tester.getSize(tile0);

      await tester.tap(library.tileAt(1));
      await tester.pumpAndSettle();
      library.expectDetailPanelVisible();

      final afterSize = tester.getSize(tile0);
      expect((afterSize.width - beforeSize.width).abs(), lessThan(1.0));
      expect((afterSize.height - beforeSize.height).abs(), lessThan(1.0));
    });
  });
}
