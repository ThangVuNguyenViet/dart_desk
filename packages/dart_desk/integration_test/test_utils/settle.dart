// packages/dart_desk/integration_test/test_utils/settle.dart
import 'package:flutter_test/flutter_test.dart';

/// Default timeout for [pumpAndSettle] across all integration tests.
/// Nothing in the app should take longer than this to settle.
const _kSettleTimeout = Duration(minutes: 1);

extension SettleExtension on WidgetTester {
  /// [pumpAndSettle] with a 3-second timeout so tests fail fast instead of
  /// hanging indefinitely when a timer or stream keeps the event loop alive.
  Future<void> settle([Duration? duration]) async {
    await pumpAndSettle(
      duration ?? Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      _kSettleTimeout,
    );
  }
}
