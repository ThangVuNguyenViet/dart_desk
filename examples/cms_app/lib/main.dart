import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk_be_client/dart_desk_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';
const String _defaultClientId = 'honeygrow';
const String _defaultApiToken =
    'cms_ad_kaKYBjZkB9BBFSjnykvELvzVRKRDHFKrEZsPcy7v240';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    // ShadApp wraps FlutterCmsAuth so the login screen gets theme + directionality.
    // CmsStudioApp provides its own ShadApp.router after authentication.
    return ShadApp(
      theme: cmsStudioTheme,
      home: FlutterCmsAuth(
        clientId: clientId,
        apiToken: apiToken,
        serverUrl: serverUrl,
        title: 'Honeygrow CMS',
        builder: (context, client) => CmsStudioApp(
          dataSource: CloudDataSource(client),
          documentTypes: [homeScreenConfigDocumentType],
          documentTypeDecorations: [
            CmsDocumentTypeDecoration(
              documentType: homeScreenConfigDocumentType,
              icon: Icons.home,
            ),
          ],
          title: 'Honeygrow CMS',
          subtitle: 'Content Management',
          icon: Icons.dashboard,
        ),
      ),
    );
  }
}
