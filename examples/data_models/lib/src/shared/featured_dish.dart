import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'featured_dish.cms.g.dart';
part 'featured_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@CmsConfig(title: 'Featured dish', description: 'Home screen carousel item')
class FeaturedDish with FeaturedDishMappable implements Serializable<FeaturedDish> {
  @CmsStringFieldConfig(description: 'Dish name', option: CmsStringOption())
  final String name;

  @CmsNumberFieldConfig(description: 'Price', option: CmsNumberOption(min: 0))
  final num price;

  @CmsDropdownFieldConfig<String>(description: 'Tag', option: FeaturedDishTagOption())
  final String tag;

  @CmsImageFieldConfig(description: 'Photo', option: CmsImageOption(hotspot: true))
  final ImageReference? image;

  const FeaturedDish({required this.name, required this.price, required this.tag, this.image});

  static FeaturedDish defaultValue = const FeaturedDish(name: 'Charred Brassicas', price: 16, tag: 'New');

  static FeaturedDish $fromMap(Map<String, dynamic> map) => FeaturedDishMapper.fromMap(map);
}

class FeaturedDishTagOption extends CmsDropdownOption<String> {
  const FeaturedDishTagOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'New';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in featuredDishTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tag';
}
