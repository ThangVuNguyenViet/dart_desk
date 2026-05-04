import 'dart:io';

import 'package:dart_desk/src/inputs/date_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import 'package:dart_desk/testing.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskDateField(
  name: 'publish_date',
  title: 'Publish Date',
  option: DeskDateOption(),
);

void main() {
  testGoldenScene('DeskDateInput gallery', (tester) async {
    await Gallery(
          'DeskDateInput — state variants',
          directory: Directory('goldens'),
          fileName: 'date_input_gallery',
          // Give each item enough width so ShadDatePickerFormField doesn't overflow.
          itemConstraints: const BoxConstraints(
            minWidth: 500,
            maxWidth: 500,
            maxHeight: 1200,
          ),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty',
          builder: (_) => const DeskDateInput(field: _field),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled',
          builder: (_) => const DeskDateInput(
            field: _field,
            data: DeskData(value: '2026-04-28', path: 'publish_date'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => const DeskDateInput(
            field: DeskDateField(
              name: 'publish_date',
              title: 'Publish Date (optional)',
              option: DeskDateOption(optional: true),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => const DeskDateInput(
            field: DeskDateField(
              name: 'publish_date',
              title: 'Publish Date (optional)',
              option: DeskDateOption(optional: true),
            ),
            data: DeskData(value: '2026-04-28', path: 'publish_date'),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
