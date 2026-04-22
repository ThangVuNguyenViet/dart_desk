import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/document_version.dart';
import '../../theme/spacing.dart';
import 'status_palette.dart';

/// A small colored pill showing document/version status.
///
/// Displays a dot prefix + status label with color coding:
/// - Published: green
/// - Draft: yellow/amber
/// - Changed (unsaved): blue
/// - Archived: gray
/// - Scheduled: purple
class CmsStatusPill extends StatelessWidget {
  final DocumentVersionStatus status;
  final bool hasUnsavedChanges;

  const CmsStatusPill({
    super.key,
    required this.status,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    StatusColors colors;
    String label;

    if (hasUnsavedChanges) {
      colors = StatusPalette.info;
      label = 'changed';
    } else {
      switch (status) {
        case DocumentVersionStatus.published:
          colors = StatusPalette.success;
          label = 'published';
        case DocumentVersionStatus.draft:
          colors = StatusPalette.warning;
          label = 'draft';
        case DocumentVersionStatus.archived:
          return _buildPill(
            bg: theme.colorScheme.muted.withValues(alpha: 0.3),
            fg: theme.colorScheme.mutedForeground,
            label: 'archived',
          );
        case DocumentVersionStatus.scheduled:
          colors = StatusPalette.special;
          label = 'scheduled';
      }
    }

    return _buildPill(
      bg: isDark ? colors.darkBg : colors.lightBg,
      fg: isDark ? colors.darkFg : colors.lightFg,
      label: label,
    );
  }

  Widget _buildPill({
    required Color bg,
    required Color fg,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(CmsBorderRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: CmsSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
