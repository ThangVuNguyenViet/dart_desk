import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../../data/models/document_version.dart';
import 'package:get_it/get_it.dart';

import '../../core/view_models/desk_document_view_model.dart';
import '../../core/view_models/desk_view_model.dart';
import '../../router/studio_router.dart';

// ---------------------------------------------------------------------------
// HistoryEvent ADT
// ---------------------------------------------------------------------------

/// Sealed base for all history timeline events.
sealed class HistoryEvent {
  DateTime get timestamp;
  String? get authorUserId;
}

/// A version publish event — emitted when a [DocumentVersion] transitions to
/// [DocumentVersionStatus.published].
class PublishedEvent extends HistoryEvent {
  final DocumentVersion version;

  PublishedEvent(this.version);

  @override
  DateTime get timestamp => version.publishedAt!;

  @override
  String? get authorUserId => version.createdByUserId;
}

// TODO(version-history-edits): emit EditedEvent bursts once the backend
// exposes raw CRDT ops over an endpoint. Today's data source only returns
// DocumentVersions, so the timeline shows publish events only.
class EditedEvent extends HistoryEvent {
  final DateTime burstStart;
  final DateTime burstEnd;
  @override
  final String? authorUserId;

  EditedEvent({
    required this.burstStart,
    required this.burstEnd,
    this.authorUserId,
  });

  @override
  DateTime get timestamp => burstEnd;
}

// ---------------------------------------------------------------------------
// DeskVersionHistory widget
// ---------------------------------------------------------------------------

/// A version history dropdown component that displays an event-style timeline.
///
/// This component uses Signals' [Watch] widget to reactively display
/// versions from the [DeskViewModel.versionsContainer]. It provides:
///
/// - Compact dropdown trigger showing selected version
/// - Event-style timeline showing [PublishedEvent]s sorted newest-first
/// - Restore action wired to [DeskViewModel.restoreVersion]
/// - Loading, error, and empty states
///
/// Only [DocumentVersionStatus.published] versions appear in the timeline.
/// Draft and archived versions are excluded.
///
/// ## Usage
///
/// ```dart
/// DeskVersionHistory(
///   viewModel: myViewModel,
/// )
/// ```
class DeskVersionHistory extends StatefulWidget {
  /// The CMS view model containing version data and selection state.
  final DeskViewModel viewModel;

  const DeskVersionHistory({super.key, required this.viewModel});

  @override
  State<DeskVersionHistory> createState() => _DeskVersionHistoryState();
}

class _DeskVersionHistoryState extends State<DeskVersionHistory> {
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

    final documentViewModel = GetIt.I<DeskDocumentViewModel>();
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
                  documentId: '',
                  versionNumber: 0,
                  status: DocumentVersionStatus.draft,
                ),
        );

        // Build timeline: published versions only, newest first.
        final events = _buildEvents(data);

        return ShadPopover(
          controller: _popoverController,
          popover: (context) =>
              _buildTimeline(context, theme, data, events, docId),
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

  /// Builds the list of [PublishedEvent]s from [data], sorted newest first.
  List<PublishedEvent> _buildEvents(DocumentVersionList data) {
    return data.versions
        .where((v) => v.isPublished && v.publishedAt != null)
        .map((v) => PublishedEvent(v))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  /// Builds the event-style timeline panel.
  Widget _buildTimeline(
    BuildContext context,
    ShadThemeData theme,
    DocumentVersionList data,
    List<PublishedEvent> events,
    String? docId,
  ) {
    if (events.isEmpty) {
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
          // Timeline list
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: events.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: theme.colorScheme.border.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final event = events[index];
                return _TimelineEventRow(
                  key: ValueKey('timeline_event_${event.version.id}'),
                  event: event,
                  onViewVersion: () {
                    if (event.version.id != null && docId != null) {
                      final docTypeSlug =
                          widget.viewModel.currentDocumentTypeSlug.value;
                      final documentId =
                          widget.viewModel.currentDocumentId.value;
                      if (docTypeSlug != null && documentId != null) {
                        context.router.navigate(
                          DocumentScreenRoute(
                            documentTypeSlug: docTypeSlug,
                            documentId: documentId,
                            versionId: event.version.id.toString(),
                          ),
                        );
                      }
                      _popoverController.toggle();
                    }
                  },
                  onRestore: docId != null && event.version.id != null
                      ? () => _restoreVersion(context, docId, event)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreVersion(
    BuildContext context,
    String docId,
    PublishedEvent event,
  ) async {
    final toaster = ShadToaster.of(context);
    _popoverController.hide();

    try {
      await widget.viewModel.restoreVersion.run((
        documentId: docId,
        versionId: event.version.id!,
      ));
      if (mounted) {
        toaster.show(
          ShadToast(
            description: Text(
              'Restored to version ${event.version.versionNumber} — '
              'review and Publish to make it live',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        toaster.show(
          ShadToast.destructive(
            description: Text('Failed to restore: $e'),
          ),
        );
      }
    }
  }

  /// Builds the empty state UI (no published versions yet).
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
            'No published versions yet',
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Publish a version to start tracking history.',
            style: theme.textTheme.muted.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TimelineEventRow
// ---------------------------------------------------------------------------

/// A single row in the event-style timeline.
class _TimelineEventRow extends StatefulWidget {
  final PublishedEvent event;
  final VoidCallback? onViewVersion;
  final VoidCallback? onRestore;

  const _TimelineEventRow({
    super.key,
    required this.event,
    this.onViewVersion,
    this.onRestore,
  });

  @override
  State<_TimelineEventRow> createState() => _TimelineEventRowState();
}

class _TimelineEventRowState extends State<_TimelineEventRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final version = widget.event.version;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onViewVersion,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.muted.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Publish icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5), // Green-100
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.arrowUpFromBracket,
                    size: 14,
                    color: Color(0xFF065F46), // Green-900
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label row
                    Row(
                      children: [
                        Text(
                          'Published',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.foreground,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'v${version.versionNumber}',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    // Relative timestamp
                    const SizedBox(height: 2),
                    Text(
                      _formatRelativeTime(widget.event.timestamp),
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                    // Author (userId text, no avatar in v1)
                    if (version.createdByUserId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'by ${version.createdByUserId}',
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Restore button
              if (widget.onRestore != null) ...[
                const SizedBox(width: 8),
                ShadButton.outline(
                  key: ValueKey('restore_button_${version.id}'),
                  size: ShadButtonSize.sm,
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: widget.onRestore,
                  child: const Text('Restore', style: TextStyle(fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a human-readable relative time string (e.g. "2h ago").
  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}

// ---------------------------------------------------------------------------
// _StatusBadge (kept for trigger button)
// ---------------------------------------------------------------------------

/// A status badge for a document version.
class _StatusBadge extends StatelessWidget {
  final DocumentVersion version;
  final bool compact;

  const _StatusBadge({required this.version, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

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
