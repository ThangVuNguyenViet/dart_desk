// dart_desk/packages/dart_desk/lib/src/studio/components/common/cms_theme_toggle.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/spacing.dart';

/// A segmented pill toggle for switching between light and dark themes.
///
/// Displays sun/moon icons. The active side has an elevated background.
class CmsThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const CmsThemeToggle({
    super.key,
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(CmsBorderRadius.md),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSegment(
            icon: isDark ? FontAwesomeIcons.sun : FontAwesomeIcons.solidSun,
            isActive: !isDark,
            isSun: true,
            onTap: () => onChanged(ThemeMode.light),
            theme: theme,
          ),
          _ToggleSegment(
            icon: isDark ? FontAwesomeIcons.solidMoon : FontAwesomeIcons.moon,
            isActive: isDark,
            isSun: false,
            onTap: () => onChanged(ThemeMode.dark),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isSun;
  final VoidCallback onTap;
  final ShadThemeData theme;

  const _ToggleSegment({
    required this.icon,
    required this.isActive,
    required this.isSun,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.muted.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(CmsBorderRadius.md),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 12,
              color: isSun
                  ? const Color(0xFFeab308)
                  : isActive
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
