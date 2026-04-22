// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'chef_profile.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for ChefProfile
final chefProfileFields = [
  DeskStringField(name: 'name', title: 'Name', option: DeskStringOption()),
  DeskStringField(name: 'role', title: 'Role', option: DeskStringOption()),
  DeskImageField(
    name: 'portrait',
    title: 'Portrait',
    option: DeskImageOption(hotspot: true),
  ),
  DeskTextField(name: 'bio', title: 'Bio', option: DeskTextOption()),
];

/// Generated document type spec for ChefProfile.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final chefProfileTypeSpec = DocumentTypeSpec<ChefProfile>(
  name: 'chefProfile',
  title: 'Chef profile',
  description: 'Head chef bio block',
  fields: chefProfileFields,
  defaultValue: ChefProfile.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class ChefProfileDeskModel {
  ChefProfileDeskModel({
    required this.name,
    required this.role,
    required this.portrait,
    required this.bio,
  });

  final DeskData<String> name;

  final DeskData<String> role;

  final DeskData<ImageReference?> portrait;

  final DeskData<String> bio;
}
