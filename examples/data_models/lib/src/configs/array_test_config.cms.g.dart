// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'array_test_config.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for ArrayTestConfig
final arrayTestConfigFields = [
  CmsArrayField<HeroConfig>(
    name: 'cmsObjectList',
    title: 'Cms Object List',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Hero Config',
      option: CmsObjectOption(
        children: [ColumnFields(children: heroConfigFields)],
      ),
    ),
  ),
  CmsArrayField<SampleConfig>(
    name: 'unannotatedObjectList',
    title: 'Unannotated Object List',
    innerField: CmsObjectField(
      name: 'item',
      title: 'Sample Config',
      option: CmsObjectOption(
        children: [ColumnFields(children: sampleConfigFields)],
      ),
    ),
  ),
  CmsArrayField<String>(
    name: 'stringListWithImageInner',
    title: 'String List With Image Inner',
    innerField: CmsImageField(name: 'item', title: 'Item'),
  ),
];

/// Generated CmsField list for HeroConfig
final heroConfigFields = [
  CmsStringField(name: 'title', title: 'Title'),
  CmsImageField(name: 'heroImage', title: 'Hero Image'),
];

/// Generated CmsField list for SampleConfig
final sampleConfigFields = [
  CmsStringField(name: 'name', title: 'Name'),
  CmsImageField(name: 'image', title: 'Image'),
];

/// Generated document type spec for ArrayTestConfig.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final arrayTestConfigTypeSpec = DocumentTypeSpec<ArrayTestConfig>(
  name: 'arrayTestConfig',
  title: 'Array Test Configuration',
  description: 'Configuration for testing array fields in CMS',
  fields: arrayTestConfigFields,
  defaultValue: ArrayTestConfig.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class HeroConfigCmsConfig {
  HeroConfigCmsConfig({required this.title, required this.heroImage});

  final CmsData<String> title;

  final CmsData<ImageReference?> heroImage;
}

class ArrayTestConfigCmsConfig {
  ArrayTestConfigCmsConfig({
    required this.primitiveStrings,
    required this.cmsObjectList,
    required this.unannotatedObjectList,
    required this.stringListWithImageInner,
  });

  final CmsData<List<String>> primitiveStrings;

  final CmsData<List<HeroConfig>> cmsObjectList;

  final CmsData<List<SampleConfig>> unannotatedObjectList;

  final CmsData<List<String>> stringListWithImageInner;
}
