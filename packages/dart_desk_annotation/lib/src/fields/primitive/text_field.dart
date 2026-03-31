import '../base/field.dart';
import '../../validators/validators.dart';

class CmsTextOption extends CmsOption {
  final int rows;
  final CmsValidator? validation;
  final String? initialValue;
  final bool readOnly;
  final String? deprecatedReason;
  /// Whether the text field is optional (can be null/unset).
  final bool optional;

  const CmsTextOption({
    this.rows = 1,
    super.hidden,
    this.validation,
    this.initialValue,
    this.readOnly = false,
    this.deprecatedReason,
    this.optional = false,
  });
}

class CmsTextField extends CmsField {
  const CmsTextField({
    required super.name,
    required super.title,
    super.description,
    CmsTextOption? super.option,
  });

  @override
  CmsTextOption get option => (super.option as CmsTextOption?) ?? const CmsTextOption();
}

class CmsTextFieldConfig extends CmsFieldConfig {
  /// Convenience param that sets [CmsTextOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const CmsTextFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsTextOption? super.option,
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String];
}
