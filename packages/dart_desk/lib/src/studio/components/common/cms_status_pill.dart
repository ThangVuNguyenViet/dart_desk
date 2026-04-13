import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/document_version.dart';
import '../../theme/spacing.dart';

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

    final (Color bg, Color fg, String label) = hasUnsavedChanges
        ? (
            isDark
                ? const Color(0xFF3b82f6).withValues(alpha: 0.1)
                : const Color(0xFF3b82f6).withValues(alpha: 0.08),
            isDark ? const Color(0xFF3b82f6) : const Color(0xFF2563eb),
            'changed',
          )
        : switch (status) {
            DocumentVersionStatus.published => (
              isDark
                  ? const Color(0xFF22c55e).withValues(alpha: 0.1)
                  : const Color(0xFF22c55e).withValues(alpha: 0.08),
              isDark ? const Color(0xFF22c55e) : const Color(0xFF16a34a),
              'published',
            ),
            DocumentVersionStatus.draft => (
              isDark
                  ? const Color(0xFFeab308).withValues(alpha: 0.1)
                  : const Color(0xFFeab308).withValues(alpha: 0.08),
              isDark ? const Color(0xFFeab308) : const Color(0xFFb45309),
              'draft',
            ),
            DocumentVersionStatus.archived => (
              theme.colorScheme.muted.withValues(alpha: 0.3),
              theme.colorScheme.mutedForeground,
              'archived',
            ),
            DocumentVersionStatus.scheduled => (
              isDark
                  ? const Color(0xFF8b5cf6).withValues(alpha: 0.1)
                  : const Color(0xFF8b5cf6).withValues(alpha: 0.08),
              isDark ? const Color(0xFF8b5cf6) : const Color(0xFF7c3aed),
              'scheduled',
            ),
          };

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
