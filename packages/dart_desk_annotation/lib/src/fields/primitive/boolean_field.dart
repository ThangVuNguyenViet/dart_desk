import '../base/field.dart';

class CmsBooleanOption extends CmsOption {
  const CmsBooleanOption({super.hidden});
}

class CmsBooleanField extends CmsField {
  const CmsBooleanField({
    required super.name,
    required super.title,
    super.description,
    required CmsBooleanOption super.option,
  });

  @override
  CmsBooleanOption get option => super.option as CmsBooleanOption;
}

class CmsBooleanFieldConfig extends CmsFieldConfig {
  const CmsBooleanFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsBooleanOption super.option = const CmsBooleanOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [bool];
}
