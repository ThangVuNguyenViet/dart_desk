import '../base/field.dart';
import '../../validators/validators.dart';

class DeskNumberOption extends DeskOption {
  final DeskValidator? validation;
  final double? min;
  final double? max;

  const DeskNumberOption({
    this.validation,
    this.min,
    this.max,
    super.optional,
    super.visibleWhen,
  });
}

class DeskNumberField extends DeskField {
  const DeskNumberField({
    required super.name,
    required super.title,
    super.description,
    DeskNumberOption super.option = const DeskNumberOption(),
  });

  @override
  DeskNumberOption get option =>
      (super.option as DeskNumberOption?) ?? const DeskNumberOption();
}

class DeskNumber extends DeskFieldConfig {
  /// Convenience param that sets [DeskNumberOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskNumber({
    super.name,
    super.title,
    super.description,
    DeskNumberOption super.option = const DeskNumberOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [num];
}
