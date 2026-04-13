/// Base condition class for conditional field visibility.
/// Subclass and override [evaluate] to create custom conditions.
/// All subclasses must be const-constructible.
abstract class CmsCondition {
  const CmsCondition();

  /// Returns true if the field should be visible given the current [data].
  bool evaluate(Map<String, dynamic> data);
}

/// Shows the field when [field] equals [value].
class FieldEquals extends CmsCondition {
  final String field;
  final Object? value;
  const FieldEquals(this.field, this.value);

  @override
  bool evaluate(Map<String, dynamic> data) => data[field] == value;
}

/// Shows the field when [field] does not equal [value].
class FieldNotEquals extends CmsCondition {
  final String field;
  final Object? value;
  const FieldNotEquals(this.field, this.value);

  @override
  bool evaluate(Map<String, dynamic> data) => data[field] != value;
}

/// Shows the field when [field] is not null.
class FieldNotNull extends CmsCondition {
  final String field;
  const FieldNotNull(this.field);

  @override
  bool evaluate(Map<String, dynamic> data) => data[field] != null;
}

/// Shows the field when [field] is null.
class FieldIsNull extends CmsCondition {
  final String field;
  const FieldIsNull(this.field);

  @override
  bool evaluate(Map<String, dynamic> data) => data[field] == null;
}

/// Shows the field when all [conditions] are true.
class AllConditions extends CmsCondition {
  final List<CmsCondition> conditions;
  const AllConditions(this.conditions);

  @override
  bool evaluate(Map<String, dynamic> data) =>
      conditions.every((c) => c.evaluate(data));
}

/// Shows the field when any of [conditions] is true.
class AnyCondition extends CmsCondition {
  final List<CmsCondition> conditions;
  const AnyCondition(this.conditions);

  @override
  bool evaluate(Map<String, dynamic> data) =>
      conditions.any((c) => c.evaluate(data));
}

abstract class CmsOption {
  const CmsOption({this.hidden = false, this.optional = false, this.condition});

  final bool hidden;

  /// Whether the field is optional (can be null/unset).
  final bool optional;

  /// Condition that determines field visibility based on document data.
  /// When null, the field is always visible (unless [hidden] is true).
  final CmsCondition? condition;
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
