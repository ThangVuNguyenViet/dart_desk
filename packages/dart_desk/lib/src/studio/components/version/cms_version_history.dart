import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/models/document_version.dart';
import 'package:get_it/get_it.dart';

import '../../core/view_models/cms_document_view_model.dart';
import '../../core/view_models/cms_view_model.dart';
import '../../router/studio_router.dart';

/// A version history dropdown component that displays and manages document versions.
///
/// This component uses Signals' [Watch] widget to reactively display
/// versions from the [CmsViewModel.versionsContainer]. It provides:
///
/// - Compact dropdown trigger showing selected version
/// - Expandable list with all versions
/// - Version selection (updates [CmsViewModel.selectedVersionId])
/// - Visual indicator for currently selected version
/// - Status color coding (draft=yellow, published=green, archived=gray, scheduled=blue)
/// - Loading, error, and empty states
///
/// ## Usage
///
/// ```dart
/// CmsVersionHistory(
///   viewModel: myViewModel,
/// )
/// ```
class CmsVersionHistory extends StatefulWidget {
  /// The CMS view model containing version data and selection state.
  final CmsViewModel viewModel;

  const CmsVersionHistory({super.key, required this.viewModel});

  @override
  State<CmsVersionHistory> createState() => _CmsVersionHistoryState();
}

class _CmsVersionHistoryState extends State<CmsVersionHistory> {
  late final ShadPopoverController _popoverController;

  @override
  void initState() {
    super.initState();
    _popoverController = ShadPopoverController();
  }

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final documentViewModel = GetIt.I<CmsDocumentViewModel>();
    final docId = documentViewModel.documentId.watch(context);

    final versionsState = docId != null
        ? widget.viewModel.versionsContainer(docId).watch(context)
        : AsyncState.data(
            DocumentVersionList(versions: [], total: 0, page: 1, pageSize: 10),
          );

    final selectedVersionId = widget.viewModel.selectedVersionId.watch(context);

    return versionsState.map(
      data: (data) {
        final selectedVersion = data.versions.firstWhere(
          (v) => v.id == selectedVersionId,
          orElse: () => data.versions.isNotEmpty
              ? data.versions.first
              : DocumentVersion(
                  documentId: 0,
                  versionNumber: 0,
                  status: DocumentVersionStatus.draft,
                ),
        );

        return ShadPopover(
          controller: _popoverController,
          popover: (context) => _buildVersionsList(context, theme, data),
          child: _buildTrigger(context, theme, selectedVersion, data),
        );
      },
      error: (error, stackTrace) {
        return _buildErrorTrigger(context, theme, error);
      },
      loading: () {
        return _buildLoadingTrigger(context, theme);
      },
    );
  }

  /// Builds the dropdown trigger button.
  Widget _buildTrigger(
    BuildContext context,
    ShadThemeData theme,
    DocumentVersion selectedVersion,
    DocumentVersionList data,
  ) {
    final hasSelection = selectedVersion.versionNumber > 0;

    return ShadButton.outline(
      key: const ValueKey('version_history_button'),
      onPressed: data.versions.isEmpty ? null : _popoverController.toggle,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSelection) ...[
            Text(
              'v${selectedVersion.versionNumber}',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            _StatusBadge(version: selectedVersion, compact: true),
          ] else ...[
            Text(
              'Select Version',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(width: 6),
          FaIcon(
            FontAwesomeIcons.arrowsUpDown,
            size: 12,
            color: theme.colorScheme.mutedForeground,
          ),
        ],
      ),
    );
  }

  /// Builds the loading trigger button.
  Widget _buildLoadingTrigger(BuildContext context, ShadThemeData theme) {
    return ShadButton.outline(
      onPressed: null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loading...',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error trigger button.
  Widget _buildErrorTrigger(
    BuildContext context,
    ShadThemeData theme,
    Object error,
  ) {
    return ShadButton.outline(
      onPressed: null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Error loading versions',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.destructive,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 16,
            color: theme.colorScheme.destructive,
          ),
        ],
      ),
    );
  }

  /// Builds the dropdown content with the list of versions.
  Widget _buildVersionsList(
    BuildContext context,
    ShadThemeData theme,
    DocumentVersionList data,
  ) {
    if (data.versions.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Version History',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          Container(height: 1, color: theme.colorScheme.border),
          // Version list
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: data.versions.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: theme.colorScheme.border.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final version = data.versions[index];
                final isSelected =
                    widget.viewModel.selectedVersionId.value == version.id;

                return _VersionMenuItem(
                  version: version,
                  isSelected: isSelected,
                  onTap: () {
                    if (version.id != null) {
                      final docTypeSlug =
                          widget.viewModel.currentDocumentTypeSlug.value;
                      final docId = widget.viewModel.currentDocumentId.value;
                      if (docTypeSlug != null && docId != null) {
                        context.router.navigate(DocumentScreenRoute(
                          documentTypeSlug: docTypeSlug,
                          documentId: docId,
                          versionId: version.id.toString(),
                        ));
                      }
                      _popoverController.toggle();
                    }
                  },
                  onPublish: version.isDraft
                      ? () => _publishVersion(context, version)
                      : null,
                  onArchive: version.isPublished
                      ? () => _archiveVersion(context, version)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publishVersion(BuildContext context, DocumentVersion version) async {
    final toaster = ShadToaster.of(context);

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Publish version'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
        child: const Text(
          'Publishing this version will archive any currently published version.',
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.viewModel.selectedVersionId.value = version.id;

    try {
      await widget.viewModel.publishVersion();
      if (mounted) {
        toaster.show(
          const ShadToast(description: Text('Version published')),
        );
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
          ShadToast.destructive(description: Text('Failed to publish: $e')),
        );
      }
    }
  }

  Future<void> _archiveVersion(BuildContext context, DocumentVersion version) async {
    final toaster = ShadToaster.of(context);

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Archive version'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
        child: const Text(
          'This version will no longer be the active published version.',
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.viewModel.selectedVersionId.value = version.id;

    try {
      await widget.viewModel.archiveVersion();
      if (mounted) {
        toaster.show(
          const ShadToast(description: Text('Version archived')),
        );
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
          ShadToast.destructive(description: Text('Failed to archive: $e')),
        );
      }
    }
  }

  /// Builds the empty state UI.
  Widget _buildEmptyState(BuildContext context, ShadThemeData theme) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: 24,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No versions yet',
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Versions will appear here once you create them.',
            style: theme.textTheme.muted.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A single version menu item in the dropdown.
class _VersionMenuItem extends StatefulWidget {
  final DocumentVersion version;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;

  const _VersionMenuItem({
    required this.version,
    required this.isSelected,
    this.onTap,
    this.onPublish,
    this.onArchive,
  });

  @override
  State<_VersionMenuItem> createState() => _VersionMenuItemState();
}

class _VersionMenuItemState extends State<_VersionMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : _isHovered
                ? theme.colorScheme.muted.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.muted.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'v${widget.version.versionNumber}',
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Text(
                          'Version ${widget.version.versionNumber}',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.foreground,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(version: widget.version, compact: true),
                      ],
                    ),
                    // Date
                    if (widget.version.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(widget.version.createdAt!),
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                      ),
                    ],
                    // Change log preview
                    if (widget.version.changeLog != null &&
                        widget.version.changeLog!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.version.changeLog!,
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action button (publish for draft, archive for published)
              if (widget.onPublish != null) ...[
                const SizedBox(width: 8),
                ShadButton(
                  key: ValueKey('publish_button_${widget.version.id}'),
                  size: ShadButtonSize.sm,
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: widget.onPublish,
                  child: const Text('Publish', style: TextStyle(fontSize: 11)),
                ),
              ],
              if (widget.onArchive != null) ...[
                const SizedBox(width: 8),
                ShadButton.outline(
                  key: ValueKey('archive_button_${widget.version.id}'),
                  size: ShadButtonSize.sm,
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: widget.onArchive,
                  child: const Text('Archive', style: TextStyle(fontSize: 11)),
                ),
              ],
              // Selection checkmark
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primaryForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a date to a human-readable string.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}

/// A status badge for a document version.
class _StatusBadge extends StatelessWidget {
  final DocumentVersion version;
  final bool compact;

  const _StatusBadge({required this.version, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Determine badge style based on status
    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    if (version.isDraft) {
      backgroundColor = const Color(0xFFFEF3C7); // Yellow-100
      foregroundColor = const Color(0xFF92400E); // Yellow-900
      label = compact ? 'D' : 'DRAFT';
    } else if (version.isPublished) {
      backgroundColor = const Color(0xFFD1FAE5); // Green-100
      foregroundColor = const Color(0xFF065F46); // Green-900
      label = compact ? 'P' : 'PUBLISHED';
    } else if (version.isArchived) {
      backgroundColor = theme.colorScheme.muted.withValues(alpha: 0.5);
      foregroundColor = theme.colorScheme.mutedForeground;
      label = compact ? 'A' : 'ARCHIVED';
    } else if (version.isScheduled) {
      backgroundColor = const Color(0xFFDBEAFE); // Blue-100
      foregroundColor = const Color(0xFF1E40AF); // Blue-900
      label = compact ? 'S' : 'SCHEDULED';
    } else {
      backgroundColor = theme.colorScheme.muted.withValues(alpha: 0.5);
      foregroundColor = theme.colorScheme.mutedForeground;
      label = compact ? '?' : version.status.value.toUpperCase();
    }

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
