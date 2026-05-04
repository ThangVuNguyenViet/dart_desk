import 'dart:io';

import 'package:dart_desk/src/inputs/number_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';

const _field = DeskNumberField(
  name: 'price',
  title: 'Price',
  option: DeskNumberOption(min: 0, max: 9999),
);

void main() {
  testGoldenScene('DeskNumberInput gallery', (tester) async {
    await Gallery(
      'DeskNumberInput — state variants',
      directory: Directory('goldens'),
      fileName: 'number_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty',
          builder: (_) => buildInputApp(const DeskNumberInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled',
          builder: (_) => buildInputApp(
            const DeskNumberInput(
              field: _field,
              data: DeskData(value: 42.5, path: 'price'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskNumberInput(
              field: DeskNumberField(
                name: 'discount',
                title: 'Discount (optional)',
                option: DeskNumberOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskNumberInput(
              field: DeskNumberField(
                name: 'discount',
                title: 'Discount (optional)',
                option: DeskNumberOption(optional: true),
              ),
              data: DeskData(value: 42, path: 'discount'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
