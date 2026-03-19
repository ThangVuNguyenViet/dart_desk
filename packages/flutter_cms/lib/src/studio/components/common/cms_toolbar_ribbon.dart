// flutter_cms/packages/flutter_cms/lib/src/studio/components/common/cms_toolbar_ribbon.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/document_version.dart';
import '../../theme/spacing.dart';
import 'cms_status_pill.dart';

/// Toolbar ribbon below the top bar with panel toggles, status, and document actions.
///
/// **Left section:** Sidebar toggle, List toggle, separator, status pill, timestamp.
/// **Right section:** Discard and Save buttons (visible when document has unsaved changes).
class CmsToolbarRibbon extends StatelessWidget {
  final bool sidebarVisible;
  final VoidCallback onToggleSidebar;
  final bool listVisible;
  final VoidCallback onToggleList;
  final DocumentVersionStatus? documentStatus;
  final String? lastSavedText;
  final bool hasUnsavedChanges;
  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;
  const CmsToolbarRibbon({
    super.key,
    required this.sidebarVisible,
    required this.onToggleSidebar,
    required this.listVisible,
    required this.onToggleList,
    this.documentStatus,
    this.lastSavedText,
    this.hasUnsavedChanges = false,
    this.isSaving = false,
    this.onSave,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: CmsSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Left section: panel toggles + status
          _PanelToggleButton(
            icon: FontAwesomeIcons.bars,
            label: 'Sidebar',
            isActive: sidebarVisible,
            onTap: onToggleSidebar,
            theme: theme,
          ),
          const SizedBox(width: CmsSpacing.sm),
          _PanelToggleButton(
            icon: FontAwesomeIcons.rectangleList,
            label: 'List',
            isActive: listVisible,
            onTap: onToggleList,
            theme: theme,
          ),
          if (documentStatus != null) ...[
            const SizedBox(width: CmsSpacing.sm),
            Container(
              width: 1,
              height: 16,
              color: theme.colorScheme.border,
            ),
            const SizedBox(width: CmsSpacing.sm),
            CmsStatusPill(
              status: documentStatus!,
              hasUnsavedChanges: hasUnsavedChanges,
            ),
            if (lastSavedText != null) ...[
              const SizedBox(width: CmsSpacing.sm),
              Text(
                '· $lastSavedText',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
          const Spacer(),

          // Right section: document actions
          if (hasUnsavedChanges) ...[
            ShadButton.outline(
              key: const ValueKey('discard_button'),
              size: ShadButtonSize.sm,
              height: 28,
              onPressed: isSaving ? null : onDiscard,
              child: const Text('Discard'),
            ),
            const SizedBox(width: CmsSpacing.sm),
            ShadButton(
              key: const ValueKey('save_button'),
              size: ShadButtonSize.sm,
              height: 28,
              onPressed: isSaving ? null : onSave,
              child: Text(isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ShadThemeData theme;

  const _PanelToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
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
          padding: const EdgeInsets.symmetric(
            horizontal: CmsSpacing.sm,
            vertical: CmsSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: BorderRadius.circular(CmsBorderRadius.sm),
            color: isActive
                ? theme.colorScheme.muted.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: 10,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: CmsSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
