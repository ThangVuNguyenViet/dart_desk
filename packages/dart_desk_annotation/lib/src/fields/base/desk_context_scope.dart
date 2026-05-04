import 'package:flutter/widgets.dart';

import 'desk_context.dart';

/// Provides a [DeskContext] to descendants. Studios install one of these
/// near the root of the studio shell so that [DeskForm] (for conditions),
/// document preview builders, and any custom widgets can call
/// [DeskContextScope.of].
///
/// Lives outside `desk_context.dart` so the abstract [DeskContext] stays
/// Flutter-free and reachable from the generator-safe barrel.
class DeskContextScope extends InheritedWidget {
  const DeskContextScope({
    super.key,
    required this.context,
    required super.child,
  });

  final DeskContext context;

  /// Reads the nearest [DeskContext] from the widget tree.
  ///
  /// Throws if no [DeskContextScope] is found above [context].
  static DeskContext of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DeskContextScope>();
    assert(scope != null, 'No DeskContextScope found in the widget tree.');
    return scope!.context;
  }

  /// Reads the nearest [DeskContext], returning null if none is installed.
  static DeskContext? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DeskContextScope>()
        ?.context;
  }

  @override
  bool updateShouldNotify(DeskContextScope oldWidget) =>
      context != oldWidget.context;
}

/// Backwards-compatible alias for the old name. Prefer [DeskContext].
@Deprecated('Renamed to DeskContext')
typedef DeskConditionContext = DeskContext;
