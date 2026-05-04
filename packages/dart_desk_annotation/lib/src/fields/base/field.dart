import 'desk_context.dart';

/// Base condition class for conditional field visibility.
/// Subclass and override [evaluate] to create custom conditions.
/// All subclasses must be const-constructible.
abstract class DeskCondition {
  const DeskCondition();

  /// Returns true if the field should be visible given [ctx].
  bool evaluate(DeskContext ctx);
}

abstract class DeskOption {
  const DeskOption({this.optional = false, this.visibleWhen});

  /// Whether the field is optional (can be null/unset).
  final bool optional;

  /// Condition that determines field visibility based on the editor context.
  /// When null, the field is always visible. When set, the field is rendered
  /// only if [visibleWhen.evaluate(ctx)] returns true.
  final DeskCondition? visibleWhen;
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
