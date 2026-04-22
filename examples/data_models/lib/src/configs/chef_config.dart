import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/chef_profile.dart';
import '../shared/curated_dish.dart';
import 'cms_content.dart';

part 'chef_config.cms.g.dart';
part 'chef_config.mapper.dart';

@CmsConfig(title: "Chef's Choice", description: 'Mobile upsell — curated list + pull-quote')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'chefConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class ChefConfig extends CmsContent with ChefConfigMappable, Serializable<ChefConfig> {
  @CmsTextFieldConfig(description: 'Headline', option: CmsTextOption())
  final String headline;

  @CmsBlockFieldConfig(option: CmsBlockOption())
  final Object? intro;

  @CmsObjectFieldConfig(description: 'Chef profile')
  final ChefProfile chef;

  @CmsTextFieldConfig(description: 'Pull quote', option: CmsTextOption())
  final String pullQuote;

  @CmsArrayFieldConfig<CuratedDish>(description: 'Curated dishes')
  final List<CuratedDish> curatedDishes;

  @CmsStringFieldConfig(description: 'Refresh cadence label', option: CmsStringOption())
  final String refreshCadence;

  @CmsDateFieldConfig(description: 'Published from', option: CmsDateOption())
  final DateTime publishFrom;

  const ChefConfig({
    required this.headline,
    this.intro,
    required this.chef,
    required this.pullQuote,
    required this.curatedDishes,
    required this.refreshCadence,
    required this.publishFrom,
  });

  static ChefConfig defaultValue = ChefConfig(
    headline: AuraCopy.chefHeadline,
    chef: ChefProfile(
      name: AuraCopy.chefName,
      role: AuraCopy.chefRole,
      portrait: const ImageReference(externalUrl: AuraAssets.chefAlt),
      bio: ChefProfile.defaultValue.bio,
    ),
    pullQuote: AuraCopy.chefPullQuote,
    curatedDishes: const [
      CuratedDish(numberLabel: '01', name: 'Pea Tendril Agnolotti', price: 26, image: ImageReference(externalUrl: AuraAssets.dish10)),
      CuratedDish(numberLabel: '02', name: 'Whole Branzino',        price: 38, image: ImageReference(externalUrl: AuraAssets.dish11)),
      CuratedDish(numberLabel: '03', name: 'Olive Oil Cake',        price: 11, image: ImageReference(externalUrl: AuraAssets.dish5)),
    ],
    refreshCadence: AuraCopy.chefRefresh,
    publishFrom: DateTime(2026, 4, 15),
  );
}
