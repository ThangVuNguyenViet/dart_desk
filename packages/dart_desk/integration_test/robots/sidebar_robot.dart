import 'package:flutter_test/flutter_test.dart';

class SidebarRobot {
  final WidgetTester tester;
  SidebarRobot(this.tester);

  Future<void> tapDocumentType(String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  void expectDocumentTypeVisible(String name) {
    expect(find.text(name), findsOneWidget);
  }
}
