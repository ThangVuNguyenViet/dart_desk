import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_bricks/golden_bricks.dart';

/// See packages/dart_desk/test/flutter_test_config.dart. Tests opt the app
/// theme into [goldenBricks] via `goldenBricksTheme()`; this just makes the
/// font available to the loader and installs the same tolerant comparator
/// for `matchesGoldenFile` to absorb macOS↔Linux rendering drift.
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

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(Uri testFile) : super(testFile);

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
