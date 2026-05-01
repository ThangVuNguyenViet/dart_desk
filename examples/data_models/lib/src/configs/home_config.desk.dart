// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'home_config.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for HomeConfig
final homeConfigFields = [
  DeskImageField(
    name: 'heroImage',
    title: 'Hero Image',
    option: DeskImageOption(optional: true, hotspot: true),
  ),
  DeskStringField(
    name: 'heroEyebrow',
    title: 'Hero Eyebrow',
    option: DeskStringOption(),
  ),
  DeskTextField(
    name: 'heroHeadline',
    title: 'Hero Headline',
    option: DeskTextOption(),
  ),
  DeskObjectField(
    name: 'primaryCta',
    title: 'Primary Cta',
    fromMap: CtaAction.$fromMap,
    option: DeskObjectOption(
      children: [ColumnFields(children: ctaActionFields)],
    ),
  ),
  DeskObjectField(
    name: 'secondaryCta',
    title: 'Secondary Cta',
    fromMap: CtaAction.$fromMap,
    option: DeskObjectOption(
      children: [ColumnFields(children: ctaActionFields)],
    ),
  ),
  DeskStringField(
    name: 'locationLabel',
    title: 'Location Label',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'welcomeGreeting',
    title: 'Welcome Greeting',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'featuredSectionTitle',
    title: 'Featured Section Title',
    option: DeskStringOption(),
  ),
  DeskArrayField<FeaturedDish>(
    name: 'featuredDishes',
    title: 'Featured Dishes',
    innerField: DeskObjectField(
      name: 'item',
      title: 'Featured Dish',
      option: DeskObjectOption(
        children: [ColumnFields(children: featuredDishFields)],
      ),
    ),
    fromMap: FeaturedDish.$fromMap,
  ),
  DeskObjectField(
    name: 'storeCallout',
    title: 'Store Callout',
    fromMap: StoreCallout.$fromMap,
    option: DeskObjectOption(
      children: [ColumnFields(children: storeCalloutFields)],
    ),
  ),
];

/// Generated document type spec for HomeConfig.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final homeConfigTypeSpec = DocumentTypeSpec<HomeConfig>(
  name: 'homeConfig',
  title: 'Home screen',
  description: 'Mobile home — hero, welcome, featured carousel, store card',
  fields: homeConfigFields,
  initialValue: HomeConfig.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class HomeConfigDeskModel {
  HomeConfigDeskModel({
    required this.heroImage,
    required this.heroEyebrow,
    required this.heroHeadline,
    required this.primaryCta,
    required this.secondaryCta,
    required this.locationLabel,
    required this.welcomeGreeting,
    required this.featuredSectionTitle,
    required this.featuredDishes,
    required this.storeCallout,
  });

  final DeskData<ImageReference?> heroImage;

  final DeskData<String> heroEyebrow;

  final DeskData<String> heroHeadline;

  final DeskData<CtaActionDeskModel> primaryCta;

  final DeskData<CtaActionDeskModel> secondaryCta;

  final DeskData<String> locationLabel;

  final DeskData<String> welcomeGreeting;

  final DeskData<String> featuredSectionTitle;

  final DeskData<List<FeaturedDish>> featuredDishes;

  final DeskData<StoreCalloutDeskModel> storeCallout;
}
