import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

// Removed legacy document types — re-added incrementally as configs land:
// restaurantProfileDocumentType
// menuItemDocumentType
// promotionCampaignDocumentType
