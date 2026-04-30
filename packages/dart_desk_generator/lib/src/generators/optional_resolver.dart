import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'utils.dart';

/// Resolves the effective `optional` flag for a generated field.
///
/// Rules:
/// - Nullable Dart field with no explicit annotation `optional` → true.
/// - Nullable Dart field with explicit `optional: false` → false (override).
/// - Nullable Dart field with explicit `optional: true` → true.
/// - Non-nullable Dart field with no/explicit `optional: false` → false.
/// - Non-nullable Dart field with `optional: true` → InvalidGenerationSourceError.
///
/// [configOptional] is the resolved bool from the annotation's `optional`
/// field (via `ConstantReader` / `DartObject`); null means the annotation
/// did not set it. [optionalSource] is the literal source ('true' / 'false')
/// from `_namedArgumentSource`, used to detect the `optional: true` shorthand
/// passed at the annotation level (e.g. `@DeskString(optional: true)`).
///
/// Both parameters derive from the same annotation argument and must not
/// disagree; callers populate whichever path is available.
bool resolveOptional({
  required FieldElement field,
  required bool? configOptional,
  required String? optionalSource,
}) {
  final isNullable = field.type.isNullable;
  final explicitTrue =
      optionalSource == 'true' || configOptional == true;
  final explicitFalse =
      optionalSource == 'false' || configOptional == false;

  if (!isNullable && explicitTrue) {
    final fieldName = field.name ?? '<unnamed>';
    final ownerName = field.enclosingElement.name ?? '<unknown>';
    throw InvalidGenerationSourceError(
      'Field `$ownerName.$fieldName` is non-nullable but its annotation '
      'sets optional: true. Optional fields can be null at runtime; either '
      'change the field type to nullable or remove `optional: true`.',
      element: field,
    );
  }
  if (explicitFalse) return false;
  if (explicitTrue) return true;
  return isNullable;
}
