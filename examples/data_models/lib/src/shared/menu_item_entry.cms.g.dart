// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_item_entry.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for MenuItemEntry
final menuItemEntryFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
  CmsTextField(
    name: 'shortDescription',
    title: 'Short Description',
    option: CmsTextOption(),
  ),
  CmsImageField(
    name: 'image',
    title: 'Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',

    option: MenuItemTagsOption(),
  ),
  CmsCheckboxField(
    name: 'isAvailable',
    title: 'Is Available',
    option: CmsCheckboxOption(label: 'Available'),
  ),
];

/// Generated document type spec for MenuItemEntry.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final menuItemEntryTypeSpec = DocumentTypeSpec<MenuItemEntry>(
  name: 'menuItemEntry',
  title: 'Menu item',
  description: 'Row in the menu browse list',
  fields: menuItemEntryFields,
  defaultValue: MenuItemEntry.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class MenuItemEntryCmsConfig {
  MenuItemEntryCmsConfig({
    required this.name,
    required this.price,
    required this.shortDescription,
    required this.image,
    required this.tags,
    required this.isAvailable,
  });

  final CmsData<String> name;

  final CmsData<num> price;

  final CmsData<String> shortDescription;

  final CmsData<ImageReference?> image;

  final CmsData<List<String>> tags;

  final CmsData<bool> isAvailable;
}
