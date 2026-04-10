// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_item.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for MenuItemVariant
final menuItemVariantFields = [
  CmsStringField(name: 'label', title: 'Label', option: CmsStringOption()),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
];

/// Generated document type spec for MenuItemVariant.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final menuItemVariantTypeSpec = DocumentTypeSpec<MenuItemVariant>(
  name: 'menuItemVariant',
  title: 'Variant',
  description: 'A size/price variant of a menu item',
  fields: menuItemVariantFields,
  defaultValue: MenuItemVariant.defaultValue,
);

/// Generated CmsField list for MenuItem
final menuItemFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsStringField(name: 'sku', title: 'Sku', option: CmsStringOption()),
  CmsBlockField(
    name: 'description',
    title: 'Description',
    option: CmsBlockOption(),
  ),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
  CmsNumberField(
    name: 'calories',
    title: 'Calories',
    option: CmsNumberOption(min: 0),
  ),
  CmsBooleanField(name: 'isAvailable', title: 'Is Available'),
  CmsCheckboxField(
    name: 'isVegetarian',
    title: 'Is Vegetarian',
    option: CmsCheckboxOption(label: 'Vegetarian'),
  ),
  CmsCheckboxField(
    name: 'isGlutenFree',
    title: 'Is Gluten Free',
    option: CmsCheckboxOption(label: 'Gluten-free'),
  ),
  CmsDropdownField<String>(
    name: 'category',
    title: 'Category',

    option: MenuCategoryDropdownOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'allergens',
    title: 'Allergens',

    option: AllergensDropdownOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',

    option: MenuTagsDropdownOption(),
  ),
  CmsImageField(
    name: 'photo',
    title: 'Photo',
    option: CmsImageOption(hotspot: true),
  ),
  CmsObjectField(
    name: 'nutritionInfo',
    title: 'Nutrition Info',
    fromMap: NutritionInfo.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: nutritionInfoFields)],
    ),
  ),
  CmsArrayField<MenuItemVariant>(
    name: 'variants',
    title: 'Variants',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Menu Item Variant',
      option: CmsObjectOption(
        children: [ColumnFields(children: menuItemVariantFields)],
      ),
    ),
    fromMap: MenuItemVariant.$fromMap,
  ),
];

/// Generated CmsField list for NutritionInfo
final nutritionInfoFields = [
  CmsNumberField(name: 'protein', title: 'Protein'),
  CmsNumberField(name: 'carbs', title: 'Carbs'),
  CmsNumberField(name: 'fat', title: 'Fat'),
];

/// Generated document type spec for MenuItem.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final menuItemTypeSpec = DocumentTypeSpec<MenuItem>(
  name: 'menuItem',
  title: 'Menu Item',
  description:
      'A product on the restaurant menu with pricing, dietary info, and variants',
  fields: menuItemFields,
  defaultValue: MenuItem.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class MenuItemVariantCmsConfig {
  MenuItemVariantCmsConfig({required this.label, required this.price});

  final CmsData<String> label;

  final CmsData<num> price;
}

class MenuItemCmsConfig {
  MenuItemCmsConfig({
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.calories,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.category,
    required this.allergens,
    required this.tags,
    required this.photo,
    required this.nutritionInfo,
    required this.variants,
  });

  final CmsData<String> name;

  final CmsData<String> sku;

  final CmsData<Object?> description;

  final CmsData<num> price;

  final CmsData<num> calories;

  final CmsData<bool> isAvailable;

  final CmsData<bool> isVegetarian;

  final CmsData<bool> isGlutenFree;

  final CmsData<String> category;

  final CmsData<List<String>> allergens;

  final CmsData<List<String>> tags;

  final CmsData<ImageReference?> photo;

  final CmsData<NutritionInfo> nutritionInfo;

  final CmsData<List<MenuItemVariant>> variants;
}
