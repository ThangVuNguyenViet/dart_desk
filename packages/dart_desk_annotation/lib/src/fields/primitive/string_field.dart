import '../base/field.dart';

class CmsStringOption extends CmsOption {
  final bool optional;

  const CmsStringOption({this.optional = false, super.hidden});
}

class CmsStringField extends CmsField {
  const CmsStringField({
    required super.name,
    required super.title,
    super.description,
    CmsStringOption super.option = const CmsStringOption(),
  });

  @override
  CmsStringOption get option =>
      (super.option as CmsStringOption?) ?? const CmsStringOption();
}

class CmsStringFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsStringFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsStringOption super.option = const CmsStringOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String];
}
