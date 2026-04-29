import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_bricks/golden_bricks.dart';

/// Loads the GoldenBricks font under its canonical family name. Test helpers
/// (`buildInputApp`, etc.) opt their app theme into [goldenBricks] via
/// [goldenBricksTheme]; widgets outside that theme get Flutter's Ahem
/// fallback, which is also host-independent.
///
/// Also installs a [_TolerantComparator] so `matchesGoldenFile` accepts a
/// small per-pixel + per-channel diff. macOS (CoreText) and Linux
/// (FreeType) render the same scene with sub-pixel drift even with
/// GoldenBricks; without tolerance, CI on Linux fails goldens authored on
/// macOS.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await rootBundle.load(
    'packages/golden_bricks/golden_bricks.ttf',
  );
  final loader = FontLoader(goldenBricks)..addFont(Future.value(bytes));
  await loader.load();

  final defaultComparator = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _TolerantComparator(
    defaultComparator.basedir.resolve('flutter_test_config.dart'),
  );

  await testMain();
}

/// Wraps the default [LocalFileComparator] with a per-pixel diff threshold.
/// Allows up to [_kPixelTolerance] of pixels to differ by any amount before
/// failing — covers macOS↔Linux antialiasing drift on text and borders.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const double _kPixelTolerance = 0.05;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || (result.diffPercent <= _kPixelTolerance)) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
