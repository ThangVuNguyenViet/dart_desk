import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../cloud/cloud_data_source.dart';
import '../cloud/dart_desk_auth.dart';
import '../data/cms_data_source.dart';
import 'cms_studio_app.dart';
import 'dart_desk_config.dart';

/// Entry point for Dart Desk CMS applications.
///
/// Two constructors for different auth strategies:
///
/// **Built-in Serverpod IDP auth** (Google + email/password):
/// ```dart
/// DartDeskApp(
///   serverUrl: 'http://localhost:8080/',
///   config: DartDeskConfig(
///     documentTypes: [...],
///     documentTypeDecorations: [...],
///   ),
/// )
/// ```
///
/// **External auth** (Firebase, Clerk, Auth0, etc.):
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
  final String? _serverUrl;
  final DataSource? _dataSource;
  final VoidCallback? _onSignOut;
  final DartDeskConfig _config;
  final String? _apiKey;
  final ShadThemeData? _theme;

  /// Creates a DartDeskApp with built-in Serverpod IDP authentication.
  ///
  /// Handles client creation, sign-in UI (Google + email/password),
  /// and wraps the studio UI with auth context.
  const DartDeskApp({
    super.key,
    required String serverUrl,
    required DartDeskConfig config,
    required String apiKey,
    ShadThemeData? theme,
  }) : _serverUrl = serverUrl,
       _dataSource = null,
       _onSignOut = null,
       _config = config,
       _apiKey = apiKey,
       _theme = theme;

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
  }) : _serverUrl = null,
       _dataSource = dataSource,
       _onSignOut = onSignOut,
       _config = config,
       _apiKey = null,
       _theme = theme;

  @override
  Widget build(BuildContext context) {
    if (_serverUrl != null) {
      ImageReference.defaultAssetResolver = (id) => '${_serverUrl}files/$id';
      return DartDeskAuth(
        serverUrl: _serverUrl,
        apiKey: _apiKey!,
        title: _config.title,
        subtitle: _config.subtitle,
        builder: (context, client, signOut) {
          final dataSource = CloudDataSource(client);
          return _buildStudio(dataSource, signOut);
        },
      );
    }

    return _buildStudio(_dataSource!, _onSignOut!);
  }

  Widget _buildStudio(DataSource dataSource, VoidCallback signOut) {
    return CmsStudioApp(
      dataSource: dataSource,
      documentTypes: _config.documentTypes,
      documentTypeDecorations: _config.documentTypeDecorations,
      title: _config.title,
      subtitle: _config.subtitle,
      icon: _config.icon,
      theme: _theme,
      onSignOut: signOut,
    );
  }
}
