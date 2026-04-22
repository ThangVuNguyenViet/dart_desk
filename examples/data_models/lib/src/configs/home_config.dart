import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/cta_action.dart';
import '../shared/featured_dish.dart';
import '../shared/store_callout.dart';
import 'cms_content.dart';

part 'home_config.cms.g.dart';
part 'home_config.mapper.dart';

@CmsConfig(title: 'Home screen', description: 'Mobile home — hero, welcome, featured carousel, store card')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'homeConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class HomeConfig extends CmsContent with HomeConfigMappable, Serializable<HomeConfig> {
  @CmsImageFieldConfig(description: 'Hero image', option: CmsImageOption(hotspot: true))
  final ImageReference? heroImage;

  @CmsStringFieldConfig(description: 'Hero eyebrow', option: CmsStringOption())
  final String heroEyebrow;

  @CmsTextFieldConfig(description: 'Hero headline', option: CmsTextOption())
  final String heroHeadline;

  @CmsObjectFieldConfig(description: 'Primary CTA')
  final CtaAction primaryCta;

  @CmsObjectFieldConfig(description: 'Secondary CTA')
  final CtaAction secondaryCta;

  @CmsStringFieldConfig(description: 'Location pill', option: CmsStringOption())
  final String locationLabel;

  @CmsStringFieldConfig(description: 'Welcome greeting', option: CmsStringOption())
  final String welcomeGreeting;

  @CmsStringFieldConfig(description: 'Featured section title', option: CmsStringOption())
  final String featuredSectionTitle;

  @CmsArrayFieldConfig<FeaturedDish>(description: 'Featured dishes')
  final List<FeaturedDish> featuredDishes;

  @CmsObjectFieldConfig(description: 'Store callout')
  final StoreCallout storeCallout;

  const HomeConfig({
    this.heroImage,
    required this.heroEyebrow,
    required this.heroHeadline,
    required this.primaryCta,
    required this.secondaryCta,
    required this.locationLabel,
    required this.welcomeGreeting,
    required this.featuredSectionTitle,
    required this.featuredDishes,
    required this.storeCallout,
  });

  static HomeConfig defaultValue = HomeConfig(
    heroImage: const ImageReference(externalUrl: AuraAssets.heroTable),
    heroEyebrow: AuraCopy.homeEyebrow,
    heroHeadline: AuraCopy.homeHeadline,
    primaryCta: const CtaAction(label: 'Order now', style: 'solid'),
    secondaryCta: const CtaAction(label: 'Reserve table', style: 'ghost'),
    locationLabel: AuraCopy.homeLocation,
    welcomeGreeting: AuraCopy.homeGreeting,
    featuredSectionTitle: AuraCopy.homeFeaturedTitle,
    featuredDishes: const [
      FeaturedDish(name: 'Charred Brassicas',   price: 16, tag: 'New',         image: ImageReference(externalUrl: AuraAssets.dish6)),
      FeaturedDish(name: "Orecchiette 'Nduja", price: 24, tag: "Chef's Pick", image: ImageReference(externalUrl: AuraAssets.dish7)),
      FeaturedDish(name: 'Olive Oil Cake',      price: 11, tag: 'Seasonal',    image: ImageReference(externalUrl: AuraAssets.dish5)),
      FeaturedDish(name: 'Citrus & Fennel',     price: 15, tag: 'Vegan',       image: ImageReference(externalUrl: AuraAssets.citrus)),
    ],
    storeCallout: StoreCallout.defaultValue,
  );
}
