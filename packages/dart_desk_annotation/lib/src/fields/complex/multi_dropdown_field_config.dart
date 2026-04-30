import 'dart:async';

import 'package:flutter/widgets.dart';

import '../base/field.dart';
import 'dropdown_field.dart';

/// Annotation to mark a `List<T>` field as a multi-select dropdown in the CMS.
///
/// Requires a [DeskMultiDropdownOption<T>] to supply the available options.
class DeskMultiDropdown<T> extends DeskFieldConfig {
  const DeskMultiDropdown({
    super.name,
    super.title,
    super.description,
    required DeskMultiDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List<T>];
}

/// Abstract option class for multi-select dropdown fields.
abstract class DeskMultiDropdownOption<T> extends DeskOption {
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  List<T>? get defaultValues;
  String? get placeholder;
  int? get minSelected;
  int? get maxSelected;

  const DeskMultiDropdownOption({super.optional, super.visibleWhen});
}

/// Simple multi-dropdown option with static options list.
class DeskMultiDropdownSimpleOption<T> extends DeskMultiDropdownOption<T> {
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

  const DeskMultiDropdownSimpleOption({
    super.optional,
    super.visibleWhen,
    required List<DropdownOption<T>> options,
    this.defaultValues,
    this.placeholder,
    this.minSelected,
    this.maxSelected,
  }) : _options = options;
}

/// A multi-select dropdown field that stores List<T> values.
class DeskMultiDropdownField<T> extends DeskField {
  const DeskMultiDropdownField({
    required super.name,
    required super.title,
    super.description,
    this.fromMap,
    required DeskMultiDropdownOption<T> super.option,
  });

  /// Converts a raw [Map<String, dynamic>] to [T] for non-primitive multi-dropdown
  /// value types. The model class must provide a static `$fromMap` method.
  final T Function(Map<String, dynamic>)? fromMap;

  @override
  DeskMultiDropdownOption<T>? get option =>
      super.option as DeskMultiDropdownOption<T>?;
}
