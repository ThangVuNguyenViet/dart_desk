import 'package:data_models/example_data.dart';
import 'package:example_app/screens/storefront_preview.dart';
import 'package:example_app/screens/menu_highlight_card.dart';
import 'package:example_app/screens/promo_offer_banner.dart';
import 'package:example_app/screens/app_theme_preview.dart';
import 'package:example_app/screens/delivery_settings_view.dart';

final storefrontDocumentType = storefrontConfigTypeSpec.build(
  builder: (data) {
    final merged = {...StorefrontConfig.defaultValue.toMap(), ...data};
    return StorefrontPreview(
        config: StorefrontConfigMapper.fromMap(merged));
  },
);

final menuHighlightDocumentType = menuHighlightTypeSpec.build(
  builder: (data) {
    final merged = {...MenuHighlight.defaultValue.toMap(), ...data};
    return MenuHighlightCard(
        config: MenuHighlightMapper.fromMap(merged));
  },
);

final promoOfferDocumentType = promoOfferTypeSpec.build(
  builder: (data) {
    final merged = {...PromoOffer.defaultValue.toMap(), ...data};
    return PromoOfferBanner(
        config: PromoOfferMapper.fromMap(merged));
  },
);

final appThemeDocumentType = appThemeTypeSpec.build(
  builder: (data) {
    final merged = {...AppTheme.defaultValue.toMap(), ...data};
    return AppThemePreview(
        config: AppThemeMapper.fromMap(merged));
  },
);

final deliverySettingsDocumentType = deliverySettingsTypeSpec.build(
  builder: (data) {
    final merged = {...DeliverySettings.defaultValue.toMap(), ...data};
    return DeliverySettingsView(
        config: DeliverySettingsMapper.fromMap(merged));
  },
);
