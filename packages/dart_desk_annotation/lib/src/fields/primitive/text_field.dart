import '../base/field.dart';
import '../../validators/validators.dart';

class DeskTextOption extends DeskOption {
  final int rows;
  final DeskValidator? validation;
  final String? initialValue;
  final bool readOnly;
  final String? deprecatedReason;

  const DeskTextOption({
    this.rows = 1,
    super.hidden,
    this.validation,
    this.initialValue,
    this.readOnly = false,
    this.deprecatedReason,
    super.optional,
    super.condition,
  });
}

class DeskTextField extends DeskField {
  const DeskTextField({
    required super.name,
    required super.title,
    super.description,
    DeskTextOption? super.option,
  });

  @override
  DeskTextOption get option =>
      (super.option as DeskTextOption?) ?? const DeskTextOption();
}

class DeskText extends DeskFieldConfig {
  /// Convenience param that sets [DeskTextOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskText({
    super.name,
    super.title,
    super.description,
    DeskTextOption? super.option,
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String];
}
