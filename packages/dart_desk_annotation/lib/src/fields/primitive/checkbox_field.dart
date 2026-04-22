import '../base/field.dart';

class DeskCheckboxOption extends DeskOption {
  final String? label;
  final bool initialValue;

  const DeskCheckboxOption({
    super.hidden,
    this.label,
    this.initialValue = false,
  });
}

class DeskCheckboxField extends DeskField {
  const DeskCheckboxField({
    required super.name,
    required super.title,
    super.description,
    DeskCheckboxOption super.option = const DeskCheckboxOption(),
  });

  @override
  DeskCheckboxOption get option =>
      (super.option as DeskCheckboxOption?) ?? const DeskCheckboxOption();
}

class DeskCheckbox extends DeskFieldConfig {
  const DeskCheckbox({
    super.name,
    super.title,
    super.description,
    DeskCheckboxOption super.option = const DeskCheckboxOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [bool];
}
