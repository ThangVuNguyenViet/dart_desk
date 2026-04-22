// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'menu_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for MenuConfig
final menuConfigFields = [
  CmsMultiDropdownField<String>(
    name: 'categories',
    title: 'Categories',

    option: MenuCategoriesOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'filterTags',
    title: 'Filter Tags',

    option: MenuFilterTagsOption(),
  ),
  CmsArrayField<MenuItemEntry>(
    name: 'items',
    title: 'Items',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Menu Item Entry',
      option: CmsObjectOption(
        children: [ColumnFields(children: menuItemEntryFields)],
      ),
    ),
    fromMap: MenuItemEntry.$fromMap,
  ),
  CmsGeopointField(name: 'location', title: 'Location'),
  CmsArrayField<StoreHoursEntry>(
    name: 'storeHours',
    title: 'Store Hours',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Store Hours Entry',
      option: CmsObjectOption(
        children: [ColumnFields(children: storeHoursEntryFields)],
      ),
    ),
    fromMap: StoreHoursEntry.$fromMap,
  ),
];

/// Generated document type spec for MenuConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final menuConfigTypeSpec = DocumentTypeSpec<MenuConfig>(
  name: 'menuConfig',
  title: 'Menu screen',
  description: 'Mobile menu browse with categories, filters, hours, location',
  fields: menuConfigFields,
  defaultValue: MenuConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class MenuConfigCmsConfig {
  MenuConfigCmsConfig({
    required this.categories,
    required this.filterTags,
    required this.items,
    required this.location,
    required this.storeHours,
  });

  final CmsData<List<String>> categories;

  final CmsData<List<String>> filterTags;

  final CmsData<List<MenuItemEntry>> items;

  final CmsData<Map<String, double>?> location;

  final CmsData<List<StoreHoursEntry>> storeHours;
}
