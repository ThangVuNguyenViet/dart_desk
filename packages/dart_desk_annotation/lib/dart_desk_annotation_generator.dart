/// Generator-safe exports for dart_desk_annotation.
///
/// This library exports only the annotation classes and field configurations
/// that have no Flutter dependency, making it safe to import in build_runner
/// code generators (which run in a Dart VM context without Flutter).
library dart_desk_annotation_generator;

// Core annotations (no Flutter dependency)
export 'src/annotations.dart';
export 'src/serializable.dart';
// Base field abstractions
export 'src/fields/base/field.dart';
export 'src/fields/base/desk_context.dart';
export 'src/fields/base/desk_listenable.dart';
// Complex field configurations (array_field and dropdown_field omitted — they import Flutter)
export 'src/fields/complex/block_field.dart';
export 'src/fields/complex/field_layout.dart';
export 'src/fields/complex/geopoint_field.dart';
export 'src/fields/complex/object_field.dart';
// Media field configurations
export 'src/fields/media/file_field.dart';
export 'src/fields/media/image_field.dart';
// Primitive field configurations
export 'src/fields/primitive/boolean_field.dart';
export 'src/fields/primitive/checkbox_field.dart';
export 'src/fields/primitive/date_field.dart';
export 'src/fields/primitive/datetime_field.dart';
export 'src/fields/primitive/string_field.dart';
// number_field.dart and text_field.dart omitted — they transitively import validators.dart (Flutter)
export 'src/fields/primitive/url_field.dart';
