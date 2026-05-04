import 'dart:io';

import 'package:dart_desk/src/inputs/boolean_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';

const _field = DeskBooleanField(
  name: 'is_active',
  title: 'Is Active',
  option: DeskBooleanOption(),
);

const _optionalField = DeskBooleanField(
  name: 'is_active',
  title: 'Is Active',
  option: DeskBooleanOption(optional: true),
);

void main() {
  testGoldenScene('DeskBooleanInput gallery', (tester) async {
    await Gallery(
      'DeskBooleanInput — state variants',
      directory: Directory('goldens'),
      fileName: 'boolean_input_gallery',
      itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 200),
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'off / unset',
          builder: (_) => buildInputApp(const DeskBooleanInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'on / enabled',
          builder: (_) => buildInputApp(
            const DeskBooleanInput(
              field: _field,
              data: DeskData(value: true, path: 'is_active'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — null (unset)',
          builder: (_) => buildInputApp(
            const DeskBooleanInput(
              field: _optionalField,
              data: null,
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — false',
          builder: (_) => buildInputApp(
            const DeskBooleanInput(
              field: _optionalField,
              data: DeskData(value: false, path: 'is_active'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — true',
          builder: (_) => buildInputApp(
            const DeskBooleanInput(
              field: _optionalField,
              data: DeskData(value: true, path: 'is_active'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
