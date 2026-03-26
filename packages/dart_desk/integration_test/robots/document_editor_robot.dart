import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/finders.dart';

class DocumentEditorRobot {
  final WidgetTester tester;
  DocumentEditorRobot(this.tester);

  /// Enters text into a form field identified by its field name key.
  Future<void> enterField(String fieldName, String value) async {
    final fieldFinder = find.byKey(ValueKey(fieldName));
    // The field widget contains a TextField descendant
    final textField = find.descendant(
      of: fieldFinder,
      matching: find.byType(TextField),
    );
    if (textField.evaluate().isNotEmpty) {
      await tester.enterText(textField.first, value);
    } else {
      // Fallback: try entering directly on the keyed widget
      await tester.enterText(fieldFinder, value);
    }
    await tester.pumpAndSettle();
  }

  /// Taps the "Save" button (CmsButton with text 'Save').
  Future<void> tapSave() async {
    await tester.tap(findShadButton('Save'));
    await tester.pumpAndSettle();
  }

  /// Taps the "Discard" button.
  Future<void> tapDiscard() async {
    await tester.tap(findShadButton('Discard'));
    await tester.pumpAndSettle();
  }

  /// Taps the "Publish" button in the version history popover,
  /// then confirms in the publish dialog.
  Future<void> tapPublish() async {
    await tester.tap(findShadButton('Publish'));
    await tester.pumpAndSettle();
    // Confirm in the publish dialog
    // The dialog has a "Publish" button as well
    await tester.tap(findShadButton('Publish'));
    await tester.pumpAndSettle();
  }

  /// Expects the toast confirmation after saving.
  void expectSaveConfirmation() {
    expect(find.text('Document saved successfully'), findsOneWidget);
  }

  /// Reads the current text value of a field by its key.
  void expectFieldValue(String fieldName, String value) {
    final fieldFinder = find.byKey(ValueKey(fieldName));
    final textField = find.descendant(
      of: fieldFinder,
      matching: find.byType(TextField),
    );
    if (textField.evaluate().isNotEmpty) {
      final widget = tester.widget<TextField>(textField.first);
      expect(widget.controller?.text, value);
    } else {
      // Fallback: check if the text is present as a descendant
      expect(
        find.descendant(of: fieldFinder, matching: find.text(value)),
        findsOneWidget,
      );
    }
  }

  /// Expects the "Published" status text to be visible (from CmsStatusPill).
  void expectPublishedStatus() {
    expect(find.text('PUBLISHED'), findsOneWidget);
  }
}
