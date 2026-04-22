// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'chef_config.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for ChefConfig
final chefConfigFields = [
  DeskTextField(name: 'headline', title: 'Headline', option: DeskTextOption()),
  DeskBlockField(name: 'intro', title: 'Intro', option: DeskBlockOption()),
  DeskObjectField(
    name: 'chef',
    title: 'Chef',
    fromMap: ChefProfile.$fromMap,
    option: DeskObjectOption(
      children: [ColumnFields(children: chefProfileFields)],
    ),
  ),
  DeskTextField(
    name: 'pullQuote',
    title: 'Pull Quote',
    option: DeskTextOption(),
  ),
  DeskArrayField<CuratedDish>(
    name: 'curatedDishes',
    title: 'Curated Dishes',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Curated Dish',
      option: DeskObjectOption(
        children: [ColumnFields(children: curatedDishFields)],
      ),
    ),
    fromMap: CuratedDish.$fromMap,
  ),
  DeskStringField(
    name: 'refreshCadence',
    title: 'Refresh Cadence',
    option: DeskStringOption(),
  ),
  DeskDateField(
    name: 'publishFrom',
    title: 'Publish From',
    option: DeskDateOption(),
  ),
];

/// Generated document type spec for ChefConfig.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final chefConfigTypeSpec = DocumentTypeSpec<ChefConfig>(
  name: 'chefConfig',
  title: 'Chef\'s Choice',
  description: 'Mobile upsell — curated list + pull-quote',
  fields: chefConfigFields,
  defaultValue: ChefConfig.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class ChefConfigDeskModel {
  ChefConfigDeskModel({
    required this.headline,
    required this.intro,
    required this.chef,
    required this.pullQuote,
    required this.curatedDishes,
    required this.refreshCadence,
    required this.publishFrom,
  });

  final DeskData<String> headline;

  final DeskData<Object?> intro;

  final DeskData<ChefProfileDeskModel> chef;

  final DeskData<String> pullQuote;

  final DeskData<List<CuratedDish>> curatedDishes;

  final DeskData<String> refreshCadence;

  final DeskData<DateTime> publishFrom;
}
