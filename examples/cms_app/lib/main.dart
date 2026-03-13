import 'package:data_models/example_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cms/flutter_cms.dart';
import 'package:flutter_cms/studio.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Google OAuth configuration
const String googleServerClientId =
    '486250973716-h7inr6886eqnve5rddl9jbpvgo3bdhto.apps.googleusercontent.com';
const String googleRedirectPath = '/googlesignin';

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
  late final Client client;

  @override
  void initState() {
    super.initState();
    client = Client(
      'http://localhost:8080/',
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: _buildCmsTheme(),
      // darkTheme: _buildCmsDarkTheme(),
      home: Scaffold(
        body: FlutterCmsAuth(
          client: client,
          child: CmsStudioApp(
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

  /// Creates a professional light theme suitable for a CMS interface
  static ShadThemeData _buildCmsTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(),
      textTheme: ShadTextTheme(
        family: 'Inter', // Professional, readable font for CMS interfaces
      ),
      radius: BorderRadius.circular(8.0),
    );
  }
}
