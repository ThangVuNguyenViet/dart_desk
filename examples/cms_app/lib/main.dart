import 'package:dart_desk/studio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'document_types.dart';

// Server configuration
const String _defaultServerUrl = 'http://localhost:8080/';

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

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
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
