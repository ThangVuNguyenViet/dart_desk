import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../../data/desk_document.dart';

/// Information passed to builders, conditions, and other studio surfaces so
/// they can read document metadata, look up other documents, and reach
/// runtime services without coupling to a specific host implementation
/// (GetIt, Riverpod, etc.).
///
/// Implementations live in the host package (e.g. `dart_desk`).
abstract class DeskContext {
  const DeskContext();

  /// The document currently being edited.
  ///
  /// Includes metadata (`id`, `documentType`, `title`, `isDefault`, …) and
  /// the current content map under [DeskDocument.activeVersionData].
  ///
  /// Null when no document is selected (e.g. in tests, or before any
  /// document has been opened).
  DeskDocument? get document;

  /// A reactive view of all documents of [documentType]. Loading and error
  /// states are flattened to an empty list — consumers that need to
  /// distinguish them should reach into the host's view models directly.
  ValueListenable<List<DeskDocument>> documents(String documentType);

  /// Look up a runtime service by type — viewmodels, repositories, or
  /// anything else registered with the host's locator.
  ///
  /// Throws [StateError] (or the host's equivalent) if [T] is not
  /// registered.
  T read<T extends Object>();

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
}

/// Provides a [DeskContext] to descendants. Studios install one of these
/// near the root of the studio shell so that [DeskForm] (for conditions),
/// document preview builders, and any custom widgets can call
/// [DeskContext.of].
class DeskContextScope extends InheritedWidget {
  const DeskContextScope({
    super.key,
    required this.context,
    required super.child,
  });

  final DeskContext context;

  @override
  bool updateShouldNotify(DeskContextScope oldWidget) =>
      context != oldWidget.context;
}

/// Backwards-compatible alias for the old name. Prefer [DeskContext].
@Deprecated('Renamed to DeskContext')
typedef DeskConditionContext = DeskContext;
