import '../base/field.dart';

class CmsStringOption extends CmsOption {
  const CmsStringOption({super.hidden});
}

class CmsStringField extends CmsField {
  const CmsStringField({
    required super.name,
    required super.title,
    super.description,
    required CmsStringOption super.option,
  });

  @override
  CmsStringOption get option => super.option as CmsStringOption;
}

class CmsStringFieldConfig extends CmsFieldConfig {
  const CmsStringFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsStringOption super.option = const CmsStringOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [String];
}
