import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms/studio.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';
const String _defaultClientId = 'honeygrow';
const String _defaultApiToken =
    'cms_ad_kaKYBjZkB9BBFSjnykvELvzVRKRDHFKrEZsPcy7v240';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );
  static const clientId = String.fromEnvironment(
    'CMS_CLIENT_ID',
    defaultValue: _defaultClientId,
  );
  static const apiToken = String.fromEnvironment(
    'CMS_API_TOKEN',
    defaultValue: _defaultApiToken,
  );

  @override
  Widget build(BuildContext context) {
    // FlutterCmsAuth handles its own client creation and login UI.
    // Once authenticated, it calls builder with the client.
    // We wrap it in ShadApp so the login screen gets dark theme + directionality.
    return ShadApp(
      theme: cmsStudioTheme,
      home: FlutterCmsAuth(
        clientId: clientId,
        apiToken: apiToken,
        serverUrl: serverUrl,
        title: 'Honeygrow CMS',
        builder: (context, client) => _AuthenticatedApp(client: client),
      ),
    );
  }
}

/// The authenticated portion of the app — creates the coordinator and router.
class _AuthenticatedApp extends StatefulWidget {
  final Client client;
  const _AuthenticatedApp({required this.client});

  @override
  State<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<_AuthenticatedApp> {
  late final StudioCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = StudioCoordinator(
      documentTypes: [homeScreenConfigDocumentType],
      dataSource: CloudDataSource(widget.client),
      documentTypeDecorations: [
        CmsDocumentTypeDecoration(
          documentType: homeScreenConfigDocumentType,
          icon: Icons.home,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCmsHeaderConfig(
      title: 'Honeygrow CMS',
      subtitle: 'Content Management',
      icon: Icons.dashboard,
      child: ShadApp.router(
        theme: cmsStudioTheme,
        routeInformationParser: coordinator.routeInformationParser,
        routerDelegate: coordinator.routerDelegate,
      ),
    );
  }
}
