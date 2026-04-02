/// Annotations for Dart Desk code generation.
///
/// This library provides annotations that can be used to generate
/// CMS configuration and data models.
library dart_desk_annotation;

// Core annotations and data types
export 'src/annotations.dart';
export 'src/cms_data.dart';
export 'src/config.dart';
// Base field abstractions
export 'src/fields/base/field.dart';
// Complex field configurations
export 'src/fields/complex/array_field.dart';
export 'src/fields/complex/block_field.dart';
export 'src/fields/complex/dropdown_field.dart';
export 'src/fields/complex/geopoint_field.dart';
export 'src/fields/complex/field_layout.dart';
export 'src/fields/complex/object_field.dart';
// Models
export 'src/models/image_ref.dart';
export 'src/models/image_types.dart';
// Media field configurations
export 'src/fields/media/color_field.dart';
export 'src/fields/media/file_field.dart';
export 'src/fields/media/image_field.dart';
// Primitive field configurations
export 'src/fields/primitive/boolean_field.dart';
export 'src/fields/primitive/checkbox_field.dart';
export 'src/fields/primitive/date_field.dart';
export 'src/fields/primitive/datetime_field.dart';
export 'src/fields/primitive/number_field.dart';
export 'src/fields/primitive/string_field.dart';
export 'src/fields/primitive/text_field.dart';
export 'src/fields/primitive/url_field.dart';
export 'src/serializable.dart';
// Validators
export 'src/validators/validators.dart';
