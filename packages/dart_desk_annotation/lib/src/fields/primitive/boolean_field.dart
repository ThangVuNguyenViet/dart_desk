import '../base/field.dart';

class DeskBooleanOption extends DeskOption {
  const DeskBooleanOption({super.hidden, super.optional});
}

class DeskBooleanField extends DeskField {
  const DeskBooleanField({
    required super.name,
    required super.title,
    super.description,
    DeskBooleanOption super.option = const DeskBooleanOption(),
  });

  @override
  DeskBooleanOption get option =>
      (super.option as DeskBooleanOption?) ?? const DeskBooleanOption();
}

class DeskBoolean extends DeskFieldConfig {
  const DeskBoolean({
    super.name,
    super.title,
    super.description,
    DeskBooleanOption super.option = const DeskBooleanOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [bool];
}
