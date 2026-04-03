// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'upsell_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for UpsellConfig
final upsellConfigFields = [
  CmsStringField(
    name: 'sectionTitle',
    title: 'Section Title',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'sectionSubtitle',
    title: 'Section Subtitle',
    option: CmsTextOption(rows: 2),
  ),
  CmsTextField(
    name: 'quoteText',
    title: 'Quote Text',
    option: CmsTextOption(rows: 3),
  ),
  CmsStringField(
    name: 'chefName',
    title: 'Chef Name',
    option: CmsStringOption(),
  ),
  CmsMultiDropdownField<String>(
    name: 'products',
    title: 'Products',
    option: UpsellProductsDropdownOption(),
  ),
];

/// Generated document type spec for UpsellConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final upsellConfigTypeSpec = DocumentTypeSpec<UpsellConfig>(
  name: 'upsellConfig',
  title: 'Upsell Screen',
  description:
      'Mobile Chefs Choice curated item list with editorial pull-quote',
  fields: upsellConfigFields,
  defaultValue: UpsellConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class UpsellConfigCmsConfig {
  UpsellConfigCmsConfig({
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.quoteText,
    required this.chefName,
    required this.products,
  });

  final CmsData<String> sectionTitle;

  final CmsData<String> sectionSubtitle;

  final CmsData<String> quoteText;

  final CmsData<String> chefName;

  final CmsData<List<String>> products;
}
