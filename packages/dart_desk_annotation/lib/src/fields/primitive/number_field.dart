import '../base/field.dart';
import '../../validators/validators.dart';

class CmsNumberOption extends CmsOption {
  final CmsValidator? validation;
  final double? min;
  final double? max;

  const CmsNumberOption({this.validation, this.min, this.max, super.hidden});
}

class CmsNumberField extends CmsField {
  const CmsNumberField({
    required super.name,
    required super.title,
    super.description,
    required CmsNumberOption super.option,
  });

  @override
  CmsNumberOption get option => super.option as CmsNumberOption;
}

class CmsNumberFieldConfig extends CmsFieldConfig {
  const CmsNumberFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsNumberOption super.option = const CmsNumberOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [num];
}
