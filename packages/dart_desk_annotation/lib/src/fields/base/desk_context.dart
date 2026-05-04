import '../../data/desk_document.dart';
import 'desk_listenable.dart';

/// Information passed to builders, conditions, and other studio surfaces so
/// they can read document metadata, look up other documents, and reach
/// runtime services without coupling to a specific host implementation
/// (GetIt, Riverpod, etc.).
///
/// This file is Flutter-free so it can be reached from
/// `dart_desk_annotation_generator.dart` (and therefore the build_runner
/// build script's AOT kernel) without dragging in `dart:ui`. The
/// [DeskContextScope] InheritedWidget and `DeskContext.of(BuildContext)`
/// helpers live in `desk_context_scope.dart`.
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
  DeskListenable<List<DeskDocument>> documents(String documentType);

  /// Look up a runtime service by type — viewmodels, repositories, or
  /// anything else registered with the host's locator.
  ///
  /// Throws [StateError] (or the host's equivalent) if [T] is not
  /// registered.
  T read<T extends Object>();
}
