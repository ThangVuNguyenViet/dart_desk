// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'featured_dish.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for FeaturedDish
final featuredDishFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsNumberField(
    name: 'price',
    title: 'Price',
    option: CmsNumberOption(min: 0),
  ),
  CmsDropdownField<String>(
    name: 'tag',
    title: 'Tag',

    option: FeaturedDishTagOption(),
  ),
  CmsImageField(
    name: 'image',
    title: 'Image',
    option: CmsImageOption(hotspot: true),
  ),
];

/// Generated document type spec for FeaturedDish.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final featuredDishTypeSpec = DocumentTypeSpec<FeaturedDish>(
  name: 'featuredDish',
  title: 'Featured dish',
  description: 'Home screen carousel item',
  fields: featuredDishFields,
  defaultValue: FeaturedDish.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class FeaturedDishCmsConfig {
  FeaturedDishCmsConfig({
    required this.name,
    required this.price,
    required this.tag,
    required this.image,
  });

  final CmsData<String> name;

  final CmsData<num> price;

  final CmsData<String> tag;

  final CmsData<ImageReference?> image;
}
