import 'dart:async';

import 'package:dart_desk/dart_desk.dart' show ImageReferenceMapper, ImageReference;
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'menu_highlight.cms.g.dart';
part 'menu_highlight.mapper.dart';

@CmsConfig(
  title: 'Menu Highlight',
  description: 'Featured menu items and upsell products displayed to customers',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [ImageReferenceMapper()])
class MenuHighlight with MenuHighlightMappable, Serializable<MenuHighlight> {
  @CmsStringFieldConfig(
    description: 'Name of the menu item',
    option: CmsStringOption(),
  )
  final String itemName;

  @CmsTextFieldConfig(
    description: 'Appetizing description of the dish',
    option: CmsTextOption(rows: 3),
  )
  final String description;

  @CmsImageFieldConfig(
    description: 'Photo of the dish with focal point control',
    option: CmsImageOption(hotspot: true),
  )
  final ImageReference? photo;

  @CmsNumberFieldConfig(
    description: 'Price in the local currency',
    option: CmsNumberOption(min: 0, max: 999),
  )
  final num price;

  @CmsStringFieldConfig(
    description: 'Optional badge label (e.g. NEW, POPULAR, SPICY)',
    option: CmsStringOption(),
  )
  final String? badge;

  @CmsDropdownFieldConfig<String>(
    description: 'Menu category this item belongs to',
    option: MenuCategoryDropdownOption(),
  )
  final String category;

  @CmsNumberFieldConfig(
    description: 'Display order within its category (lower = first)',
    option: CmsNumberOption(min: 0, max: 999),
  )
  final int sortOrder;

  @CmsBooleanFieldConfig(
    description: 'Whether this item is currently available for ordering',
    option: CmsBooleanOption(),
  )
  final bool available;

  @CmsNumberFieldConfig(
    description: 'Approximate calorie count per serving',
    option: CmsNumberOption(min: 0, max: 9999),
  )
  final num calories;

  @CmsStringFieldConfig(
    description: 'Comma-separated list of allergens (e.g. gluten, dairy)',
    option: CmsStringOption(),
  )
  final String? allergens;

  const MenuHighlight({
    required this.itemName,
    required this.description,
    this.photo,
    required this.price,
    this.badge,
    required this.category,
    required this.sortOrder,
    required this.available,
    required this.calories,
    this.allergens,
  });

  static MenuHighlight defaultValue = MenuHighlight(
    itemName: 'Truffle Mushroom Risotto',
    description:
        'Creamy Arborio rice slow-cooked with wild mushrooms, finished with truffle oil and aged Parmigiano-Reggiano.',
    photo: null,
    price: 24,
    badge: 'POPULAR',
    category: 'main',
    sortOrder: 0,
    available: true,
    calories: 450,
    allergens: 'dairy, gluten',
  );
}

class MenuCategoryDropdownOption extends CmsDropdownOption<String> {
  const MenuCategoryDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'main';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'appetizer', label: 'Appetizer'),
        DropdownOption(value: 'main', label: 'Main Course'),
        DropdownOption(value: 'dessert', label: 'Dessert'),
        DropdownOption(value: 'drink', label: 'Drink'),
        DropdownOption(value: 'side', label: 'Side'),
      ]);

  @override
  String? get placeholder => 'Select a category';
}
