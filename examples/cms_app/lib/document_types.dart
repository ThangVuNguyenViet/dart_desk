import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_preview.dart';
import 'package:example_app/screens/kiosk_preview.dart';
import 'package:example_app/screens/hero_preview.dart';
import 'package:example_app/screens/upsell_preview.dart';
import 'package:example_app/screens/reward_preview.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemePreview(config: BrandThemeMapper.fromMap(merged));
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (data) {
    final merged = {...KioskConfig.defaultValue.toMap(), ...data};
    return KioskPreview(config: KioskConfigMapper.fromMap(merged));
  },
);

final heroDocumentType = heroConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HeroConfig.defaultValue.toMap(), ...data};
    return HeroPreview(config: HeroConfigMapper.fromMap(merged));
  },
);

final upsellDocumentType = upsellConfigTypeSpec.build(
  builder: (data) {
    final merged = {...UpsellConfig.defaultValue.toMap(), ...data};
    return UpsellPreview(config: UpsellConfigMapper.fromMap(merged));
  },
);

final rewardDocumentType = rewardConfigTypeSpec.build(
  builder: (data) {
    final merged = {...RewardConfig.defaultValue.toMap(), ...data};
    return RewardPreview(config: RewardConfigMapper.fromMap(merged));
  },
);
