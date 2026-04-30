import '../base/field.dart';

class DeskStringOption extends DeskOption {
  const DeskStringOption({super.optional, super.hidden, super.condition});
}

class DeskStringField extends DeskField {
  const DeskStringField({
    required super.name,
    required super.title,
    super.description,
    DeskStringOption super.option = const DeskStringOption(),
  });

  @override
  DeskStringOption get option =>
      (super.option as DeskStringOption?) ?? const DeskStringOption();
}

class DeskString extends DeskFieldConfig {
  /// Convenience param that sets [DeskStringOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskString({
    super.name,
    super.title,
    super.description,
    DeskStringOption super.option = const DeskStringOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String];
}
