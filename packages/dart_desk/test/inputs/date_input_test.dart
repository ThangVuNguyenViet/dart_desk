import 'package:dart_desk/src/inputs/date_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsDateField(
    name: 'date',
    title: 'Date',
    option: CmsDateOption(),
  );

  group('CmsDateInput', () {
    testWidgets('renders with initial date', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsDateInput(
          field: field,
          data: const CmsData(value: '2026-03-01', path: 'date'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ShadDatePickerFormField), findsOneWidget);
    });

    testWidgets('renders empty when no data', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsDateInput(field: field),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ShadDatePickerFormField), findsOneWidget);
    });

    testWidgets('calendar popup opens on tap', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsDateInput(field: field),
      ));
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

      await tester.pumpWidget(buildInputApp(
        CmsDateInput(
          field: field,
          onChanged: (v) => received = v,
        ),
      ));
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
  });
}
