import 'package:flutter/material.dart';
import '../base/field.dart';

/// Option class for color field configuration
class DeskColorOption extends DeskOption {
  /// Whether to show alpha/opacity slider
  final bool showAlpha;

  /// List of preset colors to show in the picker
  final List<Color>? presetColors;

  const DeskColorOption({
    this.showAlpha = false,
    this.presetColors,
    super.optional,
    super.hidden,
  });
}

/// Color picker field for selecting colors with hex values
class DeskColorField extends DeskField {
  const DeskColorField({
    required super.name,
    required super.title,
    super.description,
    DeskColorOption super.option = const DeskColorOption(),
  });

  @override
  DeskColorOption get option =>
      (super.option as DeskColorOption?) ?? const DeskColorOption();
}

/// Configuration annotation for color fields
class DeskColor extends DeskFieldConfig {
  /// Whether the color field is optional (can be null/unset).
  /// Convenience param that sets [DeskColorOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const DeskColor({
    super.name,
    super.title,
    super.description,
    DeskColorOption super.option = const DeskColorOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Stored as hex string
}
