import 'dart:io';

import 'package:dart_desk/src/inputs/geopoint_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskGeopointField(
  name: 'location',
  title: 'Location',
  option: DeskGeopointOption(),
);

void main() {
  testGoldenScene('DeskGeopointInput gallery', (tester) async {
    await Gallery(
      'DeskGeopointInput — state variants',
      directory: Directory('goldens'),
      fileName: 'geopoint_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty',
          builder: (_) =>
              buildInputApp(const DeskGeopointInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'filled with coordinates',
          builder: (_) => buildInputApp(
            const DeskGeopointInput(
              field: _field,
              data: DeskData(
                value: {'lat': 37.7749, 'lng': -122.4194},
                path: 'location',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskGeopointInput(
              field: DeskGeopointField(
                name: 'location',
                title: 'Location',
                option: DeskGeopointOption(optional: true),
              ),
              data: DeskData(
                value: {'lat': 37.7749, 'lng': -122.4194},
                path: 'location',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskGeopointInput(
              field: DeskGeopointField(
                name: 'location',
                title: 'Location',
                option: DeskGeopointOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
