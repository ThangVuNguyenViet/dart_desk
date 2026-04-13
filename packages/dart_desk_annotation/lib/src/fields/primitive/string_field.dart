import '../base/field.dart';

class CmsStringOption extends CmsOption {
  const CmsStringOption({super.optional, super.hidden});
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
  /// Convenience param that sets [CmsStringOption.optional] = true when no
  /// explicit [option] is provided.
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
