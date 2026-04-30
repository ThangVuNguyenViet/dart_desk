import '../../data/desk_document.dart';

/// Information passed to [DeskCondition.evaluate] so conditions can read
/// document metadata and runtime services without coupling to a specific
/// host implementation (GetIt, Riverpod, etc.).
///
/// Implementations live in the host package (e.g. `dart_desk`).
abstract class DeskConditionContext {
  const DeskConditionContext();

  /// The document currently being edited.
  ///
  /// Includes metadata (`id`, `documentType`, `title`, `isDefault`, …) and
  /// the current content map under [DeskDocument.activeVersionData].
  ///
  /// Null when no document is selected (e.g. in tests, or before any
  /// document has been opened).
  DeskDocument? get document;

  /// Look up a runtime service by type — viewmodels, repositories, or
  /// anything else registered with the host's locator.
  ///
  /// Throws [StateError] (or the host's equivalent) if [T] is not
  /// registered.
  T read<T extends Object>();
}
