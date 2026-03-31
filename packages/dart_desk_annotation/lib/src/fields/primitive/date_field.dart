import '../base/field.dart';

class CmsDateOption extends CmsOption {
  final bool optional;

  const CmsDateOption({this.optional = false, super.hidden});
}

class CmsDateField extends CmsField {
  const CmsDateField({
    required super.name,
    required super.title,
    super.description,
    CmsDateOption super.option = const CmsDateOption(),
  });

  @override
  CmsDateOption get option =>
      (super.option as CmsDateOption?) ?? const CmsDateOption();
}

class CmsDateFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsDateFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsDateOption super.option = const CmsDateOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [DateTime];
}
