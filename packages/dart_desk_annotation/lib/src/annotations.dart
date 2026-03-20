/// Annotation for marking classes as CMS configurations.
///
/// This annotation triggers code generation for CMS data models,
/// field configurations, and UI components.
class CmsConfig {
  /// The human-readable title for this CMS configuration.
  final String title;

  /// A description of this CMS configuration.
  final String description;

  /// Optional unique identifier for this configuration.
  final String? id;

  const CmsConfig({
    required this.title,
    required this.description,
    this.id,
  });
}
