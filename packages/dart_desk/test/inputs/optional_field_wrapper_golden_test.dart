import 'dart:io';

import 'package:dart_desk/src/inputs/optional_field_wrapper.dart';
import 'package:dart_desk/src/inputs/string_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _inner = DeskStringInput(
  field: DeskStringField(
    name: 'subtitle',
    title: 'Subtitle',
    option: DeskStringOption(),
  ),
  data: DeskData(value: 'An optional subtitle value', path: 'subtitle'),
);

void main() {
  testGoldenScene('OptionalFieldWrapper gallery', (tester) async {
    await Gallery(
      'OptionalFieldWrapper — enabled vs disabled',
      directory: Directory('goldens'),
      fileName: 'optional_field_wrapper_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'enabled — full opacity, interactive',
          builder: (_) => buildInputApp(
            const OptionalFieldWrapper(isEnabled: true, child: _inner),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'disabled — dimmed to 0.4 opacity',
          builder: (_) => buildInputApp(
            const OptionalFieldWrapper(isEnabled: false, child: _inner),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
