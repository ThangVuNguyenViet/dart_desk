import '../base/field.dart';

class CmsUrlOption extends CmsOption {
  const CmsUrlOption({super.hidden});
}

class CmsUrlField extends CmsField {
  const CmsUrlField({
    required super.name,
    required super.title,
    super.description,
    required CmsUrlOption super.option,
  });

  @override
  CmsUrlOption get option => super.option as CmsUrlOption;
}

class CmsUrlFieldConfig extends CmsFieldConfig {
  const CmsUrlFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsUrlOption super.option = const CmsUrlOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [Uri];
}
