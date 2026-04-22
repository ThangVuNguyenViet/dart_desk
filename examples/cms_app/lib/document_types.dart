import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/chef_screen.dart';
import 'package:example_app/screens/home_screen.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:example_app/screens/menu_screen.dart';
import 'package:example_app/screens/rewards_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

final homeDocumentType = homeConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HomeConfig.defaultValue.toMap(), ...data};
    return HomeScreen(
      config: HomeConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (data) {
    final merged = {...KioskConfig.defaultValue.toMap(), ...data};
    return KioskScreen(
      config: KioskConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final chefDocumentType = chefConfigTypeSpec.build(
  builder: (data) {
    final merged = {...ChefConfig.defaultValue.toMap(), ...data};
    return ChefScreen(
      config: ChefConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final menuDocumentType = menuConfigTypeSpec.build(
  builder: (data) {
    final merged = {...MenuConfig.defaultValue.toMap(), ...data};
    return MenuScreen(
      config: MenuConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final rewardsDocumentType = rewardsConfigTypeSpec.build(
  builder: (data) {
    final merged = {...RewardsConfig.defaultValue.toMap(), ...data};
    return RewardsScreen(
      config: RewardsConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);
