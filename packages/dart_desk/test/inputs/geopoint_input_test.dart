import 'package:dart_desk/src/inputs/geopoint_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskGeopointField(
    name: 'location',
    title: 'Location',
    option: DeskGeopointOption(),
  );

  group('DeskGeopointInput', () {
    testWidgets('renders with initial lat/lng', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskGeopointInput(
            field: field,
            data: const DeskData(
              value: {'lat': 37.7749, 'lng': -122.4194},
              path: 'location',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('37.7749'), findsOneWidget);
      expect(find.text('-122.4194'), findsOneWidget);
    });

    testWidgets('onChanged fires with both valid coords', (tester) async {
      Map<String, double>? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskGeopointInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      // Find the two ShadInputFormField widgets (lat and lng)
      final inputs = find.byType(ShadInputFormField);
      expect(inputs, findsAtLeast(2));

      // Enter latitude
      await tester.enterText(inputs.at(0), '10.0');
      await tester.pump();

      // Enter longitude
      await tester.enterText(inputs.at(1), '-20.5');
      await tester.pump();

      expect(received, isNotNull);
      expect(received!['lat'], 10.0);
      expect(received!['lng'], -20.5);
    });

    testWidgets('onChanged fires null when one field empty', (tester) async {
      Map<String, double>? received = {'lat': 0, 'lng': 0};

      await tester.pumpWidget(
        buildInputApp(
          DeskGeopointInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      final inputs = find.byType(ShadInputFormField);

      // Only enter latitude, leave longitude empty
      await tester.enterText(inputs.at(0), '10.0');
      await tester.pump();

      expect(received, isNull);
    });

    testWidgets('renders title label', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskGeopointInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('optional toggle off fires onChanged(null) once', (
      tester,
    ) async {
      const optField = DeskGeopointField(
        name: 'location',
        title: 'Location',
        option: DeskGeopointOption(optional: true),
      );
      final received = <Map<String, double>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskGeopointInput(
            field: optField,
            data: const DeskData(
              value: {'lat': 1.0, 'lng': 2.0},
              path: 'location',
            ),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received, [null]);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      const optField = DeskGeopointField(
        name: 'location',
        title: 'Location',
        option: DeskGeopointOption(optional: true),
      );
      final received = <Map<String, double>?>[];
      await tester.pumpWidget(
        buildInputApp(
          DeskGeopointInput(
            field: optField,
            data: const DeskData(
              value: {'lat': 1.0, 'lng': 2.0},
              path: 'location',
            ),
            onChanged: received.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ShadCheckbox));
      await tester.pumpAndSettle();

      expect(received.length, 2);
      expect(received[0], isNull);
      expect(received[1], {'lat': 1.0, 'lng': 2.0});
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      const optField = DeskGeopointField(
        name: 'location',
        title: 'Location',
        option: DeskGeopointOption(optional: true),
      );
      var fireCount = 0;
      Widget mk(Map<String, double>? value) => buildInputApp(
        DeskGeopointInput(
          field: optField,
          data: value == null ? null : DeskData(value: value, path: 'location'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk({'lat': 1.0, 'lng': 2.0}));
      await tester.pumpAndSettle();
      fireCount = 0;
      await tester.pumpWidget(mk(null));
      await tester.pumpAndSettle();
      expect(fireCount, 0);
      final cb = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
      expect(cb.value, isFalse);
    });
  });
}
