import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsStringField(
    name: 'title',
    title: 'Title',
    option: CmsStringOption(),
  );

  group('CmsStringInput', () {
    testWidgets('renders with initial value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          CmsStringInput(
            field: field,
            data: const CmsData(value: 'Hello World', path: 'title'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders empty placeholder', (tester) async {
      await tester.pumpWidget(buildInputApp(CmsStringInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Enter text...'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          CmsStringInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'New value');
      await tester.pump();

      expect(received, 'New value');
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = CmsStringField(
        name: 'secret',
        title: 'Secret',
        option: CmsStringOption(hidden: true),
      );

      await tester.pumpWidget(
        buildInputApp(CmsStringInput(field: hiddenField)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadInputFormField), findsNothing);
    });
  });
}
