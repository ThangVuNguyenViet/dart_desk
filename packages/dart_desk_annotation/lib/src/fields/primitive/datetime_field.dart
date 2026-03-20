import '../base/field.dart';

class CmsDateTimeOption extends CmsOption {
  const CmsDateTimeOption({super.hidden});
}

class CmsDateTimeField extends CmsField {
  const CmsDateTimeField({
    required super.name,
    required super.title,
    super.description,
    required CmsDateTimeOption super.option,
  });

  @override
  CmsDateTimeOption get option => super.option as CmsDateTimeOption;
}

class CmsDateTimeFieldConfig extends CmsFieldConfig {
  const CmsDateTimeFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsDateTimeOption super.option = const CmsDateTimeOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [DateTime];
}
