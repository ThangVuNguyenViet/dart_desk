import 'dart:io';

import 'package:dart_desk/src/inputs/block_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskBlockField(
  name: 'content',
  title: 'Content',
  option: DeskBlockOption(),
);

void main() {
  testGoldenScene('DeskBlockInput gallery', (tester) async {
    await Gallery(
      'DeskBlockInput — state variants',
      directory: Directory('goldens'),
      fileName: 'block_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty editor',
          builder: (_) => buildInputApp(const DeskBlockInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'pre-filled with text',
          builder: (_) => buildInputApp(
            const DeskBlockInput(
              field: _field,
              data: DeskData(
                value: 'This is a **bold** example paragraph.',
                path: 'content',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskBlockInput(
              field: DeskBlockField(
                name: 'content',
                title: 'Content',
                option: DeskBlockOption(optional: true),
              ),
              data: DeskData(value: 'Hello world', path: 'content'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskBlockInput(
              field: DeskBlockField(
                name: 'content',
                title: 'Content',
                option: DeskBlockOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
