import '../base/field.dart';

class CmsBlockOption extends CmsOption {
  const CmsBlockOption();
}

class CmsBlockField extends CmsField {
  const CmsBlockField({
    required super.name,
    required super.title,
    required CmsBlockOption super.option,
  });

  @override
  CmsBlockOption get option => super.option as CmsBlockOption;
}

class CmsBlockFieldConfig extends CmsFieldConfig {
  const CmsBlockFieldConfig({
    super.name,
    super.title,
    CmsBlockOption super.option = const CmsBlockOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [Object]; // Blocks can contain various types
}
