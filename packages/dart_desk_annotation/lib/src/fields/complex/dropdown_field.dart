import 'dart:async';

import '../base/field.dart';

/// Represents a dropdown option with a label and value
class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({required this.value, required this.label});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownOption<T> &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode => value.hashCode ^ label.hashCode;
}

abstract class CmsDropdownOption<T> extends CmsOption {
  FutureOr<List<DropdownOption<T>>> get options;
  FutureOr<T?>? get defaultValue;
  String? get placeholder;
  bool get allowNull;

  const CmsDropdownOption({super.hidden});
}

class CmsDropdownSimpleOption<T> extends CmsDropdownOption<T> {
  @override
  final List<DropdownOption<T>> options;
  @override
  final T? defaultValue;
  @override
  final String? placeholder;
  @override
  final bool allowNull;

  const CmsDropdownSimpleOption({
    super.hidden,
    required this.options,
    this.defaultValue,
    this.placeholder,
    this.allowNull = true,
  });
}

class CmsDropdownField<T> extends CmsField {
  const CmsDropdownField({
    required super.name,
    required super.title,
    super.description,
    required CmsDropdownOption<T> super.option,
  });

  @override
  CmsDropdownOption<T> get option => super.option as CmsDropdownOption<T>;
}

class CmsDropdownFieldConfig<T> extends CmsFieldConfig {
  const CmsDropdownFieldConfig({
    super.name,
    super.title,
    super.description,
    required CmsDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [T];
}
