import 'package:dart_desk/src/inputs/color_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskColorField(
  name: 'color',
  title: 'Color',
  option: DeskColorOption(optional: true),
);

void main() {
  const field = DeskColorField(
    name: 'color',
    title: 'Color',
    option: DeskColorOption(showAlpha: false),
  );

  group('DeskColorInput', () {
    testWidgets('renders with initial hex color', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: field,
            data: const DeskData(value: '#FF5733', path: 'color'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The hex value is displayed in the ShadInput
      expect(find.text('#FF5733'), findsOneWidget);
    });

    testWidgets('onChanged fires on hex text entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: field,
            data: const DeskData(value: '#FF5733', path: 'color'),
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a different valid hex color
      await tester.enterText(find.byType(ShadInput), '#00FF00');
      await tester.pump();

      expect(received, '#00FF00');
    });

    testWidgets('dialog opens on swatch tap', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: field,
            data: const DeskData(value: '#FF5733', path: 'color'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the color preview box (InkWell wrapping the color container)
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(find.text('Pick a Color'), findsOneWidget);
    });

    testWidgets('dialog Select fires onChanged', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: field,
            data: const DeskData(value: '#FF5733', path: 'color'),
            onChanged: (v) => received = v,
          ),
        ),
      );
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

      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: field,
            data: const DeskData(value: '#FF5733', path: 'color'),
            onChanged: (v) => received = v,
          ),
        ),
      );
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

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskColorInput(
            field: _optionalField,
            data: const DeskData(value: '#FF5733', path: 'color'),
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle off.
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(captured, isNull);

      // Toggle on.
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      expect(captured, equals('#FF5733'));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(String? value) => buildInputApp(
        DeskColorInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'color'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk('#FF5733'));
      await tester.pumpAndSettle();
      fireCount = 0;
      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      expect(fireCount, 0);
      // Header reflects new state.
      final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });
  });
}
