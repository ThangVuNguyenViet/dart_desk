import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../primitives/aura_enums.dart';

part 'featured_dish.desk.dart';
part 'featured_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Featured dish', description: 'Home screen carousel item')
class FeaturedDish
    with FeaturedDishMappable
    implements Serializable<FeaturedDish> {
  @DeskString(description: 'Dish name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskDropdown<String>(description: 'Tag', option: FeaturedDishTagOption())
  final String tag;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  const FeaturedDish({
    required this.name,
    required this.price,
    required this.tag,
    this.image,
  });

  static FeaturedDish initialValue = const FeaturedDish(
    name: 'Charred Brassicas',
    price: 16,
    tag: 'New',
  );

  static FeaturedDish $fromMap(Map<String, dynamic> map) =>
      FeaturedDishMapper.fromMap(map);

  @override
  String toString() {
    return '$name - \$$price ($tag) ${image != null ? '[Image: ${image!.url}]' : ''}';
  }
}

class FeaturedDishTagOption extends DeskDropdownOption<String> {
  const FeaturedDishTagOption({super.visibleWhen});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get initialValue => 'New';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final t in featuredDishTags) DropdownOption(value: t, label: t),
  ];
  @override
  String? get placeholder => 'Tag';
}
