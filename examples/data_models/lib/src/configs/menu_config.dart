import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../primitives/aura_assets.dart';
import '../primitives/aura_enums.dart';
import '../shared/menu_item_entry.dart';
import '../shared/store_hours_entry.dart';
import 'desk_content.dart';

part 'menu_config.desk.dart';
part 'menu_config.mapper.dart';

@DeskModel(title: 'Menu screen', description: 'Mobile menu browse with categories, filters, hours, location')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'menuConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class MenuConfig extends DeskContent with MenuConfigMappable, Serializable<MenuConfig> {
  @DeskMultiDropdown<String>(description: 'Categories shown as tabs', option: MenuCategoriesOption())
  final List<String> categories;

  @DeskMultiDropdown<String>(description: 'Filter chip set', option: MenuFilterTagsOption())
  final List<String> filterTags;

  @DeskArray<MenuItemEntry>(description: 'Menu items')
  final List<MenuItemEntry> items;

  @DeskGeopoint()
  final Map<String, double>? location;

  @DeskArray<StoreHoursEntry>(description: 'Weekly hours')
  final List<StoreHoursEntry> storeHours;

  const MenuConfig({
    required this.categories,
    required this.filterTags,
    required this.items,
    this.location,
    required this.storeHours,
  });

  static MenuConfig defaultValue = const MenuConfig(
    categories: ['Starters', 'Mains', 'Desserts', 'Drinks'],
    filterTags: ['Vegan', 'Gluten-free', "Chef's Pick"],
    items: [
      MenuItemEntry(name: 'Citrus & Fennel',       price: 15, shortDescription: 'Blood orange, fennel pollen, olive oil.', image: ImageReference(externalUrl: AuraAssets.citrus), tags: ['Vegan'], isAvailable: true),
      MenuItemEntry(name: "Orecchiette 'Nduja",    price: 24, shortDescription: "House pasta, spicy 'nduja, pecorino.",     image: ImageReference(externalUrl: AuraAssets.dish7),   tags: ["Chef's Pick"], isAvailable: true),
      MenuItemEntry(name: 'Pea Tendril Agnolotti', price: 26, shortDescription: "Sheep's milk, brown butter, lemon.",       image: ImageReference(externalUrl: AuraAssets.dish10),  tags: ['Seasonal'], isAvailable: true),
      MenuItemEntry(name: 'Whole Branzino',        price: 38, shortDescription: 'Salt-baked, green almond, fennel pollen.', image: ImageReference(externalUrl: AuraAssets.dish11),  tags: ['Gluten-free'], isAvailable: false),
      MenuItemEntry(name: 'Olive Oil Cake',        price: 11, shortDescription: 'Meyer lemon curd, candied pistachio.',     image: ImageReference(externalUrl: AuraAssets.dish5),   tags: ['Vegan'], isAvailable: true),
    ],
    location: {'lat': 40.7193, 'lng': -74.0067},
    storeHours: [
      StoreHoursEntry(day: 'Mon', openTime: '17:00', closeTime: '23:00'),
      StoreHoursEntry(day: 'Tue', openTime: '17:00', closeTime: '23:00'),
      StoreHoursEntry(day: 'Wed', openTime: '17:00', closeTime: '23:30'),
      StoreHoursEntry(day: 'Thu', openTime: '17:00', closeTime: '23:30'),
      StoreHoursEntry(day: 'Fri', openTime: '17:00', closeTime: '00:30'),
      StoreHoursEntry(day: 'Sat', openTime: '12:00', closeTime: '00:30'),
      StoreHoursEntry(day: 'Sun', openTime: '12:00', closeTime: '22:00'),
    ],
  );
}

class MenuCategoriesOption extends DeskMultiDropdownOption<String> {
  const MenuCategoriesOption({super.visibleWhen});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => 1;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final c in menuCategories) DropdownOption(value: c, label: c),
      ];
  @override
  String? get placeholder => 'Categories';
}

class MenuFilterTagsOption extends DeskMultiDropdownOption<String> {
  const MenuFilterTagsOption({super.visibleWhen});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in menuFilterTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Filter tags';
}
