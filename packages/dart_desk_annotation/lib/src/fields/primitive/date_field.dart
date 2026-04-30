import '../base/field.dart';

class DeskDateOption extends DeskOption {
  const DeskDateOption({super.optional, super.visibleWhen});
}

class DeskDateField extends DeskField {
  const DeskDateField({
    required super.name,
    required super.title,
    super.description,
    DeskDateOption super.option = const DeskDateOption(),
  });

  @override
  DeskDateOption get option =>
      (super.option as DeskDateOption?) ?? const DeskDateOption();
}

class DeskDate extends DeskFieldConfig {
  /// Convenience param that sets [DeskDateOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskDate({
    super.name,
    super.title,
    super.description,
    DeskDateOption super.option = const DeskDateOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [DateTime];
}
