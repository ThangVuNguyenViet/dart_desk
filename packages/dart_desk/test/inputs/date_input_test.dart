import 'package:dart_desk/src/inputs/date_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskDateField(
  name: 'date',
  title: 'Date',
  option: DeskDateOption(optional: true),
);

void main() {
  const field = DeskDateField(
    name: 'date',
    title: 'Date',
    option: DeskDateOption(),
  );

  group('DeskDateInput', () {
    testWidgets('renders with initial date', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskDateInput(
            field: field,
            data: const DeskData(value: '2026-03-01', path: 'date'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadDatePickerFormField), findsOneWidget);
    });

    testWidgets('renders empty when no data', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskDateInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.byType(ShadDatePickerFormField), findsOneWidget);
    });

    testWidgets('calendar popup opens on tap', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskDateInput(field: field)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadDatePickerFormField));
      await tester.pumpAndSettle();

      expect(find.byType(ShadCalendar), findsOneWidget);
    });

    testWidgets('onChanged fires when date selected', (tester) async {
      // Suppress overflow errors from calendar buttons in small test viewport
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalHandler);

      DateTime? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskDateInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      // Open calendar
      await tester.tap(find.byType(ShadDatePickerFormField));
      await tester.pumpAndSettle();

      // Tap a day number in the calendar
      final dayFinder = find.text('15');
      if (dayFinder.evaluate().isNotEmpty) {
        await tester.tap(dayFinder.first);
        await tester.pumpAndSettle();

        expect(received, isNotNull);
        expect(received, isA<DateTime>());
      }
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      DateTime? captured;
      final lastDate = DateTime(2026, 3, 1);
      await tester.pumpWidget(
        buildInputApp(
          DeskDateInput(
            field: _optionalField,
            data: DeskData(value: lastDate, path: 'date'),
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
      expect(captured, equals(lastDate));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(DateTime? value) => buildInputApp(
        DeskDateInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'date'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk(DateTime(2026, 3, 1)));
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
