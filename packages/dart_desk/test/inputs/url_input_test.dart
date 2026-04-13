import 'package:dart_desk/src/inputs/url_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = CmsUrlField(
    name: 'website',
    title: 'Website',
    option: CmsUrlOption(),
  );

  group('CmsUrlInput', () {
    testWidgets('renders with initial URL', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          CmsUrlInput(
            field: field,
            data: const CmsData(value: 'https://example.com', path: 'website'),
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
          CmsUrlInput(field: field, onChanged: (v) => received = v),
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
          CmsUrlInput(field: field, onChanged: (v) => received = v),
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
          CmsUrlInput(field: field, onChanged: (v) => received = v),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(ShadInputFormField), 'ftp://bad');
      await tester.pump();

      expect(received, 'ftp://bad');
    });
  });
}
