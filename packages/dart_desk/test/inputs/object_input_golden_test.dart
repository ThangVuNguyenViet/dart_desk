import 'dart:io';

import 'package:dart_desk/src/inputs/object_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

const _field = DeskObjectField(
  name: 'address',
  title: 'Address',
  option: DeskObjectOption(
    children: [
      ColumnFields(
        children: [
          DeskStringField(
            name: 'street',
            title: 'Street',
            option: DeskStringOption(),
          ),
        ],
      ),
      RowFields(
        children: [
          DeskStringField(
            name: 'city',
            title: 'City',
            option: DeskStringOption(),
          ),
          DeskStringField(
            name: 'zip',
            title: 'ZIP Code',
            option: DeskStringOption(),
          ),
        ],
      ),
    ],
  ),
);

void main() {
  testGoldenScene('DeskObjectInput gallery', (tester) async {
    await Gallery(
          'DeskObjectInput — state variants',
          directory: Directory('goldens'),
          fileName: 'object_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 1200),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty',
          builder: (_) => const DeskObjectInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled',
          builder: (_) => const DeskObjectInput(
            field: _field,
            data: DeskData(
              value: {
                'street': '123 Main St',
                'city': 'San Francisco',
                'zip': '94105',
              },
              path: 'address',
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => const DeskObjectInput(
            field: DeskObjectField(
              name: 'address',
              title: 'Address',
              option: DeskObjectOption(
                optional: true,
                children: [
                  ColumnFields(
                    children: [
                      DeskStringField(
                        name: 'street',
                        title: 'Street',
                        option: DeskStringOption(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            data: DeskData(value: {'street': '123 Main St'}, path: 'address'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => const DeskObjectInput(
            field: DeskObjectField(
              name: 'address',
              title: 'Address',
              option: DeskObjectOption(
                optional: true,
                children: [
                  ColumnFields(
                    children: [
                      DeskStringField(
                        name: 'street',
                        title: 'Street',
                        option: DeskStringOption(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
