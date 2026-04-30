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

abstract class DeskDropdownOption<T> extends DeskOption {
  FutureOr<List<DropdownOption<T>>> options(BuildContext context);
  FutureOr<T?>? get defaultValue;
  String? get placeholder;
  bool get allowNull;

  const DeskDropdownOption({super.hidden, super.condition});
}

class DeskDropdownSimpleOption<T> extends DeskDropdownOption<T> {
  final List<DropdownOption<T>> _options;

  @override
  FutureOr<List<DropdownOption<T>>> options(BuildContext context) => _options;

  @override
  final T? defaultValue;
  @override
  final String? placeholder;
  @override
  final bool allowNull;

  const DeskDropdownSimpleOption({
    super.hidden,
    required List<DropdownOption<T>> options,
    this.defaultValue,
    this.placeholder,
    this.allowNull = true,
  }) : _options = options;
}

class DeskDropdownField<T> extends DeskField {
  const DeskDropdownField({
    required super.name,
    required super.title,
    super.description,
    this.fromMap,
    required DeskDropdownOption<T> super.option,
  });

  /// Converts a raw [Map<String, dynamic>] to [T] for non-primitive dropdown
  /// value types. The model class must provide a static `$fromMap` method.
  final T Function(Map<String, dynamic>)? fromMap;

  @override
  DeskDropdownOption<T>? get option => super.option as DeskDropdownOption<T>?;
}

class DeskDropdown<T> extends DeskFieldConfig {
  const DeskDropdown({
    super.name,
    super.title,
    super.description,
    required DeskDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [T];
}
