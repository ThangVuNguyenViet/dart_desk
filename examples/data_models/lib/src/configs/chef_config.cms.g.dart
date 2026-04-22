// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'chef_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for ChefConfig
final chefConfigFields = [
  CmsTextField(name: 'headline', title: 'Headline', option: CmsTextOption()),
  CmsBlockField(name: 'intro', title: 'Intro', option: CmsBlockOption()),
  CmsObjectField(
    name: 'chef',
    title: 'Chef',
    fromMap: ChefProfile.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: chefProfileFields)],
    ),
  ),
  CmsTextField(name: 'pullQuote', title: 'Pull Quote', option: CmsTextOption()),
  CmsArrayField<CuratedDish>(
    name: 'curatedDishes',
    title: 'Curated Dishes',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Curated Dish',
      option: CmsObjectOption(
        children: [ColumnFields(children: curatedDishFields)],
      ),
    ),
    fromMap: CuratedDish.$fromMap,
  ),
  CmsStringField(
    name: 'refreshCadence',
    title: 'Refresh Cadence',
    option: CmsStringOption(),
  ),
  CmsDateField(
    name: 'publishFrom',
    title: 'Publish From',
    option: CmsDateOption(),
  ),
];

/// Generated document type spec for ChefConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final chefConfigTypeSpec = DocumentTypeSpec<ChefConfig>(
  name: 'chefConfig',
  title: 'Chef\'s Choice',
  description: 'Mobile upsell — curated list + pull-quote',
  fields: chefConfigFields,
  defaultValue: ChefConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class ChefConfigCmsConfig {
  ChefConfigCmsConfig({
    required this.headline,
    required this.intro,
    required this.chef,
    required this.pullQuote,
    required this.curatedDishes,
    required this.refreshCadence,
    required this.publishFrom,
  });

  final CmsData<String> headline;

  final CmsData<Object?> intro;

  final CmsData<ChefProfileCmsConfig> chef;

  final CmsData<String> pullQuote;

  final CmsData<List<CuratedDish>> curatedDishes;

  final CmsData<String> refreshCadence;

  final CmsData<DateTime> publishFrom;
}
