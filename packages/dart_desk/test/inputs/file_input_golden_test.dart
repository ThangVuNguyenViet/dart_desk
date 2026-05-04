import 'dart:io';

import 'package:dart_desk/src/inputs/file_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

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
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 300),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'upload button when no file',
          builder: (_) => DeskFileInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'title label visible',
          builder: (_) => DeskFileInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => DeskFileInput(
            field: const DeskFileField(
              name: 'document',
              title: 'Document Upload (optional)',
              option: DeskFileOption(optional: true),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => DeskFileInput(
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
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
