/// Flutter-free mirror of `package:flutter/foundation.dart`'s
/// `ValueListenable<T>`. Lives in the annotation package so types reachable
/// from `dart_desk_annotation_generator.dart` (and therefore the
/// build_runner build script's AOT kernel) don't drag in `dart:ui`.
///
/// The host package adapts a real `ValueListenable<T>` (e.g. a signals
/// `Computed`) into this interface for runtime consumers.
abstract class DeskListenable<T> {
  T get value;
  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}
