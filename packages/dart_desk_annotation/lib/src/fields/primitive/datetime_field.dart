import '../base/field.dart';

class CmsDateTimeOption extends CmsOption {
  final bool optional;

  const CmsDateTimeOption({this.optional = false, super.hidden});
}

class CmsDateTimeField extends CmsField {
  const CmsDateTimeField({
    required super.name,
    required super.title,
    super.description,
    CmsDateTimeOption super.option = const CmsDateTimeOption(),
  });

  @override
  CmsDateTimeOption get option =>
      (super.option as CmsDateTimeOption?) ?? const CmsDateTimeOption();
}

class CmsDateTimeFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsDateTimeFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsDateTimeOption super.option = const CmsDateTimeOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [DateTime];
}
