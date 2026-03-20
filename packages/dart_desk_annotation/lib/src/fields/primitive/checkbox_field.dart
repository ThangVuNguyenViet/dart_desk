import '../base/field.dart';

class CmsCheckboxOption extends CmsOption {
  final String? label;
  final bool initialValue;

  const CmsCheckboxOption({
    super.hidden,
    this.label,
    this.initialValue = false,
  });
}

class CmsCheckboxField extends CmsField {
  const CmsCheckboxField({
    required super.name,
    required super.title,
    super.description,
    required CmsCheckboxOption super.option,
  });

  @override
  CmsCheckboxOption get option => super.option as CmsCheckboxOption;
}

class CmsCheckboxFieldConfig extends CmsFieldConfig {
  const CmsCheckboxFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsCheckboxOption super.option = const CmsCheckboxOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [bool];
}
