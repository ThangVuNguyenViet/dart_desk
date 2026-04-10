import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'cms_content.dart';

part 'menu_item.cms.g.dart';
part 'menu_item.mapper.dart';

// ── Nested types ──────────────────────────────────────────────────────────

@MappableClass()
class NutritionInfo with NutritionInfoMappable {
  final int protein;
  final int carbs;
  final int fat;

  const NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  static NutritionInfo defaultValue = const NutritionInfo(
    protein: 12,
    carbs: 45,
    fat: 18,
  );

  static NutritionInfo $fromMap(Map<String, dynamic> map) =>
      NutritionInfoMapper.fromMap(map);
}

@MappableClass()
@CmsConfig(title: 'Variant', description: 'A size/price variant of a menu item')
class MenuItemVariant
    with MenuItemVariantMappable
    implements Serializable<MenuItemVariant> {
  @CmsStringFieldConfig(
    description: 'Variant label (e.g. Small, Large)',
    option: CmsStringOption(),
  )
  final String label;

  @CmsNumberFieldConfig(
    description: 'Price for this variant',
    option: CmsNumberOption(min: 0),
  )
  final num price;

  const MenuItemVariant({required this.label, required this.price});

  static MenuItemVariant defaultValue = const MenuItemVariant(
    label: 'Regular',
    price: 0,
  );

  static MenuItemVariant $fromMap(Map<String, dynamic> map) =>
      MenuItemVariantMapper.fromMap(map);
}

// ── Main config ───────────────────────────────────────────────────────────

@CmsConfig(
  title: 'Menu Item',
  description:
      'A product on the restaurant menu with pricing, dietary info, and variants',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'menuItem',
  includeCustomMappers: [MenuItemColorMapper(), ImageReferenceMapper()],
)
class MenuItem extends CmsContent
    with MenuItemMappable, Serializable<MenuItem> {
  @CmsStringFieldConfig(description: 'Item name', option: CmsStringOption())
  final String name;

  @CmsStringFieldConfig(
    description: 'Internal product code',
    option: CmsStringOption(),
  )
  final String sku;

  @CmsBlockFieldConfig(option: CmsBlockOption())
  final Object? description;

  @CmsNumberFieldConfig(
    description: 'Base price',
    option: CmsNumberOption(min: 0),
  )
  final num price;

  @CmsNumberFieldConfig(
    description: 'Calorie count (optional)',
    option: CmsNumberOption(min: 0),
  )
  final num calories;

  @CmsBooleanFieldConfig(description: 'Is this item currently available?')
  final bool isAvailable;

  @CmsCheckboxFieldConfig(
    description: 'Vegetarian',
    option: CmsCheckboxOption(label: 'Vegetarian'),
  )
  final bool isVegetarian;

  @CmsCheckboxFieldConfig(
    description: 'Gluten-free',
    option: CmsCheckboxOption(label: 'Gluten-free'),
  )
  final bool isGlutenFree;

  @CmsDropdownFieldConfig<String>(
    description: 'Menu category',
    option: MenuCategoryDropdownOption(),
  )
  final String category;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Allergens present in this item',
    option: AllergensDropdownOption(),
  )
  final List<String> allergens;

  @CmsMultiDropdownFieldConfig<String>(
    description: 'Tags for filtering and display',
    option: MenuTagsDropdownOption(),
  )
  final List<String> tags;

  @CmsImageFieldConfig(
    description: 'Product photo',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? photo;

  @CmsObjectFieldConfig(description: 'Nutritional information per serving')
  final NutritionInfo nutritionInfo;

  @CmsArrayFieldConfig<MenuItemVariant>(description: 'Size/price variants')
  final List<MenuItemVariant> variants;

  const MenuItem({
    required this.name,
    required this.sku,
    this.description,
    required this.price,
    required this.calories,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.category,
    required this.allergens,
    required this.tags,
    this.photo,
    required this.nutritionInfo,
    required this.variants,
  });

  static MenuItem defaultValue = MenuItem(
    name: 'Black Truffle Risotto',
    sku: 'RISK-001',
    description: null,
    price: 34.50,
    calories: 620,
    isAvailable: true,
    isVegetarian: true,
    isGlutenFree: true,
    category: 'Main',
    allergens: ['Dairy'],
    tags: ["Chef's Pick", 'Popular'],
    photo: null,
    nutritionInfo: NutritionInfo.defaultValue,
    variants: [
      const MenuItemVariant(label: 'Regular', price: 34.50),
      const MenuItemVariant(label: 'Large', price: 42.00),
    ],
  );
}

class MenuItemColorMapper extends SimpleMapper<Color> {
  const MenuItemColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class MenuCategoryDropdownOption extends CmsDropdownOption<String> {
  const MenuCategoryDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Main';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final c in menuCategories) DropdownOption(value: c, label: c),
  ];

  @override
  String? get placeholder => 'Select category';
}

class AllergensDropdownOption extends CmsMultiDropdownOption<String> {
  const AllergensDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => [];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final a in allergenTypes) DropdownOption(value: a, label: a),
  ];

  @override
  String? get placeholder => 'Select allergens';
}

class MenuTagsDropdownOption extends CmsMultiDropdownOption<String> {
  const MenuTagsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => [];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
    for (final t in menuTags) DropdownOption(value: t, label: t),
  ];

  @override
  String? get placeholder => 'Select tags';
}
