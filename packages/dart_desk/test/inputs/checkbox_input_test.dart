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

  const optionalField = DeskCheckboxField(
    name: 'enable',
    title: 'Enable',
    option: DeskCheckboxOption(
      label: 'Enable this feature',
      optional: true,
    ),
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

    // optional: false — two-state only, never null
    testWidgets('optional:false — false→true→false, never null', (tester) async {
      final values = <bool?>[];

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: field,
            data: const DeskData(value: false, path: 'enable'),
            onChanged: values.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(values.last, isTrue);

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(values.last, isFalse);

      expect(values, everyElement(isNotNull));
    });

    // optional: true — tri-state cycle null → false → true → null
    testWidgets('optional:true — null→false on tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: null,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, isFalse);
    });

    testWidgets('optional:true — false→true on tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
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

    testWidgets('optional:true — true→null on tap', (tester) async {
      bool? received = false; // sentinel

      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: const DeskData(value: true, path: 'enable'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, isNull);
    });

    testWidgets('optional:true — external value updates do not fire onChanged',
        (tester) async {
      var callCount = 0;

      // Start with null
      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: null,
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // External update to false
      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: const DeskData(value: false, path: 'enable'),
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // External update to true
      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: const DeskData(value: true, path: 'enable'),
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // External update back to null
      await tester.pumpWidget(
        buildInputApp(
          DeskCheckboxInput(
            field: optionalField,
            data: null,
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
