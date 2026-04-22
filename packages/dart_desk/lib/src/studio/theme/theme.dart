/// Dart Desk Studio Theme
///
/// Warm-editorial palette for the CMS studio. Dark is canonical; a matching
/// light variant is provided. A single chromatic accent (chartreuse) is used
/// across both modes. Extra accent tokens (hover, tint, tint-border, text)
/// live on `DartDeskPalette` — a `ThemeExtension` wired up in
/// `DeskStudioApp`.
library;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'palette.dart';

export 'dart_desk_palette.dart';
export 'palette.dart' show DartDeskColors;
export 'spacing.dart';

ShadColorScheme _darkScheme() => const ShadColorScheme(
      background: DartDeskColors.darkBackground,
      foreground: DartDeskColors.darkForeground,
      card: DartDeskColors.darkCard,
      cardForeground: DartDeskColors.darkForeground,
      popover: DartDeskColors.darkPopover,
      popoverForeground: DartDeskColors.darkForeground,
      primary: DartDeskColors.darkPrimary,
      primaryForeground: DartDeskColors.darkPrimaryForeground,
      secondary: DartDeskColors.darkCard,
      secondaryForeground: DartDeskColors.darkMutedForeground,
      muted: DartDeskColors.darkCard,
      mutedForeground: DartDeskColors.darkMutedForeground,
      accent: DartDeskColors.darkAccent,
      accentForeground: DartDeskColors.darkAccentForeground,
      destructive: DartDeskColors.darkDestructive,
      destructiveForeground: DartDeskColors.darkForeground,
      border: DartDeskColors.darkBorder,
      input: DartDeskColors.darkInput,
      ring: DartDeskColors.darkRing,
      selection: Color(0x40C6F24E),
    );

ShadColorScheme _lightScheme() => const ShadColorScheme(
      background: DartDeskColors.lightBackground,
      foreground: DartDeskColors.lightForeground,
      card: DartDeskColors.lightCard,
      cardForeground: DartDeskColors.lightForeground,
      popover: DartDeskColors.lightPopover,
      popoverForeground: DartDeskColors.lightForeground,
      primary: DartDeskColors.lightPrimary,
      primaryForeground: DartDeskColors.lightPrimaryForeground,
      secondary: DartDeskColors.lightCard,
      secondaryForeground: DartDeskColors.lightMutedForeground,
      muted: DartDeskColors.lightCard,
      mutedForeground: DartDeskColors.lightMutedForeground,
      accent: DartDeskColors.lightAccent,
      accentForeground: DartDeskColors.lightAccentForeground,
      destructive: DartDeskColors.lightDestructive,
      destructiveForeground: DartDeskColors.lightCard,
      border: DartDeskColors.lightBorder,
      input: DartDeskColors.lightInput,
      ring: DartDeskColors.lightRing,
      selection: Color(0x40C6F24E),
    );

ShadThemeData get deskStudioTheme => ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: _darkScheme(),
    );

ShadThemeData get deskStudioLightTheme => ShadThemeData(
      brightness: Brightness.light,
      colorScheme: _lightScheme(),
    );
