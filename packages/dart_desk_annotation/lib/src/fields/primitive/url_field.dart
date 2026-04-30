import '../base/field.dart';

class DeskUrlOption extends DeskOption {
  const DeskUrlOption({super.optional, super.visibleWhen});
}

class DeskUrlField extends DeskField {
  const DeskUrlField({
    required super.name,
    required super.title,
    super.description,
    DeskUrlOption super.option = const DeskUrlOption(),
  });

  @override
  DeskUrlOption get option =>
      (super.option as DeskUrlOption?) ?? const DeskUrlOption();
}

class DeskUrl extends DeskFieldConfig {
  /// Convenience param that sets [DeskUrlOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskUrl({
    super.name,
    super.title,
    super.description,
    DeskUrlOption super.option = const DeskUrlOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [Uri];
}
