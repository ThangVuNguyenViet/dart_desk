import 'package:flutter/material.dart';

import 'palette.dart';

/// Extra accent tokens that don't fit shadcn_ui's fixed ColorScheme roles.
///
/// Read via `context.dartDeskPalette.<field>`. Registered on the Flutter
/// `ThemeData` passed through `ShadApp.materialThemeBuilder`.
@immutable
class DartDeskPalette extends ThemeExtension<DartDeskPalette> {
  const DartDeskPalette({
    required this.accentHover,
    required this.accentTint,
    required this.accentTintBorder,
    required this.accentText,
  });

  final Color accentHover;
  final Color accentTint;
  final Color accentTintBorder;
  final Color accentText;

  static const DartDeskPalette dark = DartDeskPalette(
    accentHover: DartDeskColors.darkAccentHover,
    accentTint: DartDeskColors.darkAccentTint,
    accentTintBorder: DartDeskColors.darkAccentTintBorder,
    accentText: DartDeskColors.darkAccentText,
  );

  static const DartDeskPalette light = DartDeskPalette(
    accentHover: DartDeskColors.lightAccentHover,
    accentTint: DartDeskColors.lightAccentTint,
    accentTintBorder: DartDeskColors.lightAccentTintBorder,
    accentText: DartDeskColors.lightAccentText,
  );

  @override
  DartDeskPalette copyWith({
    Color? accentHover,
    Color? accentTint,
    Color? accentTintBorder,
    Color? accentText,
  }) {
    return DartDeskPalette(
      accentHover: accentHover ?? this.accentHover,
      accentTint: accentTint ?? this.accentTint,
      accentTintBorder: accentTintBorder ?? this.accentTintBorder,
      accentText: accentText ?? this.accentText,
    );
  }

  @override
  DartDeskPalette lerp(ThemeExtension<DartDeskPalette>? other, double t) {
    if (other is! DartDeskPalette) return this;
    return DartDeskPalette(
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      accentTintBorder: Color.lerp(accentTintBorder, other.accentTintBorder, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
    );
  }
}

extension DartDeskPaletteX on BuildContext {
  /// Returns the [DartDeskPalette] registered on the ambient [Theme].
  DartDeskPalette get dartDeskPalette =>
      Theme.of(this).extension<DartDeskPalette>()!;
}
