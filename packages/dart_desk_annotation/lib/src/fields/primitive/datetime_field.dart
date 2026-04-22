import '../base/field.dart';

class DeskDateTimeOption extends DeskOption {
  const DeskDateTimeOption({super.optional, super.hidden});
}

class DeskDateTimeField extends DeskField {
  const DeskDateTimeField({
    required super.name,
    required super.title,
    super.description,
    DeskDateTimeOption super.option = const DeskDateTimeOption(),
  });

  @override
  DeskDateTimeOption get option =>
      (super.option as DeskDateTimeOption?) ?? const DeskDateTimeOption();
}

class DeskDateTime extends DeskFieldConfig {
  /// Convenience param that sets [DeskDateTimeOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskDateTime({
    super.name,
    super.title,
    super.description,
    DeskDateTimeOption super.option = const DeskDateTimeOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [DateTime];
}
