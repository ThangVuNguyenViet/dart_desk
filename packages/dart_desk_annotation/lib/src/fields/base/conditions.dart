import 'desk_context.dart';
import 'field.dart';

/// Shows the field when [field] equals [value].
class FieldEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldEquals(this.field, this.value);

  @override
  bool evaluate(DeskContext ctx) =>
      ctx.document?.activeVersionData?[field] == value;
}

/// Shows the field when [field] does not equal [value].
class FieldNotEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldNotEquals(this.field, this.value);

  @override
  bool evaluate(DeskContext ctx) =>
      ctx.document?.activeVersionData?[field] != value;
}

/// Shows the field when [field] is not null.
class FieldNotNull extends DeskCondition {
  final String field;
  const FieldNotNull(this.field);

  @override
  bool evaluate(DeskContext ctx) =>
      ctx.document?.activeVersionData?[field] != null;
}

/// Shows the field when [field] is null.
class FieldIsNull extends DeskCondition {
  final String field;
  const FieldIsNull(this.field);

  @override
  bool evaluate(DeskContext ctx) =>
      ctx.document?.activeVersionData?[field] == null;
}

/// Shows the field when all [conditions] are true.
class AllConditions extends DeskCondition {
  final List<DeskCondition> conditions;
  const AllConditions(this.conditions);

  @override
  bool evaluate(DeskContext ctx) => conditions.every((c) => c.evaluate(ctx));
}

/// Shows the field when any of [conditions] is true.
class AnyCondition extends DeskCondition {
  final List<DeskCondition> conditions;
  const AnyCondition(this.conditions);

  @override
  bool evaluate(DeskContext ctx) => conditions.any((c) => c.evaluate(ctx));
}
