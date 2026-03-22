/// Dart Desk Studio - Complete CMS interface components
///
/// This module provides the full CMS studio UI including:
/// - Document management screens
/// - Form components with reactive state
/// - Navigation and layout components
/// - Theme system integration
/// ## Usage
/// ```dart
/// import 'package:dart_desk/studio/studio.dart';
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ShadApp(
///       home: CmsStudioShell(
///         documentTypes: [
///           // Your CMS document types
///         ],
///       ),
///     );
///   }
/// }
/// ```
library;

// UI Components
export 'src/studio/components/common/cms_document_type_decoration.dart';
export 'src/studio/components/common/cms_document_type_item.dart';
export 'src/studio/components/common/default_cms_header.dart';
export 'src/studio/components/forms/cms_form.dart';
export 'src/studio/components/navigation/cms_document_type_sidebar.dart';
export 'src/studio/components/version/cms_version_history.dart';
// App entry point
export 'src/studio/cms_studio_app.dart';
export 'src/studio/dart_desk.dart';
export 'src/studio/dart_desk_app.dart';
// Cloud (built-in Serverpod IDP auth)
export 'src/cloud/dart_desk_app.dart';
export 'src/cloud/dart_desk_auth.dart';
export 'src/studio/dart_desk_config.dart';
// Core studio functionality
export 'src/studio/core/marionette_config.dart';
export 'src/studio/core/registry.dart';
export 'src/studio/core/view_models/cms_view_model.dart';
export 'src/studio/screens/cms_studio.dart';
// Main screens
export 'src/studio/screens/document_editor.dart';
export 'src/studio/screens/document_list.dart';
// Routes
export 'src/studio/routes/studio_coordinator.dart';
export 'src/studio/routes/studio_layout.dart';
export 'src/studio/routes/studio_route.dart';
export 'src/studio/routes/document_type_route.dart';
export 'src/studio/routes/document_route.dart';
export 'src/studio/routes/version_route.dart';
export 'src/studio/routes/media_route.dart';
// Theme
export 'src/studio/theme/theme.dart';
export 'src/studio/theme/spacing.dart';
// Common components
export 'src/studio/components/common/cms_breadcrumbs.dart';
export 'src/studio/components/common/cms_status_pill.dart';
export 'src/studio/components/common/cms_theme_toggle.dart';
export 'src/studio/components/common/cms_button.dart';
// Media system
export 'src/media/browser/media_browser.dart';
export 'src/media/image_url.dart';
export 'src/media/image_transform_params.dart';
export 'src/inputs/hotspot/image_hotspot_editor.dart';
