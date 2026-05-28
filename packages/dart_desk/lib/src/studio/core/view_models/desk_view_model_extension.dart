import 'package:signals_flutter/signals_flutter.dart';
import 'package:signals_core/signals_core.dart' as core;

/// Extension to read a container without tracking its internal map.
/// Signals v7's `SignalContainer` uses `putIfAbsent` which always triggers a `force: true` set.
/// If `SignalWidget` or `Watch` tracks the internal map, it causes a cyclic build exception.
T untrackedContainer<T>(T Function() fn) {
  final old = core.onSignalRead;
  core.onSignalRead = null;
  try {
    return core.untracked(fn);
  } finally {
    core.onSignalRead = old;
  }
}
