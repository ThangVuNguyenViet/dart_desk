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

  /// Taps the "Save" button.
  Future<void> tapSave() async {
    await tester.tap(find.byKey(const ValueKey('save_document_button')));
    await tester.pumpAndSettle();
  }

  /// Taps the "Discard" button.
  Future<void> tapDiscard() async {
    await tester.tap(find.byKey(const ValueKey('discard_document_button')));
    await tester.pumpAndSettle();
  }

  /// Opens the version history popover, taps "Publish", then confirms.
  Future<void> tapPublish() async {
    // Open the version history popover.
    await tester.tap(find.byKey(const ValueKey('version_history_button')));
    await tester.pumpAndSettle();
    // Tap the first "Publish" button in the popover.
    await tester.tap(find.text('Publish').first);
    await tester.pumpAndSettle();
    // Confirm in the dialog. The dialog is layered on top so its "Publish"
    // button is the last match in the widget tree.
    await tester.tap(find.text('Publish').last);
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

  /// Opens the version history popover and verifies it has at least one entry.
  Future<void> expectVersionHistoryShown() async {
    // Open the popover by tapping the version history trigger button.
    await tester.tap(find.byKey(const ValueKey('version_history_button')));
    await tester.pumpAndSettle();

    expect(find.text('Version History'), findsOneWidget);
    // At least one version entry exists (e.g. "v1", "v2")
    expect(
      find.textContaining(RegExp(r'^v\d+$')),
      findsAtLeastNWidgets(1),
    );

    // Close the popover.
    await tester.tap(find.byKey(const ValueKey('version_history_button')));
    await tester.pumpAndSettle();
  }

  /// Opens the version history popover and verifies at least one version
  /// shows the compact 'P' published status badge.
  Future<void> expectPublishedStatus() async {
    await tester.tap(find.byKey(const ValueKey('version_history_button')));
    await tester.pumpAndSettle();
    // The popover uses compact badges: 'P' = published, 'D' = draft.
    // Verify at least one 'P' badge exists.
    expect(find.text('P'), findsAtLeastNWidgets(1));
    // Close popover
    await tester.tap(find.byKey(const ValueKey('version_history_button')));
    await tester.pumpAndSettle();
  }

  /// Navigates back to the document list.
  ///
  /// On desktop (split-pane layout), uses the breadcrumb doc-type link.
  /// Falls back to tooltip 'Back' for mobile/push-based navigation.
  Future<void> navigateBack() async {
    final breadcrumbBack = find.byKey(const ValueKey('breadcrumb_back'));
    if (breadcrumbBack.evaluate().isNotEmpty) {
      await tester.tap(breadcrumbBack);
      await tester.pumpAndSettle();
      return;
    }
    final backButton = find.byTooltip('Back');
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      await tester.pageBack();
    }
    await tester.pumpAndSettle();
  }
}
