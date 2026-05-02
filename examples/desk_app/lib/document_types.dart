import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/chef_screen.dart';
import 'package:example_app/screens/home_screen.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:example_app/screens/menu_screen.dart';
import 'package:example_app/screens/rewards_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (context, data) {
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(data));
  },
);

final homeDocumentType = homeConfigTypeSpec.build(
  builder: (context, data) {
    return HomeScreen(
      config: HomeConfigMapper.fromMap(data),
      theme: BrandTheme.initialValue,
    );
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (context, data) {
    return KioskScreen(
      config: KioskConfigMapper.fromMap(data),
      theme: BrandTheme.initialValue,
    );
  },
);

final chefDocumentType = chefConfigTypeSpec.build(
  builder: (context, data) {
    return ChefScreen(
      config: ChefConfigMapper.fromMap(data),
      theme: BrandTheme.initialValue,
    );
  },
);

final menuDocumentType = menuConfigTypeSpec.build(
  builder: (context, data) {
    return MenuScreen(
      config: MenuConfigMapper.fromMap(data),
      theme: BrandTheme.initialValue,
    );
  },
);

final rewardsDocumentType = rewardsConfigTypeSpec.build(
  builder: (context, data) {
    return RewardsScreen(
      config: RewardsConfigMapper.fromMap(data),
      theme: BrandTheme.initialValue,
    );
  },
);
