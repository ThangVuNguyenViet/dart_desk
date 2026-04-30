import 'dart:io';

import 'package:dart_desk/src/inputs/boolean_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskBooleanField(
  name: 'is_active',
  title: 'Is Active',
  option: DeskBooleanOption(),
);

void main() {
  testGoldenScene('DeskBooleanInput gallery', (tester) async {
    await Gallery(
      'DeskBooleanInput — state variants',
      directory: Directory('goldens'),
      fileName: 'boolean_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'off / unset',
          builder: (_) => buildInputApp(const DeskBooleanInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'on / enabled',
          builder: (_) => buildInputApp(
            const DeskBooleanInput(
              field: _field,
              data: DeskData(value: true, path: 'is_active'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
