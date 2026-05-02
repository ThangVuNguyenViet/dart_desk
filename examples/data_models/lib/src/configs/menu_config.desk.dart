// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_config.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for MenuConfig
final menuConfigFields = [
  DeskMultiDropdownField<String>(
    name: 'categories',
    title: 'Categories',

    option: MenuCategoriesOption(),
  ),
  DeskMultiDropdownField<String>(
    name: 'filterTags',
    title: 'Filter Tags',

    option: MenuFilterTagsOption(),
  ),
  DeskArrayField<MenuItemEntry>(
    name: 'items',
    title: 'Items',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Menu Item Entry',
      option: DeskObjectOption(
        children: [ColumnFields(children: menuItemEntryFields)],
      ),
    ),
    fromMap: MenuItemEntry.$fromMap,
  ),
  DeskGeopointField(
    name: 'location',
    title: 'Location',
    option: DeskGeopointOption(optional: true),
  ),
  DeskArrayField<StoreHoursEntry>(
    name: 'storeHours',
    title: 'Store Hours',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Store Hours Entry',
      option: DeskObjectOption(
        children: [ColumnFields(children: storeHoursEntryFields)],
      ),
    ),
    fromMap: StoreHoursEntry.$fromMap,
  ),
];

/// Generated document type spec for MenuConfig.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final menuConfigTypeSpec = DocumentTypeSpec<MenuConfig>(
  name: 'menuConfig',
  title: 'Menu screen',
  description: 'Mobile menu browse with categories, filters, hours, location',
  fields: menuConfigFields,
  initialValue: MenuConfig.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class MenuConfigDeskModel {
  MenuConfigDeskModel({
    required this.categories,
    required this.filterTags,
    required this.items,
    required this.location,
    required this.storeHours,
  });

  final DeskData<List<String>> categories;

  final DeskData<List<String>> filterTags;

  final DeskData<List<MenuItemEntry>> items;

  final DeskData<Map<String, double>?> location;

  final DeskData<List<StoreHoursEntry>> storeHours;
}
