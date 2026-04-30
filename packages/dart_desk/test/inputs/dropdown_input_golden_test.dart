import 'dart:io';

import 'package:dart_desk/src/inputs/dropdown_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskDropdownField<String>(
  name: 'category',
  title: 'Category',
  option: DeskDropdownSimpleOption(
    options: [
      DropdownOption(value: 'tech', label: 'Technology'),
      DropdownOption(value: 'health', label: 'Health & Wellness'),
      DropdownOption(value: 'finance', label: 'Finance'),
    ],
    placeholder: 'Select a category',
  ),
);

void main() {
  testGoldenScene('DeskDropdownInput gallery', (tester) async {
    await Gallery(
      'DeskDropdownInput — state variants',
      directory: Directory('goldens'),
      fileName: 'dropdown_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty / unselected',
          builder: (_) =>
              buildInputApp(const DeskDropdownInput<String>(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'selected value',
          builder: (_) => buildInputApp(
            const DeskDropdownInput<String>(
              field: _field,
              data: DeskData(value: 'tech', path: 'category'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
