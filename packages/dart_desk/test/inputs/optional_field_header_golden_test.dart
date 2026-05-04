import 'dart:io';

import 'package:dart_desk/src/inputs/optional_field_header.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/widgets.dart';

void _noop(bool _) {}

void main() {
  testGoldenScene('OptionalFieldHeader gallery', (tester) async {
    await Gallery(
          'OptionalFieldHeader — state variants',
          directory: Directory('goldens'),
          fileName: 'optional_field_header_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 300),
          itemScaffold: shadcnInputItemScaffold,
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'not optional',
          builder: (_) => const OptionalFieldHeader(
            title: 'Article Title',
            isOptional: false,
            isEnabled: true,
            onToggle: _noop,
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional, enabled',
          builder: (_) => const OptionalFieldHeader(
            title: 'Article Title',
            isOptional: true,
            isEnabled: true,
            onToggle: _noop,
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional, disabled',
          builder: (_) => const OptionalFieldHeader(
            title: 'Article Title',
            isOptional: true,
            isEnabled: false,
            onToggle: _noop,
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
