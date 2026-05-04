import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

const _field = DeskMultiDropdownField<String>(
  name: 'tags',
  title: 'Tags',
  option: DeskMultiDropdownSimpleOption(
    options: [
      DropdownOption(value: 'flutter', label: 'Flutter'),
      DropdownOption(value: 'dart', label: 'Dart'),
      DropdownOption(value: 'mobile', label: 'Mobile'),
      DropdownOption(value: 'backend', label: 'Backend'),
    ],
    placeholder: 'Select tags',
  ),
);

void main() {
  testGoldenScene('DeskMultiDropdownInput gallery', (tester) async {
    await Gallery(
          'DeskMultiDropdownInput — state variants',
          directory: Directory('goldens'),
          fileName: 'multi_dropdown_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 1200),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty / unselected',
          builder: (_) => const DeskMultiDropdownInput<String>(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'two items selected',
          builder: (_) => const DeskMultiDropdownInput<String>(
            field: _field,
            data: DeskData(value: ['flutter', 'dart'], path: 'tags'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => const DeskMultiDropdownInput<String>(
            field: DeskMultiDropdownField<String>(
              name: 'tags',
              title: 'Tags',
              option: DeskMultiDropdownSimpleOption(
                options: [
                  DropdownOption(value: 'flutter', label: 'Flutter'),
                  DropdownOption(value: 'dart', label: 'Dart'),
                ],
                placeholder: 'Select tags',
                optional: true,
              ),
            ),
            data: DeskData(value: ['flutter'], path: 'tags'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => const DeskMultiDropdownInput<String>(
            field: DeskMultiDropdownField<String>(
              name: 'tags',
              title: 'Tags',
              option: DeskMultiDropdownSimpleOption(
                options: [
                  DropdownOption(value: 'flutter', label: 'Flutter'),
                  DropdownOption(value: 'dart', label: 'Dart'),
                ],
                placeholder: 'Select tags',
                optional: true,
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
