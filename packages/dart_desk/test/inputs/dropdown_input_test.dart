import 'package:dart_desk/src/inputs/dropdown_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsDropdownField<String>(
    name: 'category',
    title: 'Category',
    option: CmsDropdownSimpleOption(
      options: [
        DropdownOption(value: 'option_a', label: 'Option A'),
        DropdownOption(value: 'option_b', label: 'Option B'),
        DropdownOption(value: 'option_c', label: 'Option C'),
      ],
      placeholder: 'Select an option',
    ),
  );

  group('CmsDropdownInput', () {
    testWidgets('renders selected value label', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          CmsDropdownInput<String>(
            field: field,
            data: const CmsData(value: 'option_a', path: 'category'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('renders placeholder when no selection', (tester) async {
      await tester.pumpWidget(
        buildInputApp(CmsDropdownInput<String>(field: field)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('dropdown opens on tap', (tester) async {
      await tester.pumpWidget(
        buildInputApp(CmsDropdownInput<String>(field: field)),
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
          CmsDropdownInput<String>(
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
  });
}
