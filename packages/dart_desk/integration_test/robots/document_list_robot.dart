import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/finders.dart';

class DocumentListRobot {
  final WidgetTester tester;
  DocumentListRobot(this.tester);

  /// Taps the "+" icon button to open the inline create form.
  Future<void> tapCreateButton() async {
    // The create button is a ShadIconButton.secondary with a FontAwesome plus icon.
    // It toggles the inline create form.
    final plusButtons = find.byIcon(Icons.add);
    if (plusButtons.evaluate().isNotEmpty) {
      await tester.tap(plusButtons.first);
    } else {
      // Fallback: the button uses FontAwesomeIcons.plus rendered as a FaIcon.
      // We tap the first ShadIconButton in the header row.
      await tester.tap(find.byType(IconButton).first);
    }
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
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  /// Opens the per-document popup menu and taps "Delete".
  Future<void> deleteDocument(int documentId) async {
    // Tap the three-dot menu for this document
    await tester.tap(findByKey('document_menu_$documentId'));
    await tester.pumpAndSettle();
    // Tap the "Delete" menu item
    await tester.tap(findByKey('delete_document_button'));
    await tester.pumpAndSettle();
  }

  void expectDocumentVisible(String title) {
    expect(find.text(title), findsOneWidget);
  }

  void expectDocumentNotVisible(String title) {
    expect(find.text(title), findsNothing);
  }

  void expectEmptyState() {
    expect(find.text('No documents yet'), findsOneWidget);
  }
}
