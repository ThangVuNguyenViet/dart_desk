// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'kiosk_product.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for KioskProduct
final kioskProductFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskNumberField(
    name: 'price',
    title: 'Price',
    option: DeskNumberOption(min: 0),
  ),
  DeskImageField(
    name: 'image',
    title: 'Image',
    option: DeskImageOption(hotspot: true),
  ),
  DeskDropdownField<String>(
    name: 'category',
    title: 'Category',

    option: KioskCategoryOption(),
  ),
];

/// Generated document type spec for KioskProduct.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final kioskProductTypeSpec = DocumentTypeSpec<KioskProduct>(
  name: 'kioskProduct',
  title: 'Kiosk product',
  description: 'Tile in the kiosk grid',
  fields: kioskProductFields,
  defaultValue: KioskProduct.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class KioskProductDeskModel {
  KioskProductDeskModel({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  final DeskData<String> name;

  final DeskData<num> price;

  final DeskData<ImageReference?> image;

  final DeskData<String> category;
}
