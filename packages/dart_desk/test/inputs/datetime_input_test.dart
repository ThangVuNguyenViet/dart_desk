import 'package:dart_desk/src/inputs/datetime_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsDateTimeField(
    name: 'datetime',
    title: 'Date Time',
    option: CmsDateTimeOption(),
  );

  group('CmsDateTimeInput', () {
    testWidgets('renders formatted datetime', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          CmsDateTimeInput(
            field: field,
            data: const CmsData(value: '2026-03-01T10:30:00', path: 'datetime'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026-03-01 10:30'), findsOneWidget);
    });

    testWidgets('renders placeholder when no data', (tester) async {
      await tester.pumpWidget(buildInputApp(CmsDateTimeInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Select date and time'), findsOneWidget);
    });

    testWidgets('dialog opens on button tap', (tester) async {
      await tester.pumpWidget(buildInputApp(CmsDateTimeInput(field: field)));
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
          CmsDateTimeInput(
            field: field,
            data: const CmsData(value: '2026-03-01T10:30:00', path: 'datetime'),
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
          CmsDateTimeInput(field: field, onChanged: (v) => received = v),
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
  });
}
