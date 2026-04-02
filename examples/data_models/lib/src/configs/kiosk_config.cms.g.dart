// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'kiosk_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for KioskConfig
final kioskConfigFields = [
  CmsStringField(
    name: 'restaurantName',
    title: 'Restaurant Name',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'bannerTitle',
    title: 'Banner Title',
    option: CmsStringOption(),
  ),
  CmsTextField(
    name: 'bannerSubtitle',
    title: 'Banner Subtitle',
    option: CmsTextOption(rows: 2),
  ),
  CmsImageField(
    name: 'bannerImage',
    title: 'Banner Image',
    option: CmsImageOption(hotspot: false),
  ),
  CmsMultiDropdownField<String>(
    name: 'products',
    title: 'Products',
    option: KioskProductsDropdownOption(),
  ),
];

/// Generated document type spec for KioskConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final kioskConfigTypeSpec = DocumentTypeSpec<KioskConfig>(
  name: 'kioskConfig',
  title: 'Kiosk Screen',
  description:
      'Desktop 3-panel kiosk layout with product grid and order sidebar',
  fields: kioskConfigFields,
  defaultValue: KioskConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class KioskConfigCmsConfig {
  KioskConfigCmsConfig({
    required this.restaurantName,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerImage,
    required this.products,
  });

  final CmsData<String> restaurantName;

  final CmsData<String> bannerTitle;

  final CmsData<String> bannerSubtitle;

  final CmsData<ImageReference?> bannerImage;

  final CmsData<List<String>> products;
}
