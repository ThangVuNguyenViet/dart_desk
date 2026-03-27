import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/finders.dart';

class DocumentListRobot {
  final WidgetTester tester;
  DocumentListRobot(this.tester);

  /// Scopes a finder to within the document list panel.
  Finder _inList(Finder finder) => find.descendant(
        of: find.byKey(const ValueKey('document_list_view')),
        matching: finder,
      );

  /// Taps the "+" icon button to open the inline create form.
  Future<void> tapCreateButton() async {
    await tester.tap(find.byKey(const ValueKey('create_document_button')));
    await tester.pumpAndSettle();
  }

  /// Fills in the inline create form and submits it.
  Future<void> createDocument(String title) async {
    await tapCreateButton();
    // Enter the document title in the first input (placeholder: "Document title")
    await tester.enterText(
      findShadInput('Document title'),
      title,
    );
    await tester.pumpAndSettle();
    // Wait for slug auto-generation
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    // Tap the "Create" button
    await tester.tap(findShadButton('Create'));
    await tester.pumpAndSettle();
  }

  /// Taps a document row by its title text.
  Future<void> tapDocument(String title) async {
    await tester.tap(_inList(find.text(title)));
    await tester.pumpAndSettle();
  }

  /// Opens the per-document popup menu and taps "Delete".
  Future<void> deleteDocument(String title) async {
    // Find the document title within the list (use first match if briefly doubled).
    final titleFinder = _inList(find.text(title)).first;
    await tester.pumpAndSettle();

    // Find the PopupMenuButton in the same GestureDetector ancestor as the title
    final menuButton = find.descendant(
      of: find.ancestor(
        of: titleFinder,
        matching: find.byType(GestureDetector),
      ),
      matching: find.byType(PopupMenuButton<String>),
    );
    await tester.tap(menuButton.first);
    await tester.pumpAndSettle();
    // Tap the "Delete" menu item
    await tester.tap(findByKey('delete_document_button'));
    await tester.pumpAndSettle();
    // Confirm in the delete confirmation dialog
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
  }

  void expectDocumentVisible(String title) {
    expect(_inList(find.text(title)), findsOneWidget);
  }

  void expectDocumentNotVisible(String title) {
    expect(_inList(find.text(title)), findsNothing);
  }

  void expectEmptyState() {
    expect(find.text('No documents yet'), findsOneWidget);
  }
}
