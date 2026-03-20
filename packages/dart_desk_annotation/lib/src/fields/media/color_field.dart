import 'package:flutter/material.dart';
import '../base/field.dart';

/// Option class for color field configuration
class CmsColorOption extends CmsOption {
  /// Whether to show alpha/opacity slider
  final bool showAlpha;

  /// List of preset colors to show in the picker
  final List<Color>? presetColors;

  const CmsColorOption({
    this.showAlpha = false,
    this.presetColors,
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
  CmsColorOption get option => super.option as CmsColorOption;
}

/// Configuration annotation for color fields
class CmsColorFieldConfig extends CmsFieldConfig {
  const CmsColorFieldConfig({
    super.name,
    super.title,
    super.description,
    CmsColorOption super.option = const CmsColorOption(),
  });

  @override
  List<Type> get supportedFieldTypes => [String]; // Stored as hex string
}
