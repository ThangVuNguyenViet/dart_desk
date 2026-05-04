import 'dart:io';

import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

const _field = DeskStringField(
  name: 'title',
  title: 'Article Title',
  option: DeskStringOption(),
);

void main() {
  testGoldenScene('DeskStringInput gallery', (tester) async {
    await Gallery(
          'DeskStringInput — state variants',
          directory: Directory('goldens'),
          fileName: 'string_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 1200),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty',
          builder: (_) => const DeskStringInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled',
          builder: (_) => const DeskStringInput(
            field: _field,
            data: DeskData(value: 'My Awesome Article', path: 'title'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => const DeskStringInput(
            field: DeskStringField(
              name: 'subtitle',
              title: 'Subtitle (optional)',
              option: DeskStringOption(optional: true),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => const DeskStringInput(
            field: DeskStringField(
              name: 'title',
              title: 'Article Title',
              option: DeskStringOption(optional: true),
            ),
            data: DeskData(value: 'My Awesome Article', path: 'title'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
