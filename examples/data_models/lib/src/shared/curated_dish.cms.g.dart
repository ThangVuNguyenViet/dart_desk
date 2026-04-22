// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'curated_dish.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for CuratedDish
final curatedDishFields = [
  CmsStringField(
    name: 'numberLabel',
    title: 'Number Label',
    option: CmsStringOption(),
  ),
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
  CmsBlockField(
    name: 'description',
    title: 'Description',
    option: CmsBlockOption(),
  ),
];

/// Generated document type spec for CuratedDish.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final curatedDishTypeSpec = DocumentTypeSpec<CuratedDish>(
  name: 'curatedDish',
  title: 'Curated dish',
  description: 'Entry in the Chef\'s Choice list',
  fields: curatedDishFields,
  defaultValue: CuratedDish.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class CuratedDishCmsConfig {
  CuratedDishCmsConfig({
    required this.numberLabel,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final CmsData<String> numberLabel;

  final CmsData<String> name;

  final CmsData<num> price;

  final CmsData<ImageReference?> image;

  final CmsData<Object?> description;
}
