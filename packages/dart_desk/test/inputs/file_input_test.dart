import 'package:dart_desk/src/inputs/file_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  const field = DeskFileField(
    name: 'document',
    title: 'Document Upload',
    option: DeskFileOption(),
  );

  group('DeskFileInput', () {
    testWidgets('renders upload button when no file', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskFileInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Upload File'), findsOneWidget);
    });

    testWidgets('renders title label', (tester) async {
      await tester.pumpWidget(buildInputApp(DeskFileInput(field: field)));
      await tester.pumpAndSettle();

      expect(find.text('Document Upload'), findsOneWidget);
    });
  });
}
