import 'package:dart_desk/dart_desk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:signals/signals.dart';

void main() {
  group('DartDeskDebug', () {
    setUp(() {
      DartDeskDebug.debugShowClientLog = false;
      DartDeskDebug.debugShowSignalLogs = false;
    });

    test('logger initializers do not throw on first access', () {
      // Regression: top-level Logger initializer used to call
      // `..level = Level.OFF` before `hierarchicalLoggingEnabled = true`,
      // which threw on first access in any consumer.
      expect(clientLogger.fullName, 'dart_desk.client');
      expect(signalsLogger.fullName, 'dart_desk.signals');
    });

    test('clientLogger emits SEVERE failures even when flag is off', () {
      final captured = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(captured.add);
      addTearDown(sub.cancel);

      expect(DartDeskDebug.debugShowClientLog, isFalse);
      clientLogger.severe('boom', StateError('x'));
      clientLogger.info('ignored');

      expect(captured.where((r) => r.level == Level.SEVERE), hasLength(1));
      expect(captured.where((r) => r.level == Level.INFO), isEmpty);
    });

    test('debugShowClientLog raises level so INFO records flow', () {
      final captured = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(captured.add);
      addTearDown(sub.cancel);

      DartDeskDebug.debugShowClientLog = true;
      clientLogger.info('hello');
      expect(captured.where((r) => r.level == Level.INFO), hasLength(1));

      captured.clear();
      DartDeskDebug.debugShowClientLog = false;
      clientLogger.info('silenced');
      clientLogger.severe('still emitted');
      expect(captured.where((r) => r.level == Level.INFO), isEmpty);
      expect(captured.where((r) => r.level == Level.SEVERE), hasLength(1));
    });

    test('debugShowSignalLogs installs and removes observer', () {
      final original = SignalsObserver.instance;
      addTearDown(() => SignalsObserver.instance = original);

      DartDeskDebug.debugShowSignalLogs = true;
      expect(SignalsObserver.instance, isNot(equals(original)));

      DartDeskDebug.debugShowSignalLogs = false;
      expect(SignalsObserver.instance, equals(original));
    });
  });
}
