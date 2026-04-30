import 'desk_condition_context.dart';

/// Base condition class for conditional field visibility.
/// Subclass and override [evaluate] to create custom conditions.
/// All subclasses must be const-constructible.
abstract class DeskCondition {
  const DeskCondition();

  /// Returns true if the field should be visible given the current [ctx].
  bool evaluate(DeskConditionContext ctx);
}

/// Shows the field when [field] equals [value].
class FieldEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldEquals(this.field, this.value);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] == value;
}

/// Shows the field when [field] does not equal [value].
class FieldNotEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldNotEquals(this.field, this.value);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] != value;
}

/// Shows the field when [field] is not null.
class FieldNotNull extends DeskCondition {
  final String field;
  const FieldNotNull(this.field);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] != null;
}

/// Shows the field when [field] is null.
class FieldIsNull extends DeskCondition {
  final String field;
  const FieldIsNull(this.field);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] == null;
}

/// Shows the field when all [conditions] are true.
class AllConditions extends DeskCondition {
  final List<DeskCondition> conditions;
  const AllConditions(this.conditions);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      conditions.every((c) => c.evaluate(ctx));
}

/// Shows the field when any of [conditions] is true.
class AnyCondition extends DeskCondition {
  final List<DeskCondition> conditions;
  const AnyCondition(this.conditions);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      conditions.any((c) => c.evaluate(ctx));
}

abstract class DeskOption {
  const DeskOption({this.hidden = false, this.optional = false, this.condition});

  final bool hidden;

  /// Whether the field is optional (can be null/unset).
  final bool optional;

  /// Condition that determines field visibility based on the editor context.
  /// When null, the field is always visible (unless [hidden] is true).
  final DeskCondition? condition;
}

abstract class DeskField {
  final String name;
  final String title;
  final String? description;
  final DeskOption? option;

  const DeskField({
    required this.name,
    required this.title,
    this.description,
    this.option,
  });
}

/// Base class for field configuration annotations used in code generation.
///
/// DeskFieldConfig classes are used as annotations (e.g., @DeskText())
/// to mark fields in @DeskModel classes. During build time, the code generator
/// processes these annotations to create:
/// 1. Field configuration lists for the CMS studio UI
/// 2. DeskField instances for runtime field representation
///
/// The optional fields (name, title) allow the generator to fill in default
/// values when not explicitly provided in the annotation.
abstract class DeskFieldConfig {
  const DeskFieldConfig({this.name, this.title, this.option, this.description});

  final String? name;
  final String? title;
  final String? description;
  final DeskOption? option;

  /// The Dart types that this field configuration supports.
  /// Used to validate field type compatibility during code generation.
  List<Type> get supportedFieldTypes;
}
