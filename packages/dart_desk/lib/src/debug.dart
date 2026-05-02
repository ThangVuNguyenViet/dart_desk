import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signals/signals.dart';

/// Logger for Serverpod client request/response activity.
///
/// Failures (`severe`) are always emitted. Successes (`info`) only emit when
/// [DartDeskDebug.debugShowClientLog] is on.
final Logger clientLogger = _makeLogger('dart_desk.client', Level.SEVERE);

/// Logger for signal/effect updates. Records only flow when
/// [DartDeskDebug.debugShowSignalLogs] is on, which installs a
/// [SignalsObserver] that emits through this logger.
final Logger signalsLogger = _makeLogger('dart_desk.signals', Level.OFF);

/// Runtime debug flags for the Dart Desk app.
///
/// Built on `package:logging`. A default `debugPrint` listener is installed
/// the first time either logger is read so failure logs always appear, even
/// if the consumer never flips a flag.
///
/// ```dart
/// void main() {
///   DartDeskDebug.debugShowSignalLogs = true;
///   DartDeskDebug.debugShowClientLog = true;
///   runApp(...);
/// }
/// ```
///
/// Consumers that already configure `Logger.root` will see records on both
/// their handler and the default printer. To suppress ours, set
/// [DartDeskDebug.suppressDefaultPrinter] to `true` before either logger
/// is first accessed.
class DartDeskDebug {
  DartDeskDebug._();

  static bool _debugShowSignalLogs = false;
  static bool _debugShowClientLog = false;
  static SignalsObserver? _previousObserver;

  /// Set to `true` before importing/using Dart Desk to skip installing the
  /// default `debugPrint` root listener. Useful when the consumer has
  /// already wired its own logging routing.
  static bool suppressDefaultPrinter = false;

  /// When `true`, raises [signalsLogger] to [Level.ALL] and installs a
  /// [SignalsObserver] that pipes every signal/effect update through it.
  /// Restoring `false` reinstates the previous observer and silences the
  /// logger.
  static bool get debugShowSignalLogs => _debugShowSignalLogs;
  static set debugShowSignalLogs(bool value) {
    if (value == _debugShowSignalLogs) return;
    _debugShowSignalLogs = value;
    if (value) {
      signalsLogger.level = Level.ALL;
      _previousObserver = SignalsObserver.instance;
      SignalsObserver.instance = _LoggerSignalsObserver();
    } else {
      signalsLogger.level = Level.OFF;
      SignalsObserver.instance = _previousObserver;
      _previousObserver = null;
    }
  }

  /// When `true`, raises [clientLogger] to [Level.ALL] so successful client
  /// calls log alongside failures. When `false`, only failures
  /// (`Level.SEVERE`) are emitted.
  static bool get debugShowClientLog => _debugShowClientLog;
  static set debugShowClientLog(bool value) {
    if (value == _debugShowClientLog) return;
    _debugShowClientLog = value;
    clientLogger.level = value ? Level.ALL : Level.SEVERE;
  }
}

bool _loggingBootstrapped = false;

/// Idempotent. Enables hierarchical logging and (optionally) attaches the
/// default `debugPrint` listener. Called from each logger's initializer so
/// it runs the first time either logger is accessed.
void _bootstrapLogging() {
  if (_loggingBootstrapped) return;
  _loggingBootstrapped = true;
  hierarchicalLoggingEnabled = true;
  if (DartDeskDebug.suppressDefaultPrinter) return;
  Logger.root.onRecord.listen((record) {
    final buf = StringBuffer(
      '[${record.loggerName}] ${record.level.name}: ${record.message}',
    );
    if (record.error != null) buf.write(' :: ${record.error}');
    debugPrint(buf.toString());
    if (record.stackTrace != null) {
      debugPrint(record.stackTrace.toString());
    }
  });
}

Logger _makeLogger(String name, Level initialLevel) {
  _bootstrapLogging();
  return Logger(name)..level = initialLevel;
}

/// Reuses signals' [LoggingSignalsObserver] formatting, but routes the
/// emitted message through [signalsLogger] instead of `dart:developer.log`.
class _LoggerSignalsObserver extends LoggingSignalsObserver {
  @override
  void log(String message) => signalsLogger.fine(message);
}
