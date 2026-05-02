import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signals/signals.dart';

/// Logger for Serverpod client request/response activity.
final Logger clientLogger = Logger('dart_desk.client')..level = Level.OFF;

/// Logger for signal/effect updates emitted by [LoggingSignalsObserver].
final Logger signalsLogger = Logger('dart_desk.signals')..level = Level.OFF;

/// Runtime debug flags for the Dart Desk app.
///
/// Built on top of `package:logging`. Flip a flag to raise the matching
/// logger to [Level.ALL] and (the first time any flag is flipped on) install
/// a default printer that forwards records to [debugPrint].
///
/// ```dart
/// void main() {
///   DartDeskDebug.debugShowSignalLogs = true;
///   DartDeskDebug.debugShowClientLog = true;
///   runApp(...);
/// }
/// ```
///
/// Consumers that already configure `Logger.root` can ignore the default
/// printer — flipping a flag still raises the per-logger level so records
/// flow into their existing handler.
class DartDeskDebug {
  DartDeskDebug._();

  static bool _printerInstalled = false;
  static bool _debugShowSignalLogs = false;
  static bool _debugShowClientLog = false;
  static SignalsObserver? _previousObserver;

  /// When `true`, raises [signalsLogger] and installs a [SignalsObserver]
  /// that pipes every signal/effect update through it. Setting back to
  /// `false` restores the previous observer and silences the logger.
  static bool get debugShowSignalLogs => _debugShowSignalLogs;
  static set debugShowSignalLogs(bool value) {
    if (value == _debugShowSignalLogs) return;
    _debugShowSignalLogs = value;
    signalsLogger.level = value ? Level.ALL : Level.OFF;
    if (value) {
      _ensurePrinter();
      _previousObserver = SignalsObserver.instance;
      SignalsObserver.instance = _LoggerSignalsObserver();
    } else {
      SignalsObserver.instance = _previousObserver;
      _previousObserver = null;
    }
  }

  /// When `true`, raises [clientLogger] so Serverpod client request/response
  /// records flow through. Records are emitted from the
  /// `onSucceededCall` / `onFailedCall` hooks on the built-in client.
  static bool get debugShowClientLog => _debugShowClientLog;
  static set debugShowClientLog(bool value) {
    if (value == _debugShowClientLog) return;
    _debugShowClientLog = value;
    clientLogger.level = value ? Level.ALL : Level.OFF;
    if (value) _ensurePrinter();
  }

  static void _ensurePrinter() {
    if (_printerInstalled) return;
    _printerInstalled = true;
    hierarchicalLoggingEnabled = true;
    Logger.root.onRecord.listen((record) {
      final buf = StringBuffer('[${record.loggerName}] ${record.message}');
      if (record.error != null) buf.write(' :: ${record.error}');
      debugPrint(buf.toString());
      if (record.stackTrace != null) {
        debugPrint(record.stackTrace.toString());
      }
    });
  }
}

/// Reuses signals' [LoggingSignalsObserver] formatting, but routes the
/// emitted message through [signalsLogger] instead of `dart:developer.log`.
class _LoggerSignalsObserver extends LoggingSignalsObserver {
  @override
  void log(String message) => signalsLogger.fine(message);
}
