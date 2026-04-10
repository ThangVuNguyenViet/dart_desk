import 'package:dart_desk/studio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'document_types.dart';

const String _defaultServerUrl = 'http://localhost:8080/';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(const MarionetteConfiguration());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'cms_w_5dGK1_MeafXRpFF5sLLU-0x5ICYqEIVDdyT9wrlcFmg',
  );

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: DartDeskConfig(
        documentTypes: [
          restaurantProfileDocumentType,
          menuItemDocumentType,
          promotionCampaignDocumentType,
          brandThemeDocumentType,
        ],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: restaurantProfileDocumentType,
            icon: Icons.store,
          ),
          DocumentTypeDecoration(
            documentType: menuItemDocumentType,
            icon: Icons.restaurant_menu,
          ),
          DocumentTypeDecoration(
            documentType: promotionCampaignDocumentType,
            icon: Icons.campaign,
          ),
          DocumentTypeDecoration(
            documentType: brandThemeDocumentType,
            icon: Icons.palette,
          ),
        ],
        title: 'Food Ordering CMS',
        subtitle: 'White-Label App Studio',
        icon: Icons.restaurant,
      ),
    );
  }
}
