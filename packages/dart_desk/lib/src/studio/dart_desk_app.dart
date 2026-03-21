import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../data/cms_data_source.dart';
import 'cms_studio_app.dart';
import 'dart_desk.dart';
import 'dart_desk_config.dart';

/// Unified entry point for Dart Desk CMS applications with external auth.
///
/// Use this when your app handles authentication externally
/// (Firebase, Clerk, Auth0, etc.) and provides its own [DataSource].
///
/// For built-in Serverpod IDP authentication, use `DartDeskApp` from the
/// `dart_desk_be_client` package instead.
///
/// ```dart
/// DartDeskApp.withDataSource(
///   dataSource: myDataSource,
///   onSignOut: () => myAuth.signOut(),
///   config: DartDeskConfig(
///     documentTypes: [...],
///     documentTypeDecorations: [...],
///   ),
/// )
/// ```
class DartDeskApp extends StatelessWidget {
  final DataSource _dataSource;
  final VoidCallback _onSignOut;
  final DartDeskConfig _config;
  final ShadThemeData? _theme;

  /// Creates a DartDeskApp with an external data source and auth.
  ///
  /// Use this when your app handles authentication externally
  /// (Firebase, Clerk, Auth0, etc.) and provides its own [DataSource].
  const DartDeskApp.withDataSource({
    super.key,
    required DataSource dataSource,
    required VoidCallback onSignOut,
    required DartDeskConfig config,
    ShadThemeData? theme,
  })  : _dataSource = dataSource,
        _onSignOut = onSignOut,
        _config = config,
        _theme = theme;

  @override
  Widget build(BuildContext context) {
    return DartDesk(
      dataSource: _dataSource,
      signOut: _onSignOut,
      config: _config,
      child: CmsStudioApp(
        dataSource: _dataSource,
        documentTypes: _config.documentTypes,
        documentTypeDecorations: _config.documentTypeDecorations,
        title: _config.title,
        subtitle: _config.subtitle,
        icon: _config.icon,
        theme: _theme,
        onSignOut: _onSignOut,
      ),
    );
  }
}
