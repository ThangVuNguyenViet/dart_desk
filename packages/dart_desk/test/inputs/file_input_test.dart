import 'package:dart_desk/src/inputs/file_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskFileField(
  name: 'document',
  title: 'Document Upload',
  option: DeskFileOption(),
);

const _optionalField = DeskFileField(
  name: 'document',
  title: 'Document Upload',
  option: DeskFileOption(optional: true),
);

void main() {
  group('DeskFileInput', () {
    testWidgets('renders upload button when no file', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskFileInput(field: _field)));
      await tester.pumpAndSettle();

      expect(find.text('Upload File'), findsOneWidget);
    });

    testWidgets('renders title label', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskFileInput(field: _field)));
      await tester.pumpAndSettle();

      expect(find.text('Document Upload'), findsOneWidget);
    });

    testWidgets('renders file name for URL data', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskFileInput(
            field: _field,
            data: const DeskData(
              value: 'https://example.com/report.pdf',
              path: 'document',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('report.pdf'), findsOneWidget);
    });

    testWidgets('hidden field renders nothing', (tester) async {
      const hiddenField = DeskFileField(
        name: 'document',
        title: 'Document Upload',
        option: DeskFileOption(hidden: true),
      );

      await tester.pumpWidget(buildInputApp(DeskFileInput(field: hiddenField)));
      await tester.pumpAndSettle();

      expect(find.text('Upload File'), findsNothing);
      expect(find.text('Document Upload'), findsNothing);
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskFileInput(
            field: _optionalField,
            data: const DeskData(
              value: 'https://example.com/report.pdf',
              path: 'document',
            ),
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
      expect(captured, equals('https://example.com/report.pdf'));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(String? value) => buildInputApp(
        DeskFileInput(
          field: _optionalField,
          data: value == null
              ? null
              : DeskData(value: value, path: 'document'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk('https://example.com/report.pdf'));
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
