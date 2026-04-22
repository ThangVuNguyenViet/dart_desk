// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'curated_dish.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for CuratedDish
final curatedDishFields = [
  DeskStringField(
    name: 'numberLabel',
    title: 'Number Label',
    option: DeskStringOption(),
  ),
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
  DeskBlockField(
    name: 'description',
    title: 'Description',
    option: DeskBlockOption(),
  ),
];

/// Generated document type spec for CuratedDish.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final curatedDishTypeSpec = DocumentTypeSpec<CuratedDish>(
  name: 'curatedDish',
  title: 'Curated dish',
  description: 'Entry in the Chef\'s Choice list',
  fields: curatedDishFields,
  defaultValue: CuratedDish.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class CuratedDishDeskModel {
  CuratedDishDeskModel({
    required this.numberLabel,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final DeskData<String> numberLabel;

  final DeskData<String> name;

  final DeskData<num> price;

  final DeskData<ImageReference?> image;

  final DeskData<Object?> description;
}
