import 'package:dart_desk/dart_desk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',
    option: DeskMultiDropdownSimpleOption(
      options: [
        DropdownOption(value: 'a', label: 'Option A'),
        DropdownOption(value: 'b', label: 'Option B'),
        DropdownOption(value: 'c', label: 'Option C'),
      ],
      placeholder: 'Select tags',
    ),
  );

  group('DeskMultiDropdownInput', () {
    testWidgets(
      'static options render correctly — shows placeholder and all 3 options on tap',
      (tester) async {
        await tester.pumpWidget(
          buildInputApp(DeskMultiDropdownInput<String>(field: field)),
        );
        await tester.pumpAndSettle();

        // Placeholder is visible before opening
        expect(find.text('Select tags'), findsOneWidget);

        // Tap to open
        await tester.tap(find.text('Select tags'));
        await tester.pumpAndSettle();

        // All 3 options should be visible
        expect(find.text('Option A'), findsWidgets);
        expect(find.text('Option B'), findsWidgets);
        expect(find.text('Option C'), findsWidgets);
      },
    );

    testWidgets(
      'multi-select: selecting two options shows comma-joined labels and fires onChanged',
      (tester) async {
        List<String>? received;

        await tester.pumpWidget(
          buildInputApp(
            DeskMultiDropdownInput<String>(
              field: field,
              onChanged: (v) => received = v,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dropdown
        await tester.tap(find.text('Select tags'));
        await tester.pumpAndSettle();

        // Select Option A
        await tester.tap(find.text('Option A').last);
        await tester.pumpAndSettle();

        // Select Option B (dropdown stays open due to closeOnSelect: false)
        await tester.tap(find.text('Option B').last);
        await tester.pumpAndSettle();

        // Both values should have been emitted
        expect(received, containsAll(['a', 'b']));
        expect(received, hasLength(2));

        // Close the dropdown and check selected display
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // The selected options display should show comma-joined labels
        expect(find.textContaining('Option A'), findsWidgets);
        expect(find.textContaining('Option B'), findsWidgets);
      },
    );

    testWidgets('empty options list shows "No options available"', (
      tester,
    ) async {
      const emptyField = DeskMultiDropdownField<String>(
        name: 'empty',
        title: 'Empty',
        option: DeskMultiDropdownSimpleOption(options: []),
      );

      await tester.pumpWidget(
        buildInputApp(DeskMultiDropdownInput<String>(field: emptyField)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No options available'), findsOneWidget);
    });

    testWidgets('didUpdateWidget updates controller when data changes', (
      tester,
    ) async {
      Widget buildWithData(DeskData? data) => buildInputApp(
        DeskMultiDropdownInput<String>(field: field, data: data),
      );

      // Build with initial data ['a']
      await tester.pumpWidget(
        buildWithData(const DeskData(value: ['a'], path: 'tags')),
      );
      await tester.pumpAndSettle();

      // 'Option A' should be shown as selected
      expect(find.text('Option A'), findsOneWidget);

      // Update to data ['b']
      await tester.pumpWidget(
        buildWithData(const DeskData(value: ['b'], path: 'tags')),
      );
      await tester.pumpAndSettle();

      // Now 'Option B' should be shown as selected
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets(
      'deselection works: selecting an already-selected option removes it',
      (tester) async {
        List<String>? received;

        await tester.pumpWidget(
          buildInputApp(
            DeskMultiDropdownInput<String>(
              field: field,
              data: const DeskData(value: ['a'], path: 'tags'),
              onChanged: (v) => received = v,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 'Option A' is already selected — open dropdown
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Tap 'Option A' again to deselect it
        await tester.tap(find.text('Option A').last);
        await tester.pumpAndSettle();

        // onChanged should have been called with an empty list
        expect(received, isEmpty);
      },
    );

    testWidgets('optional toggle off fires onChanged(null) once', (
      tester,
    ) async {
      const optField = DeskMultiDropdownField<String>(
        name: 'tags',
        title: 'Tags',
        option: DeskMultiDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      final received = <List<String>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskMultiDropdownInput<String>(
            field: optField,
            data: const DeskData(value: ['a'], path: 'tags'),
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
      const optField = DeskMultiDropdownField<String>(
        name: 'tags',
        title: 'Tags',
        option: DeskMultiDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      final received = <List<String>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskMultiDropdownInput<String>(
            field: optField,
            data: const DeskData(value: ['a'], path: 'tags'),
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
      expect(received[1], ['a']);
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      const optField = DeskMultiDropdownField<String>(
        name: 'tags',
        title: 'Tags',
        option: DeskMultiDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      var fireCount = 0;
      Widget mk(List<String>? value) => buildInputApp(
        DeskMultiDropdownInput<String>(
          field: optField,
          data: value == null ? null : DeskData(value: value, path: 'tags'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk(['a']));
      await tester.pumpAndSettle();
      fireCount = 0;
      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      expect(fireCount, 0);
      final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });
  });
}
