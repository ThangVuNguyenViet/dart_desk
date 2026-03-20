import '../base/field.dart';

class CmsGeopointOption extends CmsOption {
  const CmsGeopointOption();
}

class CmsGeopointField extends CmsField {
  const CmsGeopointField({
    required super.name,
    required super.title,
    required CmsGeopointOption super.option,
  });

  @override
  CmsGeopointOption get option => super.option as CmsGeopointOption;
}

class CmsGeopointFieldConfig extends CmsFieldConfig {
  const CmsGeopointFieldConfig({
    super.name,
    super.title,
    CmsGeopointOption super.option = const CmsGeopointOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [Object]; // Represents a geographical point
}
