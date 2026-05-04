import 'dart:io';

import 'package:dart_desk/src/inputs/file_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskFileField(
  name: 'document',
  title: 'Document Upload',
  option: DeskFileOption(),
);

void main() {
  testGoldenScene('DeskFileInput gallery', (tester) async {
    await Gallery(
      'DeskFileInput — empty state variants',
      directory: Directory('goldens'),
      fileName: 'file_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'upload button when no file',
          builder: (_) => buildInputApp(DeskFileInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'title label visible',
          builder: (_) => buildInputApp(DeskFileInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            DeskFileInput(
              field: const DeskFileField(
                name: 'document',
                title: 'Document Upload (optional)',
                option: DeskFileOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            DeskFileInput(
              field: const DeskFileField(
                name: 'document',
                title: 'Document Upload (optional)',
                option: DeskFileOption(optional: true),
              ),
              data: const DeskData(
                value: 'https://example.com/report.pdf',
                path: 'document',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
