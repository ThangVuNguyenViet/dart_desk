/// Annotation for marking classes as CMS configurations.
///
/// This annotation triggers code generation for CMS data models,
/// field configurations, and UI components.
class DeskModel {
  /// The human-readable title for this CMS configuration.
  final String title;

  /// A description of this CMS configuration.
  final String description;

  /// Optional unique identifier for this configuration.
  final String? id;

  const DeskModel({required this.title, required this.description, this.id});
}
