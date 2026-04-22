import 'package:dart_desk/src/inputs/text_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  final field = DeskTextField(
    name: 'body',
    title: 'Body',
    option: DeskTextOption(rows: 3),
  );

  group('DeskTextInput', () {
    testWidgets('renders with initial multi-line value', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskTextInput(
            field: field,
            data: const DeskData(value: 'Line one\nLine two', path: 'body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Line one\nLine two'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskTextInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'New text');
      await tester.pump();

      expect(received, 'New text');
    });

    testWidgets('shows deprecated banner', (tester) async {
      final deprecatedField = DeskTextField(
        name: 'old',
        title: 'Old Field',
        option: DeskTextOption(
          rows: 1,
          deprecatedReason: 'Use new field instead',
        ),
      );

      await tester.pumpWidget(
        buildInputApp(DeskTextInput(field: deprecatedField)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deprecated: Use new field instead'), findsOneWidget);
    });

    testWidgets('hidden field renders nothing', (tester) async {
      final hiddenField = DeskTextField(
        name: 'hidden',
        title: 'Hidden',
        option: DeskTextOption(rows: 1, hidden: true),
      );

      await tester.pumpWidget(buildInputApp(DeskTextInput(field: hiddenField)));
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(ShadInputFormField), findsNothing);
    });
  });
}
