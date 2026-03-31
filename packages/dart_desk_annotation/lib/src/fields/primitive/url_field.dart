import '../base/field.dart';

class CmsUrlOption extends CmsOption {
  final bool optional;

  const CmsUrlOption({this.optional = false, super.hidden});
}

class CmsUrlField extends CmsField {
  const CmsUrlField({
    required super.name,
    required super.title,
    super.description,
    CmsUrlOption super.option = const CmsUrlOption(),
  });

  @override
  CmsUrlOption get option => (super.option as CmsUrlOption?) ?? const CmsUrlOption();
}

class CmsUrlFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsUrlFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsUrlOption super.option = const CmsUrlOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [Uri];
}
