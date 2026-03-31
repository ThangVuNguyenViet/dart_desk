import '../base/field.dart';
import '../../validators/validators.dart';

class CmsNumberOption extends CmsOption {
  final CmsValidator? validation;
  final double? min;
  final double? max;
  final bool optional;

  const CmsNumberOption({this.validation, this.min, this.max, super.hidden, this.optional = false});
}

class CmsNumberField extends CmsField {
  const CmsNumberField({
    required super.name,
    required super.title,
    super.description,
    CmsNumberOption super.option = const CmsNumberOption(),
  });

  @override
  CmsNumberOption get option => (super.option as CmsNumberOption?) ?? const CmsNumberOption();
}

class CmsNumberFieldConfig extends CmsFieldConfig {
  final bool optional;

  const CmsNumberFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsNumberOption super.option = const CmsNumberOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [num];
}
