import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskStringField(
    name: 'title',
    title: 'Title',
    option: DeskStringOption(),
  );

  group('DeskStringInput', () {
    testWidgets('renders with initial value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskStringInput(
            field: field,
            data: const DeskData(value: 'Hello World', path: 'title'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders empty placeholder', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskStringInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Enter text...'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskStringInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'New value');
      await tester.pump();

      expect(received, 'New value');
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskStringInput(
            field: const DeskStringField(
              name: 'title',
              title: 'Title',
              option: DeskStringOption(optional: true),
            ),
            data: const DeskData(value: 'Hello', path: 'title'),
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
        DeskStringInput(
          field: const DeskStringField(
            name: 'title',
            title: 'Title',
            option: DeskStringOption(optional: true),
          ),
          data: value == null ? null : DeskData(value: value, path: 'title'),
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
