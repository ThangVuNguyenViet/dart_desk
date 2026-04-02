import 'package:dart_desk/studio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'document_types.dart';

// Server configuration
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
          storefrontDocumentType,
          menuHighlightDocumentType,
          promoOfferDocumentType,
          appThemeDocumentType,
          deliverySettingsDocumentType,
        ],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: storefrontDocumentType,
            icon: Icons.storefront,
          ),
          DocumentTypeDecoration(
            documentType: menuHighlightDocumentType,
            icon: Icons.restaurant_menu,
          ),
          DocumentTypeDecoration(
            documentType: promoOfferDocumentType,
            icon: Icons.local_offer,
          ),
          DocumentTypeDecoration(
            documentType: appThemeDocumentType,
            icon: Icons.palette,
          ),
          DocumentTypeDecoration(
            documentType: deliverySettingsDocumentType,
            icon: Icons.delivery_dining,
          ),
        ],
        title: 'Food Ordering CMS',
        subtitle: 'White-Label App Studio',
        icon: Icons.restaurant,
      ),
    );
  }
}
