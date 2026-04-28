/// Dart Desk - Studio and runtime components for CMS applications
///
/// This package provides the CMS studio interface with:
/// - Complete CMS studio UI with document management
/// - Input widgets for all field types with reactive state
/// - Form validation and error handling
/// - Professional text editing with SuperEditor integration
///
/// ## Usage
///
/// ```dart
/// import 'package:dart_desk/dart_desk.dart';
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ShadApp(
///       home: DeskStudioShell(
///         documentTypes: [...],
///       ),
///     );
///   }
/// }
/// ```
///
/// For annotations, import from dart_desk_annotation:
/// ```dart
/// import 'package:dart_desk_annotation/dart_desk_annotation.dart';
/// ```
library;

// Re-export annotations for convenience
export 'package:dart_desk_annotation/dart_desk_annotation.dart';

// ============================================================================
// DATA LAYER
// ============================================================================
export 'src/data/data.dart';
export 'src/data/models/public_desk_document.dart';
// ============================================================================
// MEDIA
// ============================================================================
export 'src/media/image_url.dart';
export 'src/media/image_url_mapper.dart';
// ============================================================================
// INPUT WIDGETS
// ============================================================================
export 'src/inputs/array_input.dart';
export 'src/inputs/block_input.dart' hide preview;
export 'src/inputs/boolean_input.dart' hide preview;
export 'src/inputs/checkbox_input.dart' hide preview;
export 'src/inputs/color_input.dart';
export 'src/inputs/date_input.dart' hide preview;
export 'src/inputs/datetime_input.dart' hide preview;
export 'src/inputs/dropdown_input.dart' hide preview;
export 'src/inputs/multi_dropdown_input.dart';
export 'src/inputs/file_input.dart' hide preview;
export 'src/inputs/geopoint_input.dart' hide preview;
export 'src/inputs/image_input.dart';
export 'src/inputs/number_input.dart' hide preview;
export 'src/inputs/object_input.dart' hide preview;
export 'src/inputs/string_input.dart' hide preview;
export 'src/inputs/text_input.dart' hide preview;
export 'src/inputs/url_input.dart' hide preview;
// ============================================================================
// STUDIO COMPONENTS
// ============================================================================
export 'src/studio/desk_studio_app.dart';
