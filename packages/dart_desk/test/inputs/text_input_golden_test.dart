import 'dart:io';

import 'package:dart_desk/src/inputs/text_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskTextField(
  name: 'body',
  title: 'Body Text',
  option: DeskTextOption(rows: 4),
);

void main() {
  testGoldenScene('DeskTextInput gallery', (tester) async {
    await Gallery(
      'DeskTextInput — state variants',
      directory: Directory('goldens'),
      fileName: 'text_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty',
          builder: (_) => buildInputApp(const DeskTextInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'filled',
          builder: (_) => buildInputApp(
            const DeskTextInput(
              field: _field,
              data: DeskData(
                value:
                    'This is a longer body text that spans multiple lines and shows how the textarea looks when populated with content.',
                path: 'body',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskTextInput(
              field: DeskTextField(
                name: 'notes',
                title: 'Notes (optional)',
                option: DeskTextOption(rows: 3, optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskTextInput(
              field: DeskTextField(
                name: 'notes',
                title: 'Notes (optional)',
                option: DeskTextOption(rows: 3, optional: true),
              ),
              data: DeskData(value: 'Some notes here', path: 'notes'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
