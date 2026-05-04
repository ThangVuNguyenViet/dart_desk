import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/foundation.dart';

/// Adapts a [DeskListenable<T>] to Flutter's [ValueListenable<T>] so it can
/// be passed to [ValueListenableBuilder], `signals_flutter`'s `.toSignal()`,
/// or any other Flutter API that expects a `ValueListenable`.
///
/// `DeskListenable<T>` exists because the abstract [DeskContext] (and the
/// generator-safe export path) must stay Flutter-free; this extension lives
/// in `dart_desk` where importing `flutter/foundation` is fine.
extension DeskListenableToValueListenable<T> on DeskListenable<T> {
  ValueListenable<T> asValueListenable() => _DeskListenableAsValueListenable(
    this,
  );
}

class _DeskListenableAsValueListenable<T> implements ValueListenable<T> {
  _DeskListenableAsValueListenable(this._inner);
  final DeskListenable<T> _inner;

  @override
  T get value => _inner.value;

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _inner.removeListener(listener);
}
