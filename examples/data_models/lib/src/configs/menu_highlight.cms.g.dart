// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_highlight.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for MenuHighlight
final menuHighlightFields = [
  CmsStringField(
    name: 'itemName',
    title: 'Item Name',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'description',
    title: 'Description',
    option: CmsTextOption(rows: 3),
  ),
  CmsImageField(
    name: 'photo',
    title: 'Photo',
    option: CmsImageOption(hotspot: true),
  ),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0, max: 999),
  ),
  CmsStringField(name: 'badge', title: 'Badge', option: CmsStringOption()),
  CmsDropdownField<String>(
    name: 'category',
    title: 'Category',
    option: MenuCategoryDropdownOption(),
  ),
  CmsNumberField(
    name: 'sortOrder',
    title: 'Sort Order',
    option: CmsNumberOption(min: 0, max: 999),
  ),
  CmsBooleanField(
    name: 'available',
    title: 'Available',
    option: CmsBooleanOption(),
  ),
  CmsNumberField(
    name: 'calories',
    title: 'Calories',
    option: CmsNumberOption(min: 0, max: 9999),
  ),
  CmsStringField(
    name: 'allergens',
    title: 'Allergens',
    option: CmsStringOption(),
  ),
];

/// Generated document type spec for MenuHighlight.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final menuHighlightTypeSpec = DocumentTypeSpec<MenuHighlight>(
  name: 'menuHighlight',
  title: 'Menu Highlight',
  description: 'Featured menu items and upsell products displayed to customers',
  fields: menuHighlightFields,
  defaultValue: MenuHighlight.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class MenuHighlightCmsConfig {
  MenuHighlightCmsConfig({
    required this.itemName,
    required this.description,
    required this.photo,
    required this.price,
    required this.badge,
    required this.category,
    required this.sortOrder,
    required this.available,
    required this.calories,
    required this.allergens,
  });

  final CmsData<String> itemName;

  final CmsData<String> description;

  final CmsData<ImageReference?> photo;

  final CmsData<num> price;

  final CmsData<String?> badge;

  final CmsData<String> category;

  final CmsData<int> sortOrder;

  final CmsData<bool> available;

  final CmsData<num> calories;

  final CmsData<String?> allergens;
}
