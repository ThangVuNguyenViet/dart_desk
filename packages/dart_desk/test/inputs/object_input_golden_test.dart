import 'dart:io';

import 'package:dart_desk/src/inputs/object_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

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
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(
          description: 'empty',
          builder: (_) => buildInputApp(const DeskObjectInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'filled',
          builder: (_) => buildInputApp(
            const DeskObjectInput(
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
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
