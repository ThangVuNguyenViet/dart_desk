import 'dart:io';

import 'package:dart_desk/src/data/models/image_types.dart';
import 'package:dart_desk/src/inputs/hotspot/framing_controller.dart';
import 'package:dart_desk/src/inputs/hotspot/framing_math.dart';
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

  group('ImageHotspotEditor', () {
    testWidgets('renders crop focus and preview modes', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hotspot_editor')), findsOneWidget);
      expect(find.text('Edit Framing'), findsOneWidget);
      expect(find.byKey(const ValueKey('framing_mode_focus')), findsOneWidget);
      expect(find.byKey(const ValueKey('framing_mode_crop')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('framing_mode_preview')),
        findsOneWidget,
      );
    });

    testWidgets('cancel does not fire callback', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onChanged: (_) => callCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('cancel_button')));
      await tester.tap(find.byKey(const ValueKey('cancel_button')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('transform mode segment is selectable', (tester) async {
      FramingMode? lastMode;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onModeChanged: (value) => lastMode = value,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('framing_mode_transform')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('framing_mode_transform')));
      await tester.pump();

      expect(lastMode, FramingMode.transform);
    });

    testWidgets('reset focus preserves crop', (tester) async {
      late ({Hotspot? hotspot, CropRect? crop, double? scale, Offset? offset})
      result;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            initialHotspot: const Hotspot(
              x: 0.8,
              y: 0.2,
              width: 0.2,
              height: 0.2,
            ),
            initialCrop: const CropRect(
              top: 0.1,
              bottom: 0.2,
              left: 0.15,
              right: 0.05,
            ),
            onChanged: (value) => result = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('reset_focus_button')),
      );
      await tester.tap(find.byKey(const ValueKey('reset_focus_button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('apply_button')));
      await tester.tap(find.byKey(const ValueKey('apply_button')));
      await tester.pumpAndSettle();

      expect(
        result.crop,
        const CropRect(top: 0.1, bottom: 0.2, left: 0.15, right: 0.05),
      );
      expect(result.hotspot!.x, FramingDefaults.defaultHotspot.x);
      expect(result.hotspot!.y, FramingDefaults.defaultHotspot.y);
      expect(result.hotspot!.width, FramingDefaults.defaultHotspot.width);
      expect(result.hotspot!.height, FramingDefaults.defaultHotspot.height);
    });

    testWidgets('onLiveChange fires when mode changes', (tester) async {
      int liveCount = 0;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onLiveChange: (_) => liveCount++,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialCount = liveCount;
      await tester.tap(find.byKey(const ValueKey('framing_mode_crop')));
      await tester.pump();

      expect(liveCount, greaterThan(initialCount));
    });

    testWidgets('scale slider hidden outside transform mode', (tester) async {
      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('scale_slider_0')), findsNothing);
      expect(find.text('Scale'), findsNothing);
    });

    testWidgets('scale slider visible in transform mode with readout', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            initialMode: FramingMode.transform,
            initialScale: 2.5,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('scale_slider_0')), findsOneWidget);
      expect(find.text('Scale'), findsOneWidget);
      expect(find.text('2.50×'), findsOneWidget);
    });

    testWidgets('reset transform restores default scale and re-keys slider', (
      tester,
    ) async {
      late ({Hotspot? hotspot, CropRect? crop, double? scale, Offset? offset})
      result;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            initialMode: FramingMode.transform,
            initialScale: 3.0,
            initialOffset: const Offset(0.2, 0.1),
            onChanged: (value) => result = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('scale_slider_0')), findsOneWidget);
      expect(find.text('3.00×'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const ValueKey('reset_transform_button')),
      );
      await tester.tap(find.byKey(const ValueKey('reset_transform_button')));
      await tester.pumpAndSettle();

      // Tick bumps the slider key on reset.
      expect(find.byKey(const ValueKey('scale_slider_1')), findsOneWidget);
      expect(find.text('1.00×'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('apply_button')));
      await tester.tap(find.byKey(const ValueKey('apply_button')));
      await tester.pumpAndSettle();

      expect(result.scale, isNull);
      expect(result.offset, isNull);
    });

    testWidgets('calls onModeChanged when switching modes', (tester) async {
      FramingMode? mode;

      await tester.pumpWidget(
        buildInputApp(
          ImageHotspotEditor(
            imageUrl: 'https://test.example.com/image.png',
            onModeChanged: (value) => mode = value,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('framing_mode_preview')));
      await tester.pumpAndSettle();

      expect(mode, FramingMode.preview);
    });
  });
}
