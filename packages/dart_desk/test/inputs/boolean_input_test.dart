import 'package:dart_desk/src/inputs/boolean_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskBooleanField(
    name: 'is_active',
    title: 'Is Active',
    option: DeskBooleanOption(),
  );

  const optionalField = DeskBooleanField(
    name: 'is_active',
    title: 'Is Active',
    option: DeskBooleanOption(optional: true),
  );

  group('DeskBooleanInput', () {
    testWidgets('renders with true value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: field,
            data: const DeskData(value: true, path: 'is_active'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(ShadSwitch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<ShadSwitch>(switchFinder);
      expect(switchWidget.value, isTrue);
    });

    testWidgets('onChanged fires false on tap (true→false)', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: field,
            data: const DeskData(value: true, path: 'is_active'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(received, isFalse);
    });

    testWidgets('onChanged fires true on tap (false→true)', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: field,
            data: const DeskData(value: false, path: 'is_active'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(received, isTrue);
    });

    // optional: false — two-state only, never null
    testWidgets('optional:false — false→true→false, never null', (tester) async {
      final values = <bool?>[];

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: field,
            data: const DeskData(value: false, path: 'is_active'),
            onChanged: values.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();
      expect(values.last, isTrue);

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();
      expect(values.last, isFalse);

      expect(values, everyElement(isNotNull));
    });

    // optional: true — tri-state cycle null → false → true → null
    testWidgets('optional:true — null→false on tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: null, // null initial
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(received, isFalse);
    });

    testWidgets('optional:true — false→true on tap', (tester) async {
      bool? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: const DeskData(value: false, path: 'is_active'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(received, isTrue);
    });

    testWidgets('optional:true — true→null on tap', (tester) async {
      bool? received = false; // sentinel

      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: const DeskData(value: true, path: 'is_active'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();

      expect(received, isNull);
    });

    testWidgets('optional:true — external value updates do not fire onChanged',
        (tester) async {
      var callCount = 0;

      // Start with null
      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
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
          DeskBooleanInput(
            field: optionalField,
            data: const DeskData(value: false, path: 'is_active'),
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // External update to true
      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: const DeskData(value: true, path: 'is_active'),
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // External update back to null
      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: null,
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('optional:true — null shows switch with opacity 0.4',
        (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskBooleanInput(
            field: optionalField,
            data: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, 0.4);
    });
  });
}
