import 'package:signals/signals.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class MutationState<T> {
  const MutationState({this.lastValue});

  /// The most recent successful result. Preserved across [MutationPending] and
  /// [MutationError] transitions so the last known value remains accessible
  /// while a new mutation is in flight or has failed.
  ///
  /// Only cleared by [MutationSignal.reset].
  final T? lastValue;

  bool get isIdle => this is MutationIdle<T>;
  bool get isLoading => this is MutationPending<T>;
  bool get hasError => this is MutationError<T>;
  bool get isSuccess => this is MutationSuccess<T>;

  Object? get error => switch (this) {
    MutationError(:final error) => error,
    _ => null,
  };

  /// The current value: the latest success result if in [MutationSuccess],
  /// otherwise [lastValue] (the previous success, if any).
  T? get value => lastValue;
}

final class MutationIdle<T> extends MutationState<T> {
  const MutationIdle({super.lastValue});
}

final class MutationPending<T> extends MutationState<T> {
  const MutationPending({super.lastValue});
}

final class MutationSuccess<T> extends MutationState<T> {
  @override
  final T value;
  MutationSuccess(this.value) : super(lastValue: value);
}

final class MutationError<T> extends MutationState<T> {
  @override
  final Object error;
  final StackTrace stackTrace;
  const MutationError(this.error, this.stackTrace, {super.lastValue});
}

// ---------------------------------------------------------------------------
// Signal
// ---------------------------------------------------------------------------

/// A signal for imperative async mutations (create, update, delete).
///
/// Unlike [futureSignal], this never auto-executes. It starts as [MutationIdle]
/// and transitions to [MutationPending] → [MutationSuccess] or [MutationError]
/// only when [run] is called explicitly.
///
/// Parameters are passed at call time — no need for separate input signals.
///
/// ```dart
/// // VM
/// late final createItem = mutationSignal<Item, String>((name) async {
///   return await api.createItem(name);
/// }, debugLabel: 'createItem');
///
/// // Screen
/// final state = vm.createItem.watch(context);
/// if (state.isLoading) return Spinner();\n/// if (state.hasError) return ErrorText(state.error.toString());
///
/// // Button
/// onPressed: () async {
///   final item = await vm.createItem.run(nameController.text);
///   if (item != null) navigate(item);
/// }
/// ```
class MutationSignal<T, A> extends Signal<MutationState<T>> {
  final Future<T> Function(A) _fn;

  MutationSignal(this._fn, {String? debugLabel})
    : super(MutationIdle<T>(), debugLabel: debugLabel);

  /// Executes the mutation with [args].
  ///
  /// Returns the result on success, or `null` on error.
  /// The signal state reflects the outcome and notifies all watchers.
  Future<T?> run(A args) async {
    final prev = value.lastValue;
    value = MutationPending<T>(lastValue: prev);
    try {
      final result = await _fn(args);
      value = MutationSuccess<T>(result);
      return result;
    } catch (e, st) {
      value = MutationError<T>(e, st, lastValue: prev);
      return null;
    }
  }

  /// Resets the signal back to [MutationIdle].
  void reset() => value = MutationIdle<T>();
}

/// Creates a [MutationSignal] with a single typed argument [A].
///
/// Use Dart records for multiple parameters:
/// ```dart
/// final update = mutationSignal<void, ({String name, int age})>(\n///   (args) async => api.update(args.name, args.age),\n/// );
/// await update.run((name: 'Alice', age: 30));\n/// ```
MutationSignal<T, A> mutationSignal<T, A>(
  Future<T> Function(A) fn, {
  String? debugLabel,
}) => MutationSignal<T, A>(fn, debugLabel: debugLabel);
