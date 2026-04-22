import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/spacing.dart';

/// A full-width collapse/expand bar with a chevron icon and optional label.
class DeskCollapseBar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const DeskCollapseBar({
    super.key,
    this.isCollapsed = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onToggle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: DeskSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              FaIcon(
                isCollapsed
                    ? FontAwesomeIcons.anglesRight
                    : FontAwesomeIcons.anglesLeft,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: DeskSpacing.sm),
                Text(
                  'Collapse',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
