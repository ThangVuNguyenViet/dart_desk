import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/view_models/desk_document_view_model.dart';
import '../../core/view_models/desk_view_model.dart';
import '../../theme/spacing.dart';

/// Autosave / publish-state status pill shown in the document editor.
///
/// Renders one of four states based on the current mutation and change signals:
///
/// | Priority | Condition                          | Label                   |
/// |----------|------------------------------------|-------------------------|
/// | 1        | `updateData.isLoading`             | "Saving…"               |
/// | 2        | `updateData.hasError`              | "Save failed — retry"   |
/// | 3        | `hasUnpublishedChanges`            | "Unpublished changes"   |
/// | 4        | (default)                          | "Saved"                 |
///
/// Resolves both VMs from GetIt so callers need zero constructor args.
class CmsStatusPill extends StatelessWidget {
  const CmsStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    final documentVM = GetIt.I<DeskDocumentViewModel>();
    final viewModel = GetIt.I<DeskViewModel>();

    final saveState = documentVM.updateData.watch(context);
    final hasChanges = viewModel.hasUnpublishedChanges.watch(context);

    if (saveState.isLoading) {
      return const _Pill(
        label: 'Saving…',
        icon: Icons.cloud_upload_outlined,
        variant: _PillVariant.muted,
      );
    }

    if (saveState.hasError) {
      return _Pill(
        label: 'Save failed — retry',
        icon: Icons.error_outline,
        variant: _PillVariant.error,
        onTap: () => documentVM.updateData.reset(),
      );
    }

    if (hasChanges) {
      return const _Pill(
        label: 'Unpublished changes',
        icon: Icons.history,
        variant: _PillVariant.warning,
      );
    }

    return const _Pill(
      label: 'Saved',
      icon: Icons.check_circle_outline,
      variant: _PillVariant.success,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal pill widget
// ---------------------------------------------------------------------------

enum _PillVariant { muted, success, warning, error }

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final _PillVariant variant;
  final VoidCallback? onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.variant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (Color bg, Color fg) = switch (variant) {
      _PillVariant.success => (
          isDark
              ? const Color(0xFF22c55e).withValues(alpha: 0.12)
              : const Color(0xFF22c55e).withValues(alpha: 0.08),
          isDark ? const Color(0xFF22c55e) : const Color(0xFF16a34a),
        ),
      _PillVariant.warning => (
          isDark
              ? const Color(0xFFeab308).withValues(alpha: 0.12)
              : const Color(0xFFeab308).withValues(alpha: 0.08),
          isDark ? const Color(0xFFeab308) : const Color(0xFFb45309),
        ),
      _PillVariant.error => (
          isDark
              ? const Color(0xFFef4444).withValues(alpha: 0.12)
              : const Color(0xFFef4444).withValues(alpha: 0.08),
          isDark ? const Color(0xFFef4444) : const Color(0xFFdc2626),
        ),
      _PillVariant.muted => (
          theme.colorScheme.muted.withValues(alpha: 0.3),
          theme.colorScheme.mutedForeground,
        ),
    };

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DeskBorderRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: DeskSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return content;
  }
}
