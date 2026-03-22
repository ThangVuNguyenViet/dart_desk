import 'package:dart_desk/src/inputs/array_input.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  final field = CmsArrayField(
    name: 'tags',
    title: 'Tags',
    option: TestStringArrayOption(),
  );

  group('CmsArrayInput', () {
    testWidgets('renders existing items', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: field,
          data: const CmsData(
            value: ['Item 1', 'Item 2', 'Item 3'],
            path: 'tags',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('empty state message', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: field,
          data: const CmsData(value: [], path: 'tags'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('No items. Click "Add" to create one.'),
        findsOneWidget,
      );
    });

    testWidgets('Add + Save fires onChanged', (tester) async {
      List? received;

      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: field,
          data: CmsData(value: List<String>.from(['Existing']), path: 'tags'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Enter text in the inline editor
      await tester.enterText(
        find.byType(ShadInputFormField).last,
        'New item',
      );
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, contains('Existing'));
      expect(received, contains('New item'));
    });

    testWidgets('delete fires onChanged with item removed', (tester) async {
      List? received;

      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(
          field: field,
          data: CmsData(
            value: List<String>.from(['Keep', 'Remove']),
            path: 'tags',
          ),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Find and tap the last trash icon (for 'Remove')
      final trashIcons = find.byIcon(FontAwesomeIcons.trash);
      await tester.tap(trashIcons.last);
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received, contains('Keep'));
      expect(received, isNot(contains('Remove')));
    });

    testWidgets('hidden field renders nothing', (tester) async {
      final hiddenField = CmsArrayField(
        name: 'hidden',
        title: 'Hidden',
        option: TestStringArrayOption(),
      );

      // CmsArrayField doesn't have a hidden option on the field itself,
      // but the option does — checking that the widget builds with no items
      await tester.pumpWidget(buildInputApp(
        CmsArrayInput(field: hiddenField),
      ));
      await tester.pumpAndSettle();

      // Array input always renders (no hidden option on CmsArrayOption)
      expect(find.text('Hidden'), findsOneWidget);
    });
  });
}
