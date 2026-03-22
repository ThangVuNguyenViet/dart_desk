import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../studio/cms_studio_app.dart';
import '../studio/dart_desk.dart';
import '../studio/dart_desk_config.dart';
import 'dart_desk_auth.dart';
import 'cloud_data_source.dart';

/// Dart Desk CMS app with built-in Serverpod IDP authentication.
///
/// Handles client creation, sign-in UI (Google + email/password),
/// and wraps the studio UI with [DartDesk] InheritedWidget context.
///
/// For external auth (Firebase, Clerk, Auth0), use
/// `DartDeskApp.withDataSource()` from the `dart_desk` package instead.
///
/// ```dart
/// DartDeskBuiltInApp(
///   serverUrl: 'http://localhost:8080/',
///   config: DartDeskConfig(
///     documentTypes: [...],
///     documentTypeDecorations: [...],
///   ),
/// )
/// ```
class DartDeskBuiltInApp extends StatelessWidget {
  final String serverUrl;
  final DartDeskConfig config;
  final ShadThemeData? theme;

  const DartDeskBuiltInApp({
    super.key,
    required this.serverUrl,
    required this.config,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DartDeskAuth(
      serverUrl: serverUrl,
      title: config.title,
      subtitle: config.subtitle,
      builder: (context, client, signOut) {
        final dataSource = CloudDataSource(client);
        return DartDesk(
          dataSource: dataSource,
          signOut: signOut,
          config: config,
          child: CmsStudioApp(
            dataSource: dataSource,
            documentTypes: config.documentTypes,
            documentTypeDecorations: config.documentTypeDecorations,
            title: config.title,
            subtitle: config.subtitle,
            icon: config.icon,
            theme: theme,
            onSignOut: signOut,
          ),
        );
      },
    );
  }
}
