import '../base/field.dart';

class DeskBlockOption extends DeskOption {
  const DeskBlockOption({super.optional, super.visibleWhen});
}

class DeskBlockField extends DeskField {
  const DeskBlockField({
    required super.name,
    required super.title,
    DeskBlockOption super.option = const DeskBlockOption(),
  });

  @override
  DeskBlockOption get option =>
      (super.option as DeskBlockOption?) ?? const DeskBlockOption();
}

class DeskBlock extends DeskFieldConfig {
  const DeskBlock({
    super.name,
    super.title,
    DeskBlockOption super.option = const DeskBlockOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [Object]; // Blocks can contain various types
}
