import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_bricks/golden_bricks.dart';

/// Loads the GoldenBricks font under its canonical family name. Test helpers
/// (`buildInputApp`, etc.) opt their app theme into [goldenBricks] via
/// [goldenBricksTheme]; widgets outside that theme get Flutter's Ahem
/// fallback, which is also host-independent.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await rootBundle.load(
    'packages/golden_bricks/golden_bricks.ttf',
  );
  final loader = FontLoader(goldenBricks)..addFont(Future.value(bytes));
  await loader.load();
  await testMain();
}
