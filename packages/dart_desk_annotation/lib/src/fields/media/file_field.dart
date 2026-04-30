import '../base/field.dart';

class DeskFileOption extends DeskOption {
  const DeskFileOption({super.optional, super.hidden, super.condition});
}

class DeskFileField extends DeskField {
  const DeskFileField({
    required super.name,
    required super.title,
    super.description,
    DeskFileOption super.option = const DeskFileOption(),
  });

  @override
  DeskFileOption get option =>
      (super.option as DeskFileOption?) ?? const DeskFileOption();
}

class DeskFile extends DeskFieldConfig {
  /// Convenience param that sets [DeskFileOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskFile({
    super.name,
    super.title,
    super.description,
    DeskFileOption super.option = const DeskFileOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Assuming file is represented by a URL string
}
