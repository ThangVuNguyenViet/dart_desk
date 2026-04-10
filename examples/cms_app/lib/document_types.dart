import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/restaurant_profile_screen.dart';
import 'package:example_app/screens/menu_item_screen.dart';
import 'package:example_app/screens/promotion_campaign_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

final restaurantProfileDocumentType = restaurantProfileTypeSpec.build(
  builder: (data) {
    final merged = {...RestaurantProfile.defaultValue.toMap(), ...data};
    return RestaurantProfileScreen(config: RestaurantProfileMapper.fromMap(merged));
  },
);

final menuItemDocumentType = menuItemTypeSpec.build(
  builder: (data) {
    final merged = {...MenuItem.defaultValue.toMap(), ...data};
    return MenuItemScreen(config: MenuItemMapper.fromMap(merged));
  },
);

final promotionCampaignDocumentType = promotionCampaignTypeSpec.build(
  builder: (data) {
    final merged = {...PromotionCampaign.defaultValue.toMap(), ...data};
    return PromotionCampaignScreen(config: PromotionCampaignMapper.fromMap(merged));
  },
);
