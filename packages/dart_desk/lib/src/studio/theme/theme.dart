/// Dart Desk Studio Theme
///
/// Provides theme configuration for the CMS studio interface
library;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

export 'spacing.dart';

/// Default theme for the CMS studio (dark)
ShadThemeData get cmsStudioTheme => ShadThemeData(
  brightness: Brightness.dark,
  colorScheme: const ShadStoneColorScheme.dark(),
);

/// Light theme for the CMS studio
ShadThemeData get cmsStudioLightTheme => ShadThemeData(
  brightness: Brightness.light,
  colorScheme: const ShadStoneColorScheme.light(),
);
