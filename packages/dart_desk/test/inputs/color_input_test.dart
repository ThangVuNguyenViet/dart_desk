import 'package:dart_desk/src/inputs/color_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsColorField(
    name: 'color',
    title: 'Color',
    option: CmsColorOption(showAlpha: false),
  );

  group('CmsColorInput', () {
    testWidgets('renders with initial hex color', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsColorInput(
          field: field,
          data: const CmsData(value: '#FF5733', path: 'color'),
        ),
      ));
      await tester.pumpAndSettle();

      // The hex value is displayed in the ShadInput
      expect(find.text('#FF5733'), findsOneWidget);
    });

    testWidgets('onChanged fires on hex text entry', (tester) async {
      String? received;

      await tester.pumpWidget(buildInputApp(
        CmsColorInput(
          field: field,
          data: const CmsData(value: '#FF5733', path: 'color'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Enter a different valid hex color
      await tester.enterText(find.byType(ShadInput), '#00FF00');
      await tester.pump();

      expect(received, '#00FF00');
    });

    testWidgets('dialog opens on swatch tap', (tester) async {
      await tester.pumpWidget(buildInputApp(
        CmsColorInput(
          field: field,
          data: const CmsData(value: '#FF5733', path: 'color'),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the color preview box (InkWell wrapping the color container)
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.text('Pick a Color'), findsOneWidget);
    });

    testWidgets('dialog Select fires onChanged', (tester) async {
      String? received;

      await tester.pumpWidget(buildInputApp(
        CmsColorInput(
          field: field,
          data: const CmsData(value: '#FF5733', path: 'color'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Tap Select button
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
    });

    testWidgets('dialog Cancel closes without callback', (tester) async {
      String? received;

      await tester.pumpWidget(buildInputApp(
        CmsColorInput(
          field: field,
          data: const CmsData(value: '#FF5733', path: 'color'),
          onChanged: (v) => received = v,
        ),
      ));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.text('Pick a Color'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(received, isNull);
      expect(find.text('Pick a Color'), findsNothing);
    });
  });
}
