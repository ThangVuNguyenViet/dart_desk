// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'array_test_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for ArrayTestConfig
final arrayTestConfigFields = [
  CmsArrayField<String>(
    name: 'tags',
    title: 'Tags',
    innerField: CmsStringField(name: 'item', title: 'String'),
  ),
  CmsArrayField<HeroConfig>(
    name: 'heroes',
    title: 'Heroes',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Hero Config',
      option: CmsObjectOption(
        children: [ColumnFields(children: heroConfigFields)],
      ),
    ),
  ),
  CmsArrayField<String>(
    name: 'gallery',
    title: 'Gallery',
    innerField: CmsImageField(name: 'item', title: 'Item'),
  ),
];

/// Generated document type spec for ArrayTestConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final arrayTestConfigTypeSpec = DocumentTypeSpec<ArrayTestConfig>(
  name: 'arrayTestConfig',
  title: 'Array Test Config',
  description: 'Testing unified array field inputs with objects and primitives',
  fields: arrayTestConfigFields,
  defaultValue: ArrayTestConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class ArrayTestConfigCmsConfig {
  ArrayTestConfigCmsConfig({
    required this.tags,
    required this.heroes,
    required this.gallery,
  });

  final CmsData<List<String>> tags;

  final CmsData<List<HeroConfig>> heroes;

  final CmsData<List<String>> gallery;
}
