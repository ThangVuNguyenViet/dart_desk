import 'package:dart_desk/src/inputs/number_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskNumberField(
  name: 'count',
  title: 'Count',
  option: DeskNumberOption(optional: true),
);

void main() {
  const field = DeskNumberField(
    name: 'count',
    title: 'Count',
    option: DeskNumberOption(),
  );

  group('DeskNumberInput', () {
    testWidgets('renders with initial numeric value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskNumberInput(
            field: field,
            data: const DeskData(value: 42, path: 'count'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('onChanged fires with parsed num', (tester) async {
      num? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskNumberInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), '123');
      await tester.pump();

      expect(received, 123);
    });

    testWidgets('onChanged fires null for empty', (tester) async {
      num? received = 999;

      await tester.pumpWidget(
        buildInputApp(
          DeskNumberInput(
            field: field,
            data: const DeskData(value: 42, path: 'count'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), '');
      await tester.pump();

      expect(received, isNull);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      num? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskNumberInput(
            field: _optionalField,
            data: const DeskData(value: 42, path: 'count'),
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
      expect(captured, equals(42));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(num? value) => buildInputApp(
        DeskNumberInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'count'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk(42));
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
