import 'package:flutter/material.dart';
import '../base/field.dart';

/// Option class for color field configuration
class CmsColorOption extends CmsOption {
  /// Whether to show alpha/opacity slider
  final bool showAlpha;

  /// List of preset colors to show in the picker
  final List<Color>? presetColors;

  /// Whether the color field is optional (can be null/unset)
  final bool optional;

  const CmsColorOption({
    this.showAlpha = false,
    this.presetColors,
    this.optional = false,
    super.hidden,
  });
}

/// Color picker field for selecting colors with hex values
class CmsColorField extends CmsField {
  const CmsColorField({
    required super.name,
    required super.title,
    super.description,
    CmsColorOption super.option = const CmsColorOption(),
  });

  @override
  CmsColorOption get option => (super.option as CmsColorOption?) ?? const CmsColorOption();
}

/// Configuration annotation for color fields
class CmsColorFieldConfig extends CmsFieldConfig {
  /// Whether the color field is optional (can be null/unset).
  /// Convenience param that sets [CmsColorOption.optional] = true when no
  /// explicit [option] is provided.
  final bool optional;

  const CmsColorFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsColorOption super.option = const CmsColorOption(),
    this.optional = false,
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Stored as hex string
}
