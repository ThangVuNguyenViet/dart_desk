// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'chef_profile.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for ChefProfile
final chefProfileFields = [
  CmsStringField(name: 'name', title: 'Name', option: CmsStringOption()),
  CmsStringField(name: 'role', title: 'Role', option: CmsStringOption()),
  CmsImageField(
    name: 'portrait',
    title: 'Portrait',
    option: CmsImageOption(hotspot: true),
  ),
  CmsTextField(name: 'bio', title: 'Bio', option: CmsTextOption()),
];

/// Generated document type spec for ChefProfile.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final chefProfileTypeSpec = DocumentTypeSpec<ChefProfile>(
  name: 'chefProfile',
  title: 'Chef profile',
  description: 'Head chef bio block',
  fields: chefProfileFields,
  defaultValue: ChefProfile.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class ChefProfileCmsConfig {
  ChefProfileCmsConfig({
    required this.name,
    required this.role,
    required this.portrait,
    required this.bio,
  });

  final CmsData<String> name;

  final CmsData<String> role;

  final CmsData<ImageReference?> portrait;

  final CmsData<String> bio;
}
