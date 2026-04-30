import 'package:dart_desk/src/inputs/dropdown_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskDropdownField<String>(
    name: 'category',
    title: 'Category',
    option: DeskDropdownSimpleOption(
      options: [
        DropdownOption(value: 'option_a', label: 'Option A'),
        DropdownOption(value: 'option_b', label: 'Option B'),
        DropdownOption(value: 'option_c', label: 'Option C'),
      ],
      placeholder: 'Select an option',
    ),
  );

  group('DeskDropdownInput', () {
    testWidgets('renders selected value label', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskDropdownInput<String>(
            field: field,
            data: const DeskData(value: 'option_a', path: 'category'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('renders placeholder when no selection', (tester) async {
      await tester.pumpWidget(
        buildInputApp(DeskDropdownInput<String>(field: field)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('dropdown opens on tap', (tester) async {
      await tester.pumpWidget(
        buildInputApp(DeskDropdownInput<String>(field: field)),
      );
      await tester.pumpAndSettle();

      // Tap the select trigger
      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();

      // All options should now be visible
      expect(find.text('Option A'), findsWidgets);
      expect(find.text('Option B'), findsWidgets);
      expect(find.text('Option C'), findsWidgets);
    });

    testWidgets('onChanged fires with selected value', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskDropdownInput<String>(
            field: field,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();

      // Select Option B
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(received, 'option_b');
    });

    testWidgets('optional toggle off fires onChanged(null) once', (tester) async {
      const optField = DeskDropdownField<String>(
        name: 'category',
        title: 'Category',
        option: DeskDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      final received = <String?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskDropdownInput<String>(
            field: optField,
            data: const DeskData(value: 'a', path: 'category'),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, [null]);
    });

    testWidgets('optional toggle off then on restores last value', (tester) async {
      const optField = DeskDropdownField<String>(
        name: 'category',
        title: 'Category',
        option: DeskDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      final received = <String?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskDropdownInput<String>(
            field: optField,
            data: const DeskData(value: 'a', path: 'category'),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, [null, 'a']);
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      const optField = DeskDropdownField<String>(
        name: 'category',
        title: 'Category',
        option: DeskDropdownSimpleOption(
          options: [
            DropdownOption(value: 'a', label: 'A'),
            DropdownOption(value: 'b', label: 'B'),
          ],
          optional: true,
        ),
      );
      var fireCount = 0;
      Widget mk(String? value) => buildInputApp(
        DeskDropdownInput<String>(
          field: optField,
          data: value == null
              ? null
              : DeskData(value: value, path: 'category'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk('a'));
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
