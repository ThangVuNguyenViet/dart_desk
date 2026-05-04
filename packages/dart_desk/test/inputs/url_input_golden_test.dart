import 'dart:io';

import 'package:dart_desk/src/inputs/url_input.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';

const _field = DeskUrlField(
  name: 'website',
  title: 'Website URL',
  option: DeskUrlOption(),
);

void main() {
  testGoldenScene('DeskUrlInput gallery', (tester) async {
    await Gallery(
      'DeskUrlInput — state variants',
      directory: Directory('goldens'),
      fileName: 'url_input_gallery',
      itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 200),
      layout: ColumnSceneLayout(),
    )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty',
          builder: (_) => buildInputApp(const DeskUrlInput(field: _field)),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled with valid URL',
          builder: (_) => buildInputApp(
            const DeskUrlInput(
              field: _field,
              data: DeskData(
                value: 'https://example.com',
                path: 'website',
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            const DeskUrlInput(
              field: DeskUrlField(
                name: 'blog',
                title: 'Blog URL (optional)',
                option: DeskUrlOption(optional: true),
              ),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            const DeskUrlInput(
              field: DeskUrlField(
                name: 'blog',
                title: 'Blog URL (optional)',
                option: DeskUrlOption(optional: true),
              ),
              data: DeskData(value: 'https://example.com', path: 'blog'),
            ),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
