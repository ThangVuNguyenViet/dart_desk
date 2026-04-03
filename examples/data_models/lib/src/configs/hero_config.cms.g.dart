// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'hero_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for HeroConfig
final heroConfigFields = [
  CmsStringField(
    name: 'heroTitle',
    title: 'Hero Title',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'heroSubtitle',
    title: 'Hero Subtitle',
    option: CmsTextOption(rows: 2),
  ),
  CmsImageField(
    name: 'heroImage',
    title: 'Hero Image',
    option: CmsImageOption(hotspot: false),
  ),
  CmsStringField(
    name: 'ctaLabel',
    title: 'Cta Label',
    option: CmsStringOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'products',
    title: 'Products',
    option: HeroProductsDropdownOption(),
  ),
];

/// Generated document type spec for HeroConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final heroConfigTypeSpec = DocumentTypeSpec<HeroConfig>(
  name: 'heroConfig',
  title: 'Hero Screen',
  description:
      'Mobile home screen with hero image, categories, and featured products',
  fields: heroConfigFields,
  defaultValue: HeroConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class HeroConfigCmsConfig {
  HeroConfigCmsConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroImage,
    required this.ctaLabel,
    required this.products,
  });

  final CmsData<String> heroTitle;

  final CmsData<String> heroSubtitle;

  final CmsData<ImageReference?> heroImage;

  final CmsData<String> ctaLabel;

  final CmsData<List<String>> products;
}
