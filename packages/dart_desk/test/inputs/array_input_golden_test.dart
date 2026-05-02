import 'dart:io';

import 'package:dart_desk/src/inputs/array_input.dart';
import 'package:dart_desk/testing.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

final _field = DeskArrayField<String>(
  name: 'tags',
  title: 'Tags',
  innerField: const DeskStringField(name: 'tag', title: 'Tag'),
  option: const TestStringArrayOption(),
);

final _optionalField = DeskArrayField<String>(
  name: 'tags',
  title: 'Tags',
  innerField: const DeskStringField(name: 'tag', title: 'Tag'),
  option: const DeskArrayOption<String>(optional: true),
);

void main() {
  testGoldenScene('DeskArrayInput gallery', (tester) async {
    await Gallery(
      'DeskArrayInput — state variants',
      directory: Directory('goldens'),
      fileName: 'array_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty list',
          builder: (_) => buildInputApp(
            DeskArrayInput<String>(
              field: _field,
              data: const DeskData(value: [], path: 'tags'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'populated list',
          builder: (_) => buildInputApp(
            DeskArrayInput<String>(
              field: _field,
              data: const DeskData(
                value: ['flutter', 'dart', 'mobile'],
                path: 'tags',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            DeskArrayInput<String>(
              field: _optionalField,
              data: const DeskData(
                value: ['flutter', 'dart'],
                path: 'tags',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            DeskArrayInput<String>(field: _optionalField),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
