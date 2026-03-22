import 'package:dart_desk/src/inputs/number_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsNumberField(
    name: 'count',
    title: 'Count',
    option: CmsNumberOption(),
  );

  group('CmsNumberInput', () {
    testWidgets('renders with initial numeric value', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsNumberInput(
          field: field,
          data: const CmsData(value: 42, path: 'count'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('onChanged fires with parsed num', (tester) async {
      num? received;

      await tester.pumpWidget(buildInputApp(
        CmsNumberInput(
          field: field,
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(ShadInputFormField),
        '123',
      );
      await tester.pump();

      expect(received, 123);
    });

    testWidgets('onChanged fires null for empty', (tester) async {
      num? received = 999;

      await tester.pumpWidget(buildInputApp(
        CmsNumberInput(
          field: field,
          data: const CmsData(value: 42, path: 'count'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(ShadInputFormField),
        '',
      );
      await tester.pump();

      expect(received, isNull);
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = CmsNumberField(
        name: 'hidden',
        title: 'Hidden',
        option: CmsNumberOption(hidden: true),
      );

      await tester.pumpWidget(buildInputApp(
        CmsNumberInput(field: hiddenField),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ShadInputFormField), findsNothing);
    });
  });
}
