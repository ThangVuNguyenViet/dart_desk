import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/finders.dart';
import '../test_utils/settle.dart';

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
    await tester.settle();
  }

  /// Fills in the inline create form and submits it.
  Future<void> createDocument(String title) async {
    await tapCreateButton();
    // Enter the document title in the first input (placeholder: "Document title")
    await tester.enterText(findShadInput('Document title'), title);
    await tester.settle();
    // Wait for slug auto-generation
    await tester.pump(const Duration(milliseconds: 600));
    await tester.settle();
    // Tap the "Create" button
    await tester.tap(findShadButton('Create'));
    await tester.settle();
  }

  /// Taps a document row by its title text.
  ///
  /// If the doc isn't visible (e.g. long list on prod), types the title into
  /// the search field to filter the list first.
  Future<void> tapDocument(String title) async {
    var finder = _inList(find.text(title));
    if (finder.evaluate().isEmpty) {
      await tester.enterText(findShadInput('Search documents...'), title);
      await tester.settle();
      finder = _inList(find.text(title));
    }
    // After search, there may be 2 matches (search field EditableText + doc
    // title Text). The doc title is the last one in the widget tree.
    await tester.tap(finder.last);
    await tester.settle();
    // Clear search so the full list is visible for subsequent operations.
    final searchField = findShadInput('Search documents...');
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField, '');
      await tester.settle();
    }
  }

  /// Opens the per-document popup menu and taps "Delete".
  ///
  /// Best-effort cleanup — if the document can't be found or deleted, the
  /// error is swallowed so it doesn't mask the real test result.
  Future<void> deleteDocument(String title) async {
    try {
      // Search to ensure the doc is visible in a long list.
      if (_inList(find.text(title)).evaluate().isEmpty) {
        await tester.enterText(findShadInput('Search documents...'), title);
        await tester.settle();
      }
      // Use .last to skip the search EditableText and land on the doc Text.
      final titleFinder = _inList(find.text(title)).last;

      // Find the PopupMenuButton in the same GestureDetector ancestor.
      final menuButton = find.descendant(
        of: find.ancestor(
          of: titleFinder,
          matching: find.byType(GestureDetector),
        ),
        matching: find.byType(PopupMenuButton<String>),
      );
      await tester.tap(menuButton.first);
      await tester.settle();
      // Tap the "Delete" menu item
      await tester.tap(findByKey('delete_document_button'));
      await tester.settle();
      // Confirm in the delete confirmation dialog
      await tester.tap(find.text('Delete').last);
      await tester.settle();
      // Clear search
      final searchField = findShadInput('Search documents...');
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, '');
        await tester.settle();
      }
    } catch (e) {
      // Cleanup is best-effort; don't fail the test.
      debugPrint('[cleanup] Failed to delete "$title": $e');
    }
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
