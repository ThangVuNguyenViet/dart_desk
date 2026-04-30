// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_item_entry.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for MenuItemEntry
final menuItemEntryFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskNumberField(
    name: 'price',
    title: 'Price',
    option: DeskNumberOption(min: 0),
  ),
  DeskTextField(
    name: 'shortDescription',
    title: 'Short Description',
    option: DeskTextOption(),
  ),
  DeskImageField(
    name: 'image',
    title: 'Image',
    option: DeskImageOption(optional: true, hotspot: true),
  ),
  DeskMultiDropdownField<String>(
    name: 'tags',
    title: 'Tags',

    option: MenuItemTagsOption(),
  ),
  DeskCheckboxField(
    name: 'isAvailable',
    title: 'Is Available',
    option: DeskCheckboxOption(optional: true, label: 'Available'),
  ),
];

/// Generated document type spec for MenuItemEntry.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final menuItemEntryTypeSpec = DocumentTypeSpec<MenuItemEntry>(
  name: 'menuItemEntry',
  title: 'Menu item',
  description: 'Row in the menu browse list',
  fields: menuItemEntryFields,
  defaultValue: MenuItemEntry.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class MenuItemEntryDeskModel {
  MenuItemEntryDeskModel({
    required this.name,
    required this.price,
    required this.shortDescription,
    required this.image,
    required this.tags,
    required this.isAvailable,
  });

  final DeskData<String> name;

  final DeskData<num> price;

  final DeskData<String> shortDescription;

  final DeskData<ImageReference?> image;

  final DeskData<List<String>> tags;

  final DeskData<bool?> isAvailable;
}
