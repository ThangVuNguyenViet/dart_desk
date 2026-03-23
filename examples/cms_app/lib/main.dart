import 'package:dart_desk/studio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'document_types.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';

void main() {
  const apiKey = String.fromEnvironment('API_KEY');
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
  }
  if (apiKey.isNotEmpty) {
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );

  static const apiKey = String.fromEnvironment('API_KEY');

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey.isNotEmpty ? apiKey : null,
      config: DartDeskConfig(
        documentTypes: [homeScreenDocumentType],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: homeScreenDocumentType,
            icon: Icons.home,
          ),
        ],
        title: 'Dart desk CMS',
        subtitle: 'Content Management',
        icon: Icons.dashboard,
      ),
    );
  }
}
