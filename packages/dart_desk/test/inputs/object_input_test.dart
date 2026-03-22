import 'package:dart_desk/src/inputs/object_input.dart';
import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsObjectField(
    name: 'address',
    title: 'Object Field',
    option: CmsObjectOption(
      fields: [
        CmsStringField(
          name: 'nested_title',
          title: 'Nested Title',
          option: CmsStringOption(),
        ),
      ],
    ),
  );

  group('CmsObjectInput', () {
    testWidgets('renders object title', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsObjectInput(field: field),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Object Field'), findsOneWidget);
    });

    testWidgets('renders CmsStringInput sub-fields', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsObjectInput(field: field),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CmsStringInput), findsOneWidget);
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = CmsObjectField(
        name: 'hidden',
        title: 'Hidden',
        option: CmsObjectOption(fields: [], hidden: true),
      );

      await tester.pumpWidget(buildInputApp(
        CmsObjectInput(field: hiddenField),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hidden'), findsNothing);
    });
  });
}
