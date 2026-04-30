import 'package:dart_desk/src/inputs/url_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

const _optionalField = DeskUrlField(
  name: 'blog',
  title: 'Blog URL',
  option: DeskUrlOption(optional: true),
);

void main() {
  const field = DeskUrlField(
    name: 'website',
    title: 'Website',
    option: DeskUrlOption(),
  );

  group('DeskUrlInput', () {
    testWidgets('renders with initial URL', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          DeskUrlInput(
            field: field,
            data: const DeskData(value: 'https://example.com', path: 'website'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('https://example.com'), findsOneWidget);
    });

    testWidgets('onChanged fires on valid URL entry', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskUrlInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(ShadInputFormField),
        'https://flutter.dev',
      );
      await tester.pump();

      expect(received, 'https://flutter.dev');
    });

    testWidgets('onChanged fires for invalid URL without crashing', (
      tester,
    ) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskUrlInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'not-a-url');
      await tester.pump();

      // onChanged fires even for invalid URLs
      expect(received, 'not-a-url');
    });

    testWidgets('onChanged fires even for invalid URL', (tester) async {
      String? received;

      await tester.pumpWidget(
        buildInputApp(
          DeskUrlInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'ftp://bad');
      await tester.pump();

      expect(received, 'ftp://bad');
    });

    testWidgets('optional toggle off then on restores last value', (
      tester,
    ) async {
      String? captured;
      await tester.pumpWidget(
        buildInputApp(
          DeskUrlInput(
            field: _optionalField,
            data: const DeskData(value: 'https://example.com', path: 'blog'),
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
      expect(captured, equals('https://example.com'));
    });

    testWidgets('external value flip to null does not fire onChanged', (
      tester,
    ) async {
      var fireCount = 0;
      Widget mk(String? value) => buildInputApp(
        DeskUrlInput(
          field: _optionalField,
          data: value == null ? null : DeskData(value: value, path: 'blog'),
          onChanged: (_) => fireCount++,
        ),
      );

      await tester.pumpWidget(mk('https://example.com'));
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
