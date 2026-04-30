import '../base/field.dart';

class DeskGeopointOption extends DeskOption {
  const DeskGeopointOption({super.condition});
}

class DeskGeopointField extends DeskField {
  const DeskGeopointField({
    required super.name,
    required super.title,
    DeskGeopointOption super.option = const DeskGeopointOption(),
  });

  @override
  DeskGeopointOption get option =>
      (super.option as DeskGeopointOption?) ?? const DeskGeopointOption();
}

class DeskGeopoint extends DeskFieldConfig {
  const DeskGeopoint({
    super.name,
    super.title,
    DeskGeopointOption super.option = const DeskGeopointOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [Object]; // Represents a geographical point
}
