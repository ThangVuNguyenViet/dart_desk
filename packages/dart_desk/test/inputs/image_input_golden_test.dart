import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/input_test_helpers.dart';
import 'package:dart_desk/testing.dart';

class _MockDataSource extends Mock implements DataSource {}

const _field = DeskImageField(
  name: 'hero',
  title: 'Hero Image',
  option: DeskImageOption(hotspot: false),
);

void main() {
  setUpAll(() {
    initTestPngBytes();
    installSuperDragAndDropMocks();
    HttpOverrides.global = FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testGoldenScene('DeskImageInput gallery', (tester) async {
    final dataSource = _MockDataSource();

    await Gallery(
          'DeskImageInput — state variants',
          directory: Directory('goldens'),
          fileName: 'image_input_gallery',
          itemConstraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'empty / upload area',
          builder: (_) => buildInputApp(
            DeskImageInput(field: _field, dataSource: dataSource),
          ),
          setup: (t) async {
            for (var i = 0; i < 5; i++) {
              await t.pump(const Duration(milliseconds: 100));
            }
          },
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'filled with external URL',
          builder: (_) => buildInputApp(
            DeskImageInput(
              field: _field,
              dataSource: dataSource,
              data: const DeskData(
                value: {
                  'type': 'external',
                  'url': 'https://cdn.example.com/hero.png',
                },
                path: 'hero',
              ),
            ),
          ),
          setup: (t) async {
            for (var i = 0; i < 5; i++) {
              await t.pump(const Duration(milliseconds: 100));
            }
          },
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / enabled',
          builder: (_) => buildInputApp(
            DeskImageInput(
              field: const DeskImageField(
                name: 'hero',
                title: 'Hero Image',
                option: DeskImageOption(hotspot: false, optional: true),
              ),
              dataSource: dataSource,
              data: const DeskData(
                value: {
                  '_type': 'imageReference',
                  'externalUrl': 'https://cdn.example.com/hero.png',
                },
                path: 'hero',
              ),
            ),
          ),
          setup: (t) async {
            for (var i = 0; i < 5; i++) {
              await t.pump(const Duration(milliseconds: 100));
            }
          },
        )
        .itemFromBuilder(
          tolerancePx: kGoldenTolerancePx,
          description: 'optional / disabled',
          builder: (_) => buildInputApp(
            DeskImageInput(
              field: const DeskImageField(
                name: 'hero',
                title: 'Hero Image',
                option: DeskImageOption(hotspot: false, optional: true),
              ),
              dataSource: dataSource,
            ),
          ),
          setup: (t) async {
            for (var i = 0; i < 5; i++) {
              await t.pump(const Duration(milliseconds: 100));
            }
          },
        )
        .run(tester);
  });
}
