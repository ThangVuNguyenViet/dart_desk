// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'featured_dish.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for FeaturedDish
final featuredDishFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskNumberField(
    name: 'price',
    title: 'Price',
    option: DeskNumberOption(min: 0),
  ),
  DeskDropdownField<String>(
    name: 'tag',
    title: 'Tag',

    option: FeaturedDishTagOption(),
  ),
  DeskImageField(
    name: 'image',
    title: 'Image',
    option: DeskImageOption(hotspot: true),
  ),
];

/// Generated document type spec for FeaturedDish.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final featuredDishTypeSpec = DocumentTypeSpec<FeaturedDish>(
  name: 'featuredDish',
  title: 'Featured dish',
  description: 'Home screen carousel item',
  fields: featuredDishFields,
  defaultValue: FeaturedDish.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class FeaturedDishDeskModel {
  FeaturedDishDeskModel({
    required this.name,
    required this.price,
    required this.tag,
    required this.image,
  });

  final DeskData<String> name;

  final DeskData<num> price;

  final DeskData<String> tag;

  final DeskData<ImageReference?> image;
}
