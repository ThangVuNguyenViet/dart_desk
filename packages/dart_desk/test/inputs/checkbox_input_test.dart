import 'package:dart_desk/src/inputs/checkbox_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskCheckboxField(
    name: 'enable',
    title: 'Enable',
    option: DeskCheckboxOption(label: 'Enable this feature'),
  );

  group('DeskCheckboxInput', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskCheckboxInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Enable this feature'), findsOneWidget);
    });

    testWidgets('onChanged fires on checkbox tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: field,
            data: const DeskData(value: false, path: 'enable'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, isTrue);
    });

    testWidgets('onChanged fires on label tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: field,
            data: const DeskData(value: false, path: 'enable'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable this feature'));
      await tester.pumpAndSettle();

      expect(received, isTrue);
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = DeskCheckboxField(
        name: 'hidden',
        title: 'Hidden',
        option: DeskCheckboxOption(hidden: true),
      );

      await tester.pumpWidget(
        buildInputApp(DeskCheckboxInput(field: hiddenField)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadCheckbox), findsNothing);
    });
  });
}
