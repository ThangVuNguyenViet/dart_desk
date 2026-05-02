import 'package:dart_desk/src/inputs/text_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskTextField(
  name: 'notes',
  title: 'Notes',
  option: DeskTextOption(rows: 3, optional: true),
);

void main() {
  final field = DeskTextField(
    name: 'body',
    title: 'Body',
    option: DeskTextOption(rows: 3),
  );

  group('DeskTextInput', () {
    testWidgets('renders with initial multi-line value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskTextInput(
            field: field,
            data: const DeskData(value: 'Line one\nLine two', path: 'body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Line one\nLine two'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskTextInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'New text');
      await tester.pump();

      expect(received, 'New text');
    });

    testWidgets('shows deprecated banner', (tester) async {
      final deprecatedField = DeskTextField(
        name: 'old',
        title: 'Old Field',
        option: DeskTextOption(
          rows: 1,
          deprecatedReason: 'Use new field instead',
        ),
      );

      await tester.pumpWidget(
        buildInputApp(DeskTextInput(field: deprecatedField)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deprecated: Use new field instead'), findsOneWidget);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskTextInput(
            field: _optionalField,
            data: const DeskData(value: 'Hello', path: 'notes'),
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle off.
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(captured, isNull);

      // Toggle on.
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(captured, equals('Hello'));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(String? value) => buildInputApp(
        DeskTextInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'notes'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk('Hello'));
      await tester.pumpAndSettle();
      fireCount = 0;
      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      expect(fireCount, 0);
      // Header reflects new state.
      final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });
  });
}
