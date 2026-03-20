abstract class CmsOption {
  // Abstract class for options, can be extended later for specific option types
  const CmsOption({this.hidden = false});

  final bool hidden;
}

abstract class CmsField {
  final String name;
  final String title;
  final String? description;
  final CmsOption? option;

  const CmsField({
    required this.name,
    required this.title,
    this.description,
    this.option,
  });
}

/// Base class for field configuration annotations used in code generation.
///
/// CmsFieldConfig classes are used as annotations (e.g., @CmsTextFieldConfig())
/// to mark fields in @CmsConfig classes. During build time, the code generator
/// processes these annotations to create:
/// 1. Field configuration lists for the CMS studio UI
/// 2. CmsField instances for runtime field representation
///
/// The optional fields (name, title) allow the generator to fill in default
/// values when not explicitly provided in the annotation.
abstract class CmsFieldConfig {
  const CmsFieldConfig({this.name, this.title, this.option, this.description});

  final String? name;
  final String? title;
  final String? description;
  final CmsOption? option;

  /// The Dart types that this field configuration supports.
  /// Used to validate field type compatibility during code generation.
  List<Type> get supportedFieldTypes;
}
