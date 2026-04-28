import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../primitives/aura_assets.dart';
import '../primitives/aura_copy.dart';
import '../shared/cta_action.dart';
import '../shared/featured_dish.dart';
import '../shared/store_callout.dart';
import 'desk_content.dart';

part 'home_config.desk.dart';
part 'home_config.mapper.dart';

@DeskModel(title: 'Home screen', description: 'Mobile home — hero, welcome, featured carousel, store card')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'homeConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class HomeConfig extends DeskContent with HomeConfigMappable, Serializable<HomeConfig> {
  @DeskImage(description: 'Hero image', option: DeskImageOption(hotspot: true))
  final ImageReference? heroImage;

  @DeskString(description: 'Hero eyebrow', option: DeskStringOption())
  final String heroEyebrow;

  @DeskText(description: 'Hero headline', option: DeskTextOption())
  final String heroHeadline;

  @DeskObject(description: 'Primary CTA')
  final CtaAction primaryCta;

  @DeskObject(description: 'Secondary CTA')
  final CtaAction secondaryCta;

  @DeskString(description: 'Location pill', option: DeskStringOption())
  final String locationLabel;

  @DeskString(description: 'Welcome greeting', option: DeskStringOption())
  final String welcomeGreeting;

  @DeskString(description: 'Featured section title', option: DeskStringOption())
  final String featuredSectionTitle;

  @DeskArray<FeaturedDish>(description: 'Featured dishes')
  final List<FeaturedDish> featuredDishes;

  @DeskObject(description: 'Store callout')
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
