import '../base/field.dart';

class CmsFileOption extends CmsOption {
  final bool optional;

  const CmsFileOption({this.optional = false, super.hidden});
}

class CmsFileField extends CmsField {
  const CmsFileField({
    required super.name,
    required super.title,
    super.description,
    CmsFileOption super.option = const CmsFileOption(),
  });

  @override
  CmsFileOption get option =>
      (super.option as CmsFileOption?) ?? const CmsFileOption();
}

class CmsFileFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsFileFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsFileOption super.option = const CmsFileOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Assuming file is represented by a URL string
}
