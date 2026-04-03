import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:example_app/screens/hero_screen.dart';
import 'package:example_app/screens/upsell_screen.dart';
import 'package:example_app/screens/reward_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (data) {
    final merged = {...KioskConfig.defaultValue.toMap(), ...data};
    return KioskScreen(config: KioskConfigMapper.fromMap(merged));
  },
);

final heroDocumentType = heroConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HeroConfig.defaultValue.toMap(), ...data};
    return HeroScreen(config: HeroConfigMapper.fromMap(merged));
  },
);

final upsellDocumentType = upsellConfigTypeSpec.build(
  builder: (data) {
    final merged = {...UpsellConfig.defaultValue.toMap(), ...data};
    return UpsellScreen(config: UpsellConfigMapper.fromMap(merged));
  },
);

final rewardDocumentType = rewardConfigTypeSpec.build(
  builder: (data) {
    final merged = {...RewardConfig.defaultValue.toMap(), ...data};
    return RewardScreen(config: RewardConfigMapper.fromMap(merged));
  },
);
