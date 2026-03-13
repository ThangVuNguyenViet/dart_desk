import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms/flutter_cms.dart';
import 'package:flutter_cms/studio.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';
const String _defaultClientId = 'default';
const String _defaultApiToken = 'dev-token';

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

    return ShadApp(
      theme: _buildCmsTheme(),
      home: Scaffold(
        body: FlutterCmsAuth(
          clientId: clientId,
          apiToken: apiToken,
          serverUrl: serverUrl,
          builder: (context, client) => CmsStudioApp(
            dataSource: CloudDataSource(client),
            header: const DefaultCmsHeader(
              name: 'example-cms',
              title: 'Example CMS',
              subtitle: 'Content Management',
              icon: Icons.dashboard,
            ),
            sidebar: CmsDocumentTypeSidebar(
              documentTypeDecorations: [
                CmsDocumentTypeDecoration(
                  documentType: homeScreenConfigDocumentType,
                  icon: Icons.home,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static ShadThemeData _buildCmsTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(),
      textTheme: ShadTextTheme(
        family: 'Inter',
      ),
      radius: BorderRadius.circular(8.0),
    );
  }
}
