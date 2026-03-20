import '../base/field.dart';

class CmsFileOption extends CmsOption {
  const CmsFileOption();
}

class CmsFileField extends CmsField {
  const CmsFileField({
    required super.name,
    required super.title,
    super.description,
    required CmsFileOption super.option,
  });

  @override
  CmsFileOption get option => super.option as CmsFileOption;
}

class CmsFileFieldConfig extends CmsFieldConfig {
  const CmsFileFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsFileOption super.option = const CmsFileOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Assuming file is represented by a URL string
}
