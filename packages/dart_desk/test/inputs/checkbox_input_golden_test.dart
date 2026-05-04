import 'dart:io';

import 'package:dart_desk/src/inputs/checkbox_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

const _field = DeskCheckboxField(
  name: 'accept_terms',
  title: 'Accept Terms',
  option: DeskCheckboxOption(label: 'I agree to the terms and conditions'),
);

const _optionalField = DeskCheckboxField(
  name: 'accept_terms',
  title: 'Accept Terms',
  option: DeskCheckboxOption(
    label: 'I agree to the terms and conditions',
    optional: true,
  ),
);

void main() {
  testGoldenScene('DeskCheckboxInput gallery', (tester) async {
    await Gallery(
          'DeskCheckboxInput — state variants',
          directory: Directory('goldens'),
          fileName: 'checkbox_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 1200),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'unchecked',
          builder: (_) => const DeskCheckboxInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'checked',
          builder: (_) => const DeskCheckboxInput(
            field: _field,
            data: DeskData(value: true, path: 'accept_terms'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — null (indeterminate)',
          builder: (_) =>
              const DeskCheckboxInput(field: _optionalField, data: null),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — false',
          builder: (_) => const DeskCheckboxInput(
            field: _optionalField,
            data: DeskData(value: false, path: 'accept_terms'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional — true',
          builder: (_) => const DeskCheckboxInput(
            field: _optionalField,
            data: DeskData(value: true, path: 'accept_terms'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
