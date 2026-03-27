// packages/dart_desk/integration_test/test_utils/screenshot_helper.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Helper for capturing sequential screenshots during integration tests.
///
/// Screenshots are best-effort: if the platform doesn't support capture
/// (e.g. macOS desktop), the call silently logs and continues.
///
/// Usage:
/// ```dart
/// final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
/// final screenshots = ScreenshotHelper(binding, 'tc_01_create');
/// // ... later in test:
/// await screenshots.take(tester, 'after_login');
/// // Produces: "tc_01_create_01_after_login"
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
      await binding.takeScreenshot(name);
    } catch (e) {
      debugPrint('[screenshot] $name skipped: $e');
    }
  }
}
