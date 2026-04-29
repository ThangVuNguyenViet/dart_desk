import 'dart:io';

import 'package:dart_desk/src/inputs/checkbox_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskCheckboxField(
  name: 'accept_terms',
  title: 'Accept Terms',
  option: DeskCheckboxOption(label: 'I agree to the terms and conditions'),
);

void main() {
  testGoldenScene('DeskCheckboxInput gallery', (tester) async {
    await Gallery(
      'DeskCheckboxInput — state variants',
      directory: Directory('goldens'),
      fileName: 'checkbox_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(
          tolerancePx: 10000,
          description: 'unchecked',
          builder: (_) =>
              buildInputApp(const DeskCheckboxInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: 10000,
          description: 'checked',
          builder: (_) => buildInputApp(
            const DeskCheckboxInput(
              field: _field,
              data: DeskData(value: true, path: 'accept_terms'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
