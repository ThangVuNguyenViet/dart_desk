import 'package:flutter/material.dart';
import 'package:golden_bricks/golden_bricks.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A [ShadThemeData] whose text theme uses the GoldenBricks font, so any text
/// rendered under this theme produces deterministic-rectangle glyphs.
///
/// Used by golden tests to escape host-specific font rasterization
/// (CoreText on macOS vs FreeType on Linux) without losing real-text-ish
/// sizing the way Ahem would.
///
/// ```dart
/// // Inputs (own ShadApp):
/// ShadApp(theme: goldenBricksTheme(), home: ...);
/// // Whole app (DartDeskApp accepts a ShadThemeData? theme):
/// DartDeskApp.withDataSource(theme: goldenBricksTheme(), ...);
/// ```
ShadThemeData goldenBricksTheme({Brightness brightness = Brightness.light}) {
  return ShadThemeData(
    brightness: brightness,
    colorScheme: brightness == Brightness.light
        ? const ShadSlateColorScheme.light()
        : const ShadSlateColorScheme.dark(),
    textTheme: ShadTextTheme(family: goldenBricks),
  );
}
