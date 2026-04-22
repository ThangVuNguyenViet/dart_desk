// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'kiosk_product.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for KioskProduct
final kioskProductFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
  CmsImageField(
    name: 'image',
    title: 'Image',
    option: CmsImageOption(hotspot: true),
  ),
  CmsDropdownField<String>(
    name: 'category',
    title: 'Category',

    option: KioskCategoryOption(),
  ),
];

/// Generated document type spec for KioskProduct.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final kioskProductTypeSpec = DocumentTypeSpec<KioskProduct>(
  name: 'kioskProduct',
  title: 'Kiosk product',
  description: 'Tile in the kiosk grid',
  fields: kioskProductFields,
  defaultValue: KioskProduct.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class KioskProductCmsConfig {
  KioskProductCmsConfig({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  final CmsData<String> name;

  final CmsData<num> price;

  final CmsData<ImageReference?> image;

  final CmsData<String> category;
}
