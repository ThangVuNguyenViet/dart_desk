import 'dart:async';

import 'package:flutter/widgets.dart';

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
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  FutureOr<T?>? get defaultValue;
  String? get placeholder;
  bool get allowNull;

  const CmsDropdownOption({super.hidden});
}

class CmsDropdownSimpleOption<T> extends CmsDropdownOption<T> {
  final List<DropdownOption<T>> _options;

  @override
  FutureOr<List<DropdownOption<T>>> options(BuildContext context) => _options;

  @override
  final T? defaultValue;
  @override
  final String? placeholder;
  @override
  final bool allowNull;

  const CmsDropdownSimpleOption({
    super.hidden,
    required List<DropdownOption<T>> options,
    this.defaultValue,
    this.placeholder,
    this.allowNull = true,
  }) : _options = options;
}

class CmsDropdownField<T> extends CmsField {
  const CmsDropdownField({
    required super.name,
    required super.title,
    super.description,
    required CmsDropdownOption<T> super.option,
  });

  @override
  CmsDropdownOption<T>? get option => super.option as CmsDropdownOption<T>?;
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

/// Abstract option class for multi-select dropdown fields.
abstract class CmsMultiDropdownOption<T> extends CmsOption {
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  List<T>? get defaultValues;
  String? get placeholder;
  int? get minSelected;
  int? get maxSelected;

  const CmsMultiDropdownOption({super.hidden});
}

/// Simple multi-dropdown option with static options list.
class CmsMultiDropdownSimpleOption<T> extends CmsMultiDropdownOption<T> {
  final List<DropdownOption<T>> _options;

  @override
  FutureOr<List<DropdownOption<T>>> options(BuildContext context) => _options;

  @override
  final List<T>? defaultValues;
  @override
  final String? placeholder;
  @override
  final int? minSelected;
  @override
  final int? maxSelected;

  const CmsMultiDropdownSimpleOption({
    super.hidden,
    required List<DropdownOption<T>> options,
    this.defaultValues,
    this.placeholder,
    this.minSelected,
    this.maxSelected,
  }) : _options = options;
}

/// A multi-select dropdown field that stores List<T> values.
class CmsMultiDropdownField<T> extends CmsField {
  const CmsMultiDropdownField({
    required super.name,
    required super.title,
    super.description,
    required CmsMultiDropdownOption<T> super.option,
  });

  @override
  CmsMultiDropdownOption<T>? get option =>
      super.option as CmsMultiDropdownOption<T>?;
}
