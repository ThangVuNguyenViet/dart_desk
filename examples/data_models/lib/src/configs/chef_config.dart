import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/chef_profile.dart';
import '../shared/curated_dish.dart';
import 'desk_content.dart';

part 'chef_config.desk.dart';
part 'chef_config.mapper.dart';

@DeskModel(title: "Chef's Choice", description: 'Mobile upsell — curated list + pull-quote')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'chefConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class ChefConfig extends DeskContent with ChefConfigMappable, Serializable<ChefConfig> {
  @DeskText(description: 'Headline', option: DeskTextOption())
  final String headline;

  @DeskBlock(option: DeskBlockOption())
  final Object? intro;

  @DeskObject(description: 'Chef profile')
  final ChefProfile chef;

  @DeskText(description: 'Pull quote', option: DeskTextOption())
  final String pullQuote;

  @DeskArray<CuratedDish>(description: 'Curated dishes')
  final List<CuratedDish> curatedDishes;

  @DeskString(description: 'Refresh cadence label', option: DeskStringOption())
  final String refreshCadence;

  @DeskDate(description: 'Published from', option: DeskDateOption())
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
