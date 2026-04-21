import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../cloud/cloud_data_source.dart';
import '../cloud/dart_desk_auth.dart';
import '../cloud/dart_desk_auth_view_model.dart';
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
class DartDeskApp extends StatefulWidget {
  final String? serverUrl;
  final DataSource? dataSource;
  final VoidCallback? onSignOut;
  final DartDeskConfig config;
  final String? apiKey;
  final ShadThemeData? theme;

  /// Creates a DartDeskApp with built-in Serverpod IDP authentication.
  ///
  /// Handles client creation, sign-in UI (Google + email/password),
  /// and wraps the studio UI with auth context.
  const DartDeskApp({
    super.key,
    required String this.serverUrl,
    required this.config,
    required String this.apiKey,
    this.theme,
  }) : dataSource = null,
       onSignOut = null;

  /// Creates a DartDeskApp with an external data source and auth.
  ///
  /// Use this when your app handles authentication externally
  /// (Firebase, Clerk, Auth0, etc.) and provides its own [DataSource].
  const DartDeskApp.withDataSource({
    super.key,
    required DataSource this.dataSource,
    required VoidCallback this.onSignOut,
    required this.config,
    this.theme,
  }) : serverUrl = null,
       apiKey = null;

  @override
  State<DartDeskApp> createState() => _DartDeskAppState();
}

class _DartDeskAppState extends State<DartDeskApp> {
  DartDeskAuthViewModel? _authVM;

  @override
  void initState() {
    super.initState();
    if (widget.serverUrl != null) {
      ImageReference.defaultAssetResolver =
          (id) => '${widget.serverUrl}files/$id';
      final vm = DartDeskAuthViewModel.fromConfig(
        serverUrl: widget.serverUrl!,
        apiKey: widget.apiKey!,
      );
      _authVM = vm;
      final getIt = GetIt.I;
      if (getIt.isRegistered<DartDeskAuthViewModel>()) {
        getIt.unregister<DartDeskAuthViewModel>();
      }
      getIt.registerSingleton<DartDeskAuthViewModel>(vm);

      // Warm up Google Sign-In plumbing — fire-and-forget, required before
      // rendering the Google sign-in button.
      vm.sessionManager.initializeGoogleSignIn();
    }
  }

  @override
  void dispose() {
    final vm = _authVM;
    if (vm != null) {
      final getIt = GetIt.I;
      if (getIt.isRegistered<DartDeskAuthViewModel>() &&
          identical(getIt<DartDeskAuthViewModel>(), vm)) {
        getIt.unregister<DartDeskAuthViewModel>();
      }
      vm.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serverUrl != null) {
      return DartDeskAuth(
        title: widget.config.title,
        subtitle: widget.config.subtitle,
        theme: widget.theme,
        builder: (context, client, signOut) {
          final dataSource = CloudDataSource(client);
          return _buildStudio(dataSource, signOut);
        },
      );
    }

    return _buildStudio(widget.dataSource!, widget.onSignOut!);
  }

  Widget _buildStudio(DataSource dataSource, VoidCallback signOut) {
    return CmsStudioApp(
      dataSource: dataSource,
      documentTypes: widget.config.documentTypes,
      documentTypeDecorations: widget.config.documentTypeDecorations,
      title: widget.config.title,
      subtitle: widget.config.subtitle,
      icon: widget.config.icon,
      theme: widget.theme,
      onSignOut: signOut,
    );
  }
}
