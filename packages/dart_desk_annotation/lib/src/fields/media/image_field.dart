import '../base/field.dart';

class CmsImageOption extends CmsOption {
  final bool hotspot;

  const CmsImageOption({required this.hotspot, super.hidden});
}

class CmsImageField extends CmsField {
  const CmsImageField({
    required super.name,
    required super.title,
    super.description,
    CmsImageOption? super.option,
  });

  @override
  CmsImageOption? get option => super.option as CmsImageOption?;
}

class CmsImageFieldConfig extends CmsFieldConfig {
  const CmsImageFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsImageOption? super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [Object]; // String (URL) or ImageUrl (resolved)
}
