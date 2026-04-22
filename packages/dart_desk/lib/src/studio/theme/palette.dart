import 'package:flutter/painting.dart';

/// Raw color constants for the Dart Desk editorial theme.
///
/// Internal — consumers should read colors through
/// `ShadTheme.of(context).colorScheme` or `context.dartDeskPalette`.
abstract final class DartDeskColors {
  // --- Dark (canonical) ---
  static const Color darkBackground = Color(0xFF0A0A09);
  static const Color darkCard = Color(0xFF0E0D0A);
  static const Color darkPopover = Color(0xFF0B0A08);
  static const Color darkForeground = Color(0xFFF4EFE6);
  static const Color darkMutedForeground = Color(0xFF8A8378);
  static const Color darkBorder = Color(0xFF262320);
  static const Color darkInput = Color(0xFF262320);
  static const Color darkRing = Color(0xFFD4C9B6);
  static const Color darkPrimary = Color(0xFFF4EFE6);
  static const Color darkPrimaryForeground = Color(0xFF1A1611);
  static const Color darkAccent = Color(0xFFC6F24E);
  static const Color darkAccentForeground = Color(0xFF0A0A09);
  static const Color darkAccentHover = Color(0xFFD8E85C);
  static const Color darkAccentTint = Color(0x1AC6F24E);
  static const Color darkAccentTintBorder = Color(0x52C6F24E);
  static const Color darkAccentText = Color(0xFFB6DD46);
  static const Color darkDestructive = Color(0xFFEF4444);

  // --- Light ---
  static const Color lightBackground = Color(0xFFF7F3EA);
  static const Color lightCard = Color(0xFFFDFAF2);
  static const Color lightPopover = Color(0xFFFFFDF6);
  static const Color lightForeground = Color(0xFF1A1611);
  static const Color lightMutedForeground = Color(0xFF6B6358);
  static const Color lightBorder = Color(0xFFE2DBC9);
  static const Color lightInput = Color(0xFFE2DBC9);
  static const Color lightRing = Color(0xFF1A1611);
  static const Color lightPrimary = Color(0xFF1A1611);
  static const Color lightPrimaryForeground = Color(0xFFF4EFE6);
  static const Color lightAccent = Color(0xFFC6F24E);
  static const Color lightAccentForeground = Color(0xFF1A1611);
  static const Color lightAccentHover = Color(0xFFB8E43E);
  static const Color lightAccentTint = Color(0x24C6F24E);
  static const Color lightAccentTintBorder = Color(0x70C6F24E);
  static const Color lightAccentText = Color(0xFF7C9A1E);
  static const Color lightDestructive = Color(0xFFDC2626);
}
