import 'dart:async';

import 'package:flutter/widgets.dart';

import '../base/field.dart';
import 'dropdown_field.dart';

/// Annotation to mark a `List<T>` field as a multi-select dropdown in the CMS.
///
/// Requires a [CmsMultiDropdownOption<T>] to supply the available options.
class CmsMultiDropdownFieldConfig<T> extends CmsFieldConfig {
  const CmsMultiDropdownFieldConfig({
    super.name,
    super.title,
    super.description,
    required CmsMultiDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List<T>];
}

/// Abstract option class for multi-select dropdown fields.
abstract class CmsMultiDropdownOption<T> extends CmsOption {
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  List<T>? get defaultValues;
  String? get placeholder;
  int? get minSelected;
  int? get maxSelected;

  const CmsMultiDropdownOption({super.hidden});

  /// Convert a raw stored value to [T]. Override for complex types;
  /// the default works for primitives where the stored form is already [T].
  T fromDynamic(dynamic value) => value as T;
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
