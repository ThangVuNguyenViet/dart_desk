import 'dart:io';

import 'package:dart_desk/src/data/models/image_types.dart';
import 'package:dart_desk/src/inputs/hotspot/framing_controller.dart';
import 'package:dart_desk/src/inputs/hotspot/image_hotspot_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/input_test_helpers.dart';

void main() {
  setUpAll(() {
    initTestPngBytes();
    HttpOverrides.global = FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('ImageHotspotEditor golden', () {
    Future<void> pumpEditor(
      WidgetTester tester, {
      Hotspot? hotspot,
      CropRect? crop,
      FramingMode mode = FramingMode.focus,
    }) async {
      await tester.pumpWidget(
        buildInputApp(
          SizedBox(
            width: 600,
            child: ImageHotspotEditor(
              imageUrl: 'https://test.example.com/image.png',
              initialHotspot: hotspot,
              initialCrop: crop,
              initialMode: mode,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('focus mode default', (tester) async {
      await pumpEditor(tester);
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_focus_default.png'),
      );
    });

    testWidgets('crop mode default', (tester) async {
      await pumpEditor(tester, mode: FramingMode.crop);
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_crop_default.png'),
      );
    });

    testWidgets('preview mode default', (tester) async {
      await pumpEditor(tester, mode: FramingMode.preview);
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_preview_default.png'),
      );
    });

    testWidgets('focus mode with custom hotspot', (tester) async {
      await pumpEditor(
        tester,
        hotspot: const Hotspot(x: 0.3, y: 0.7, width: 0.4, height: 0.25),
      );
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_focus_custom.png'),
      );
    });

    testWidgets('crop mode with custom crop', (tester) async {
      await pumpEditor(
        tester,
        mode: FramingMode.crop,
        crop: const CropRect(top: 0.1, bottom: 0.15, left: 0.2, right: 0.1),
      );
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_crop_custom.png'),
      );
    });

    testWidgets('preview mode with custom hotspot and crop', (tester) async {
      await pumpEditor(
        tester,
        mode: FramingMode.preview,
        hotspot: const Hotspot(x: 0.3, y: 0.7, width: 0.4, height: 0.25),
        crop: const CropRect(top: 0.1, bottom: 0.15, left: 0.2, right: 0.1),
      );
      await expectLater(
        find.byKey(const ValueKey('hotspot_editor')),
        matchesGoldenFile('goldens/hotspot_editor_preview_custom.png'),
      );
    });
  });
}
