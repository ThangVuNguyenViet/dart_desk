import 'dart:async';

import 'package:signals/signals_flutter.dart';

/// A [FutureSignal] subclass that fixes the `.reload()` bug where the internal
/// completer is not reset, causing `await reload()` to resolve immediately with
/// stale data on subsequent calls.
///
/// Use [awaitableFutureSignal] as a drop-in replacement for [futureSignal].
/// Use [awaitableReload] instead of [reload].
class AwaitableFutureSignal<T> extends FutureSignal<T> {
  AwaitableFutureSignal(
    super.fn, {
    super.initialValue,
    super.debugLabel,
    super.dependencies,
    super.lazy,
    super.autoDispose,
  });

  /// Re-executes the factory and waits for the new value to resolve.
  ///
  /// Unlike [reload], this correctly resets the internal completer so the
  /// returned Future only resolves after the new data (or error) arrives.
  Future<void> awaitableReload() async {
    // ignore: invalid_use_of_internal_member
    completer = Completer<bool>();
    await reload();
  }

  @Deprecated(
    'Use awaitableReload() instead. '
    '.reload() has a bug where it does not reset the internal completer, '
    'causing await reload() to resolve immediately with stale data.',
  )
  @override
  Future<void> reload() => super.reload();
}

/// Drop-in replacement for [futureSignal] that returns an [AwaitableFutureSignal].
AwaitableFutureSignal<T> awaitableFutureSignal<T>(
  Future<T> Function() fn, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  bool lazy = true,
  bool autoDispose = false,
}) {
  return AwaitableFutureSignal<T>(
    fn,
    initialValue: initialValue,
    debugLabel: debugLabel,
    dependencies: dependencies,
    lazy: lazy,
    autoDispose: autoDispose,
  );
}
