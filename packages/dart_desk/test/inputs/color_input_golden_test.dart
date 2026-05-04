import 'dart:io';

import 'package:dart_desk/src/inputs/color_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

const _field = DeskColorField(
  name: 'brand_color',
  title: 'Brand Color',
  option: DeskColorOption(),
);

void main() {
  testGoldenScene('DeskColorInput gallery', (tester) async {
    await Gallery(
          'DeskColorInput — state variants',
          directory: Directory('goldens'),
          fileName: 'color_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 1200),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty / unset',
          builder: (_) => const DeskColorInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled with red',
          builder: (_) => const DeskColorInput(
            field: _field,
            data: DeskData(value: '#E53E3E', path: 'brand_color'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => const DeskColorInput(
            field: DeskColorField(
              name: 'accent_color',
              title: 'Accent Color (optional)',
              option: DeskColorOption(optional: true),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => const DeskColorInput(
            field: DeskColorField(
              name: 'accent_color',
              title: 'Accent Color (optional)',
              option: DeskColorOption(optional: true),
            ),
            data: DeskData(value: '#E53E3E', path: 'accent_color'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
