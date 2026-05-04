import 'package:dart_desk/src/inputs/datetime_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskDateTimeField(
  name: 'datetime',
  title: 'Date Time',
  option: DeskDateTimeOption(optional: true),
);

void main() {
  const field = DeskDateTimeField(
    name: 'datetime',
    title: 'Date Time',
    option: DeskDateTimeOption(),
  );

  group('DeskDateTimeInput', () {
    testWidgets('renders formatted datetime', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskDateTimeInput(
            field: field,
            data: const DeskData(
              value: '2026-03-01T10:30:00',
              path: 'datetime',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026-03-01 10:30'), findsOneWidget);
    });

    testWidgets('renders placeholder when no data', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskDateTimeInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Select date and time'), findsOneWidget);
    });

    testWidgets('dialog opens on button tap', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskDateTimeInput(field: field)));
      await tester.pumpAndSettle();

      // Tap the button to open the dialog
      await tester.tap(find.text('Select date and time'));
      await tester.pumpAndSettle();

      // Dialog should be visible with Select and Cancel buttons
      expect(find.text('Select'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Select fires onChanged', (tester) async {
      DateTime? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskDateTimeInput(
            field: field,
            data: const DeskData(
              value: '2026-03-01T10:30:00',
              path: 'datetime',
            ),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('2026-03-01 10:30'));
      await tester.pumpAndSettle();

      // Tap Select
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, isA<DateTime>());
    });

    testWidgets('Cancel closes without callback', (tester) async {
      DateTime? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskDateTimeInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Select date and time'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(received, isNull);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      DateTime? captured;
      final lastDt = DateTime(2026, 3, 1, 10, 30);
      await tester.pumpWidget(
        buildInputApp(
          DeskDateTimeInput(
            field: _optionalField,
            data: DeskData(value: lastDt, path: 'datetime'),
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
      expect(captured, equals(lastDt));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(DateTime? value) => buildInputApp(
        DeskDateTimeInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'datetime'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk(DateTime(2026, 3, 1, 10, 30)));
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
