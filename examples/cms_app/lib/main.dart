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
const String _defaultApiToken = 'cms_ad_kaKYBjZkB9BBFSjnykvELvzVRKRDHFKrEZsPcy7v240';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const serverUrl = String.fromEnvironment(
      'SERVER_URL',
      defaultValue: _defaultServerUrl,
    );
    const clientId = String.fromEnvironment(
      'CMS_CLIENT_ID',
      defaultValue: _defaultClientId,
    );
    const apiToken = String.fromEnvironment(
      'CMS_API_TOKEN',
      defaultValue: _defaultApiToken,
    );

    return FlutterCmsAuth(
      clientId: clientId,
      apiToken: apiToken,
      serverUrl: serverUrl,
      builder: (context, client) {
        final coordinator = StudioCoordinator(
          documentTypes: [homeScreenConfigDocumentType],
          dataSource: CloudDataSource(client),
          documentTypeDecorations: [
            CmsDocumentTypeDecoration(
              documentType: homeScreenConfigDocumentType,
              icon: Icons.home,
            ),
          ],
        );

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
      },
    );
  }
}
