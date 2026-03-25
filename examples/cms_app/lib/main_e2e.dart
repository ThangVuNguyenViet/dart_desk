import 'package:dart_desk/studio.dart';
import 'package:dart_desk/testing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'document_types.dart';

/// E2E entry point — uses real CloudDataSource. Auth is handled via marionette.
///
/// Launch with Dart MCP `launch_app` tool, or manually:
/// ```bash
/// flutter run -d chrome -t lib/main_e2e.dart
/// ```
void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
    FakeImagePickerPlatform.install();
  }
  runApp(const E2eApp());
}

class E2eApp extends StatelessWidget {
  const E2eApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:8080/',
  );

  static const apiKey = String.fromEnvironment('API_KEY');

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: DartDeskConfig(
        documentTypes: [homeScreenDocumentType],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: homeScreenDocumentType,
            icon: Icons.home,
          ),
        ],
        title: 'CMS E2E Test',
        subtitle: 'Integration Testing',
        icon: Icons.bug_report,
      ),
    );
  }
}
