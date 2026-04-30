import 'package:dart_desk/src/inputs/boolean_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskBooleanField(
    name: 'is_active',
    title: 'Is Active',
    option: DeskBooleanOption(),
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

  });
}
