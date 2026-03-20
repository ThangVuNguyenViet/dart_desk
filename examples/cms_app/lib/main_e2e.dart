import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_desk/studio.dart';
import 'package:dart_desk_be_client/dart_desk_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// E2E entry point — uses real CloudDataSource. Auth is handled via marionette.
///
/// Launch with Dart MCP `launch_app` tool, or manually:
/// ```bash
/// flutter run -d chrome -t lib/main_e2e.dart
/// ```
/// Defaults: server=localhost:8080, client=e2e-client-a. Override via --dart-define if needed.
void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
  }
  runApp(const E2eApp());
}

class E2eApp extends StatelessWidget {
  const E2eApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:8080/',
  );
  static const clientId = String.fromEnvironment(
    'CMS_CLIENT_ID',
    defaultValue: 'e2e-client-a',
  );
  static const apiToken = String.fromEnvironment(
    'CMS_API_TOKEN',
    defaultValue: 'cms_ad_e2eTestTokenClientA000000000000000aaaa',
  );
  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: cmsStudioTheme,
      home: FlutterCmsAuth(
        clientId: clientId,
        apiToken: apiToken,
        serverUrl: serverUrl,
        title: 'CMS E2E Test',
        builder: (context, client) => CmsStudioApp(
          dataSource: CloudDataSource(client),
          documentTypes: [homeScreenConfigDocumentType],
          documentTypeDecorations: [
            CmsDocumentTypeDecoration(
              documentType: homeScreenConfigDocumentType,
              icon: Icons.home,
            ),
          ],
          title: 'CMS E2E Test',
          subtitle: 'Integration Testing',
          icon: Icons.bug_report,
        ),
      ),
    );
  }
}
