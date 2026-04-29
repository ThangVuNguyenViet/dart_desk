import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_bricks/golden_bricks.dart';

/// See packages/dart_desk/test/flutter_test_config.dart. Tests opt the app
/// theme into [goldenBricks] via `goldenBricksTheme()`; this just makes the
/// font available to the loader.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await rootBundle.load(
    'packages/golden_bricks/golden_bricks.ttf',
  );
  final loader = FontLoader(goldenBricks)..addFont(Future.value(bytes));
  await loader.load();
  await testMain();
}
