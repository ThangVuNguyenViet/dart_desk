import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskStringField(
    name: 'title',
    title: 'Title',
    option: DeskStringOption(),
  );

  group('DeskStringInput', () {
    testWidgets('renders with initial value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskStringInput(
            field: field,
            data: const DeskData(value: 'Hello World', path: 'title'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders empty placeholder', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskStringInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Enter text...'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskStringInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'New value');
      await tester.pump();

      expect(received, 'New value');
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = DeskStringField(
        name: 'secret',
        title: 'Secret',
        option: DeskStringOption(hidden: true),
      );

      await tester.pumpWidget(
        buildInputApp(DeskStringInput(field: hiddenField)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadInputFormField), findsNothing);
    });
  });
}
