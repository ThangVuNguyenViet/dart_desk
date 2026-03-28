// packages/dart_desk/integration_test/test_utils/screenshot_helper.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Helper for capturing sequential screenshots during integration tests.
///
/// Uses direct layer-to-image rendering instead of `binding.takeScreenshot()`
/// which is not implemented on macOS desktop.
///
/// Usage:
/// ```dart
/// final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
/// final screenshots = ScreenshotHelper(binding, 'tc_01_create');
/// // ... later in test:
/// await screenshots.take(tester, 'after_login');
/// // Produces: "integration_test/screenshots/tc_01_create_01_after_login.png"
/// ```
class ScreenshotHelper {
  ScreenshotHelper(this.binding, this.testName);

  final IntegrationTestWidgetsFlutterBinding binding;
  final String testName;
  int _step = 0;

  Future<void> take(WidgetTester tester, String label) async {
    _step++;
    final stepStr = _step.toString().padLeft(2, '0');
    final name = '${testName}_${stepStr}_$label';
    try {
      final renderView = binding.renderViews.first;
      final layer = renderView.debugLayer! as OffsetLayer;
      final image = await layer.toImage(renderView.paintBounds);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final dir = Directory('integration_test/screenshots');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/$name.png');
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
      debugPrint('[screenshot] Saved ${file.path}');
    } catch (e) {
      debugPrint('[screenshot] $name skipped: $e');
    }
  }
}
