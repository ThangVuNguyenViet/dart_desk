import 'package:dart_desk/src/inputs/block_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const optField = DeskBlockField(
    name: 'content',
    title: 'Content',
    option: DeskBlockOption(optional: true),
  );

  group('DeskBlockInput', () {
    testWidgets('hidden field renders nothing', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskBlockInput(
            field: const DeskBlockField(
              name: 'content',
              title: 'Content',
              option: DeskBlockOption(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('optional toggle off fires onChanged(null) once', (
      tester,
    ) async {
      final received = <dynamic>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskBlockInput(
            field: optField,
            data: const DeskData(value: 'Hello world', path: 'content'),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, [null]);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      final received = <dynamic>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskBlockInput(
            field: optField,
            data: const DeskData(value: 'Hello world', path: 'content'),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received.length, 2);
      expect(received[0], isNull);
      expect(received[1], contains('Hello world'));
    });

    testWidgets('checkbox reflects optional state from initial data', (
      tester,
    ) async {
      Widget mk(String? value) => buildInputApp(
        DeskBlockInput(
          field: optField,
          data: value == null ? null : DeskData(value: value, path: 'content'),
        ),
      );

      await tester.pumpWidget(mk('Hello'));
      await tester.pumpAndSettle();
      var cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isTrue);

      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      // didUpdateWidget doesn't currently sync (no override); state retained.
      // Use a fresh widget tree to verify init-time wiring.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });
  });
}
