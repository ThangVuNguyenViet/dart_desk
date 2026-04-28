import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class SidebarRobot {
  final WidgetTester tester;
  SidebarRobot(this.tester);

  Future<void> tapDocumentType(String title) async {
    // Use the ValueKey set on DocumentTypeItem to avoid ambiguity with
    // other Text widgets that may show the same document type title.
    await tester.tap(find.byKey(ValueKey('doc_type_$title')));
    await tester.pumpAndSettle();
  }

  Future<void> tapMediaLibrary() async {
    await tester.tap(find.byKey(const ValueKey('sidebar_media_button')));
    await tester.pumpAndSettle();
  }

  void expectDocumentTypeVisible(String name) {
    expect(find.text(name), findsWidgets);
  }
}
