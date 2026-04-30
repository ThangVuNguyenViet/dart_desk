import 'dart:io';

import 'package:dart_desk/src/inputs/optional_field_header.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';

void _noop(bool _) {}

void main() {
  testGoldenScene('OptionalFieldHeader gallery', (tester) async {
    await Gallery(
      'OptionalFieldHeader — state variants',
      directory: Directory('goldens'),
      fileName: 'optional_field_header_gallery',
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(          description: 'not optional',
          builder: (_) => buildInputApp(
            const OptionalFieldHeader(
              title: 'Article Title',
              isOptional: false,
              isEnabled: true,
              onToggle: _noop,
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional, enabled',
          builder: (_) => buildInputApp(
            const OptionalFieldHeader(
              title: 'Article Title',
              isOptional: true,
              isEnabled: true,
              onToggle: _noop,
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(          description: 'optional, disabled',
          builder: (_) => buildInputApp(
            const OptionalFieldHeader(
              title: 'Article Title',
              isOptional: true,
              isEnabled: false,
              onToggle: _noop,
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
