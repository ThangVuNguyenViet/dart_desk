import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import 'aura_tokens.dart';

/// Wrap screens in the Aura Material theme + [AuraTokens].
class AuraTheme {
  /// Build a Material 3 [ThemeData] from [theme].
  static ThemeData dataFor(BrandTheme theme) {
    final scheme = ColorScheme.fromSeed(
      seedColor: theme.primaryColor,
      primary: theme.primaryColor,
      surface: theme.surfaceColor,
      onSurface: theme.inkColor,
      secondary: theme.accentColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: theme.surfaceColor,
      textTheme: _textTheme(theme),
    );
  }

  static TextTheme _textTheme(BrandTheme theme) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      headlineLarge: TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      headlineMedium:TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      titleLarge:    TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      bodyLarge:     TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor),
      bodyMedium:    TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor),
      labelLarge:    TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor, fontWeight: FontWeight.w600),
    );
  }

  /// Wrap a subtree in both the [Theme] and [AuraTokens].
  static Widget wrap(BrandTheme theme, {required Widget child}) {
    return Theme(
      data: dataFor(theme),
      child: AuraTokens(
        creamWarm: _shift(theme.surfaceColor, -0.04),
        inkSoft:   _shift(theme.inkColor, 0.25),
        mute:      _shift(theme.inkColor, 0.45),
        line:      theme.inkColor.withValues(alpha: 0.10),
        greenDark: _shift(theme.primaryColor, -0.12),
        child: child,
      ),
    );
  }

  static Color _shift(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
