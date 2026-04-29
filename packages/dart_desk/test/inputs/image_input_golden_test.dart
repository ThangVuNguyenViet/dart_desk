import 'dart:io';

import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/input_test_helpers.dart';

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
          layout: ColumnSceneLayout(),
        )
        .itemFromBuilder(
          tolerancePx: 10000,
          description: 'empty / upload area',
          builder: (_) => buildInputApp(
            DeskImageInput(field: _field, dataSource: dataSource),
          ),
          setup: (t) async => t.pumpAndSettle(),
        )
        .itemFromBuilder(
          tolerancePx: 10000,
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
          setup: (t) async => t.pumpAndSettle(),
        )
        .run(tester);
  });
}
