// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'home_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for HomeConfig
final homeConfigFields = [
  CmsImageField(
    name: 'heroImage',
    title: 'Hero Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsStringField(
    name: 'heroEyebrow',
    title: 'Hero Eyebrow',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'heroHeadline',
    title: 'Hero Headline',
    option: CmsTextOption(),
  ),
  CmsObjectField(
    name: 'primaryCta',
    title: 'Primary Cta',
    fromMap: CtaAction.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: ctaActionFields)],
    ),
  ),
  CmsObjectField(
    name: 'secondaryCta',
    title: 'Secondary Cta',
    fromMap: CtaAction.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: ctaActionFields)],
    ),
  ),
  CmsStringField(
    name: 'locationLabel',
    title: 'Location Label',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'welcomeGreeting',
    title: 'Welcome Greeting',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'featuredSectionTitle',
    title: 'Featured Section Title',
    option: CmsStringOption(),
  ),
  CmsArrayField<FeaturedDish>(
    name: 'featuredDishes',
    title: 'Featured Dishes',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Featured Dish',
      option: CmsObjectOption(
        children: [ColumnFields(children: featuredDishFields)],
      ),
    ),
    fromMap: FeaturedDish.$fromMap,
  ),
  CmsObjectField(
    name: 'storeCallout',
    title: 'Store Callout',
    fromMap: StoreCallout.$fromMap,
    option: CmsObjectOption(
      children: [ColumnFields(children: storeCalloutFields)],
    ),
  ),
];

/// Generated document type spec for HomeConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final homeConfigTypeSpec = DocumentTypeSpec<HomeConfig>(
  name: 'homeConfig',
  title: 'Home screen',
  description: 'Mobile home — hero, welcome, featured carousel, store card',
  fields: homeConfigFields,
  defaultValue: HomeConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class HomeConfigCmsConfig {
  HomeConfigCmsConfig({
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

  final CmsData<ImageReference?> heroImage;

  final CmsData<String> heroEyebrow;

  final CmsData<String> heroHeadline;

  final CmsData<CtaActionCmsConfig> primaryCta;

  final CmsData<CtaActionCmsConfig> secondaryCta;

  final CmsData<String> locationLabel;

  final CmsData<String> welcomeGreeting;

  final CmsData<String> featuredSectionTitle;

  final CmsData<List<FeaturedDish>> featuredDishes;

  final CmsData<StoreCalloutCmsConfig> storeCallout;
}
