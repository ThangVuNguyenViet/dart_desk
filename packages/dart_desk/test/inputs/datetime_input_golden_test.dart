import 'dart:io';

import 'package:dart_desk/src/inputs/datetime_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

const _field = DeskDateTimeField(
  name: 'created_at',
  title: 'Created At',
  option: DeskDateTimeOption(),
);

void main() {
  testGoldenScene('DeskDateTimeInput gallery', (tester) async {
    await Gallery(
      'DeskDateTimeInput — state variants',
      directory: Directory('goldens'),
      fileName: 'datetime_input_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'empty',
          builder: (_) =>
              buildInputApp(const DeskDateTimeInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'filled',
          builder: (_) => buildInputApp(
            const DeskDateTimeInput(
              field: _field,
              data: DeskData(
                value: '2026-04-28T14:30:00.000',
                path: 'created_at',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskDateTimeInput(
              field: DeskDateTimeField(
                name: 'created_at',
                title: 'Created At (optional)',
                option: DeskDateTimeOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskDateTimeInput(
              field: DeskDateTimeField(
                name: 'created_at',
                title: 'Created At (optional)',
                option: DeskDateTimeOption(optional: true),
              ),
              data: DeskData(
                value: '2026-04-28T14:30:00.000',
                path: 'created_at',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
