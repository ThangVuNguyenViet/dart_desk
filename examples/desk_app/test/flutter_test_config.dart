import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

/// Loads every font declared in any dependency's `flutter: fonts:` block via
/// the test runner's FontManifest.json — same trick golden_toolkit uses.
/// Covers dart_desk's bundled families, shadcn_ui's Geist, and FontAwesome.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await TestFonts.loadAppFonts();
  await testMain();
}
